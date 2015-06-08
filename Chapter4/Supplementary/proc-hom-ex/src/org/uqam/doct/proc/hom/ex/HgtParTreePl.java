/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.uqam.doct.proc.hom.ex;

import com.esotericsoftware.yamlbeans.YamlException;
import com.esotericsoftware.yamlbeans.YamlReader;
import java.io.BufferedWriter;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.GnuParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Option;
import org.apache.commons.cli.OptionBuilder;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.commons.exec.CommandLine;
import org.apache.commons.exec.DefaultExecutor;
import org.apache.commons.exec.PumpStreamHandler;

/**
 *
 * @author root
 */
public class HgtParTreePl {

    // create Options object
    static Options options;
    static org.apache.commons.cli.CommandLine line;
    static String rootFolder;
    static String geneName;
    static int threadsNb;
    //
    //execute
    ByteArrayOutputStream stdout;
    PumpStreamHandler psh;
    CommandLine cl;
    DefaultExecutor exec;
    //        
    StringBuffer mrcasStr;
    BufferedWriter out;
    int nbConstr;
    //
    String[] mrcas;
    Boolean[] mrcaActiv;
    ArrayList<String> winNames;

    HgtParTreePl(String geneName) {
        this.geneName = geneName;
    }

    public void readGeneConfig()
            throws FileNotFoundException, IOException {

        String mrcasFile = rootFolder + "/" + geneName + "/" + "mrcas.yaml";
        YamlReader reader = new YamlReader(new FileReader(mrcasFile));
        reader.getConfig().setClassTag("!", String.class);

        Object object = reader.read();
        //System.out.println(object);

        Map<String, String> map = (Map<String, String>) object;

        mrcas = new String[map.size()];
        mrcaActiv = new Boolean[mrcas.length];


        for (String k : map.keySet()) {
            //inialize mrcas array
            mrcas[Integer.valueOf(k)] = map.get(k);
            //initialize mrcaActiv
            mrcaActiv[Integer.valueOf(k)] = false;

        }

        System.out.println("mrcas size: " + mrcas.length);


        //show all constraints
        //for (int i = 0; i < mrcas.length; i++) {
        //show
        //    if (!mrcas[i].equals("")) {
        //        System.out.println("i: " + i + " mrca: " + mrcas[i]);
        //   }

        //}

    }

    public void readTasksList() throws FileNotFoundException, YamlException {
        String tasksFile = rootFolder + "/" + geneName + "/" + "tasks.yaml";
        YamlReader reader = new YamlReader(new FileReader(tasksFile));
        reader.getConfig().setClassTag("ruby/object:HgtParFragm", Map.class);

        Object object = reader.read();

        System.out.println(object);

        winNames = new ArrayList<String>();

        for (Map el : (ArrayList<Map>) object) {
            System.out.println("element: " + el.toString());
            Map<String, String> attr = (Map<String, String>) el.get("attributes");
            //int fen_no = 
            winNames.add(attr.get("win_size") + "/" + attr.get("fen_no") + "-" + attr.get("fen_idx_min") + "-" + attr.get("fen_idx_max"));

        }



    }

    public void executeOneWin(String winName) throws IOException, InterruptedException {

        int alignLen = 272;
        String workingDir = rootFolder + "/" + geneName + "/" + winName;
        String treeplCfg = workingDir + "/gene_res.cfg";
        String datedTree = workingDir + "/dated_tree.nwk";
        File datedTreeFile;

        //test activate constraints
        for (int x = 0; x < mrcas.length; x++) {
            mrcasStr = new StringBuffer();

            for (int prevIdx = 0; prevIdx < x; prevIdx++) {
                if (mrcaActiv[prevIdx].equals(true)) {
                    mrcasStr.append(mrcas[prevIdx]);
                }
            }
            //all cases include current step 
            mrcasStr.append(mrcas[x]);

            //test current constraints 
            out = new BufferedWriter(new FileWriter(treeplCfg));
            out.write("treefile  = gene_res.tr \n");
            out.write("smooth = 100 \n");
            out.write("numsites = " + alignLen + " \n");
            out.write(" \n");
            //add all current constrains
            out.write("" + mrcasStr.toString() + " \n");
            out.write("outfile = dated_tree.nwk \n");
            out.write("nthreads = " + threadsNb + " \n");
            //add final optimisation
            //out.write("thorough \n");
            out.flush();

            out.close();
            //give disk time to flush
            Thread.sleep(200);
            //execute
            stdout = new ByteArrayOutputStream();
            psh = new PumpStreamHandler(stdout);
            cl = CommandLine.parse("treePL gene_res.cfg");
            exec = new DefaultExecutor();
            exec.setWorkingDirectory(new File(workingDir));
            exec.setStreamHandler(psh);
            try {
                mrcaActiv[x] = true;
                System.out.println("Activated constraint " + x);
                exec.execute(cl);
                //activate constraint if execution successfull
                //decision is based on process not result 
                //as in complete transfers jruby version

            } catch (org.apache.commons.exec.ExecuteException e) {
                System.out.println("Message: " + e.getMessage());
                System.out.println("exitValue: " + e.getExitValue());
                mrcaActiv[x] = false;
                System.out.println("Error constraint " + x);

            } finally {
                System.out.println(stdout.toString());
            }


            Pattern p = Pattern.compile("(problem)\\s(initializing)");
            stdout.flush();
            Matcher m = p.matcher(stdout.toString());
            if (m.find()) {
                System.out.println("g0: " + m.group(0));
                //inactivate mrca
                mrcaActiv[x] = false;
                System.out.println("Problem constraint " + x);
            };



        }

        System.out.println("All tested, final step----------------");
        //final step
        mrcasStr = new StringBuffer();

        //count constraints
        nbConstr = 0;
        for (int i = 0; i < mrcas.length; i++) {
            if (mrcaActiv[i].equals(true)) {
                //count constraints
                nbConstr++;
                //add  constraint
                mrcasStr.append(mrcas[i]);
            } else {
                mrcasStr.append("# skiped constraint " + i + " \n");
            }
        }

        //test final constraints 
        out = new BufferedWriter(new FileWriter(treeplCfg));
        out.write("treefile  = gene_res.tr \n");
        out.write("smooth = 100 \n");
        out.write("numsites = " + alignLen + " \n");
        out.write(" \n");
        //add all current constrains
        out.write("" + mrcasStr.toString() + " \n");
        out.write("outfile = dated_tree.nwk \n");
        out.write("nthreads = " + threadsNb + " \n");
        //add final optimisation
        out.write("thorough \n");
        out.flush();
        out.close();
        //give disk time to flush
        Thread.sleep(200);


        //check if output
        int maxRet = 100;
        datedTreeFile = new File(datedTree);
        while ( (!datedTreeFile.exists() || datedTreeFile.length() == 0) && maxRet > 0) {
        
            
            double bytes = datedTreeFile.length();
            System.out.println("maxRet: " +maxRet + " file len: " + bytes);
            //execute
            stdout = new ByteArrayOutputStream();
            psh = new PumpStreamHandler(stdout);
            cl = CommandLine.parse("treePL gene_res.cfg");
            exec = new DefaultExecutor();
            exec.setWorkingDirectory(new File(workingDir));
            exec.setStreamHandler(psh);
            try {
                exec.execute(cl);
            } catch (org.apache.commons.exec.ExecuteException e) {
                //System.out.println("Message: " + e.getMessage());
                System.out.println("exitValue: " + e.getExitValue());


            } finally {
                //System.out.println(stdout.toString());
                //System.out.println("nbConstr: " + nbConstr);
            }
            maxRet--;
            
            datedTreeFile = new File(datedTree);
            System.out.println("------------------len: " + datedTreeFile.length());
        
            Thread.sleep(200);
        }




    }

    public void executeAllWins() throws IOException, InterruptedException {

        for (String wn : winNames) {
            System.out.println("executing wn: " + wn);
            executeOneWin(wn);
        }

        //executeOneWin("25/2-25-298");


    }

    public static void main(String[] args)
            throws FileNotFoundException, IOException, InterruptedException {

        //
        Option helpOpt = new Option("help", "print this message");
        Option logfileOpt = OptionBuilder.withArgName("file")
                .hasArg()
                .withDescription("use given file for log")
                .create("logfile");
        Option rootFolderOpt = OptionBuilder.withArgName("folder")
                .hasArg()
                .withDescription("use given folder for all genes")
                .create("root");

        Option geneNameOpt = OptionBuilder.withArgName("name")
                .hasArg()
                .withDescription("gene name")
                .create("gene");
        Option threadsNbOpt = OptionBuilder.withArgName("number")
                .hasArg()
                .withDescription("Concurrent threads")
                .create("threads");

        // create Options object
        options = new Options();
        options.addOption(helpOpt);
        options.addOption(logfileOpt);
        options.addOption(rootFolderOpt);
        options.addOption(geneNameOpt);
        options.addOption(threadsNbOpt);



        // create the parser
        CommandLineParser parser = new GnuParser();
        try {
            // parse the command line arguments
            line = parser.parse(options, args);
        } catch (ParseException exp) {
            // oops, something went wrong
            System.err.println("Parsing failed.  Reason: " + exp.getMessage());
        }


        // has the buildfile argument been passed?
        if (line.hasOption("help")) {
            HelpFormatter formatter = new HelpFormatter();
            formatter.printHelp("HgtParTreePl", options);

        }

        // automatically generate the help statement

        if (line.hasOption("root")) {
            rootFolder = line.getOptionValue("root");
        }

        if (line.hasOption("gene")) {
            geneName = line.getOptionValue("gene");
        }

        if (line.hasOption("threads")) {
            threadsNb = Integer.valueOf(line.getOptionValue("threads"));
        }


        System.out.println("gene: " + geneName);
        System.out.println("root: " + rootFolder);

        HgtParTreePl hptp = new HgtParTreePl(geneName);
        hptp.readGeneConfig();
        hptp.readTasksList();

        hptp.executeAllWins();






    }
}
