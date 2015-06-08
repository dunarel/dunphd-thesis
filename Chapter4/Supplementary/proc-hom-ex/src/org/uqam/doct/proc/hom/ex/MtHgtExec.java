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
import java.util.concurrent.TimeUnit;
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
public class MtHgtExec {

    // create Options object
    static Options options;
    static org.apache.commons.cli.CommandLine line;
    // from comman line
    static String rootFolder;
    static String jobName;
    static int nbThreads;
    static String stage;
    static String timingProg;
    static String internalCmd;
    
    //job tasks parameters
    static ArrayList<Integer> tasksId;
    static ArrayList<String> tasksGeneName;
    static ArrayList<String> tasksWinName;
    static ArrayList<String> tasksAlignLen;
    //
    static Server server;

    static void loadJobTasksList() throws FileNotFoundException, YamlException {
        String tasksFile = rootFolder + "/jobs" + "/job-tasks-" + jobName + ".yaml";
        YamlReader reader = new YamlReader(new FileReader(tasksFile));

        switch (stage) {
            case "hgt-com":
                reader.getConfig().setClassTag("ruby/object:Gene", Map.class);
                break;
            case "hgt-par":
                reader.getConfig().setClassTag("ruby/object:HgtParFragm", Map.class);
                break;
        }



        Object object = reader.read();

        System.out.println(object);

        //load static list of task parameters
        tasksId = new ArrayList<Integer>();
        tasksGeneName = new ArrayList<String>();
        //stage hgt-com has no windows
        tasksWinName = new ArrayList<String>();
        tasksAlignLen = new ArrayList<String>();

        int id = 0;
        for (Map el : (ArrayList<Map>) object) {
            System.out.println("element: " + el.toString());
            Map<String, String> attr = (Map<String, String>) el.get("attributes");
            //int fen_no = 
            tasksId.add(id);
           
                      
            //stage hgt-com has no windows
            //and gene_name is name
            switch (stage) {
                case "hgt-com":
                    tasksGeneName.add(attr.get("name"));
                    tasksWinName.add("");
                    tasksAlignLen.add(attr.get("align_len"));
                    break;
                case "hgt-par":
                    tasksGeneName.add(attr.get("gene_name"));
                    tasksWinName.add(attr.get("win_size") + "/" + attr.get("fen_no") + "-" + attr.get("fen_idx_min") + "-" + attr.get("fen_idx_max"));
                    tasksAlignLen.add(attr.get("align_len"));
                    break;
            }

            id++;
        }



    }
    
    static Runnable taskBuilder(int i) throws FileNotFoundException, IOException {
       
      Runnable runTask = null;
       
       if        ("hgt-com".equals(stage) && "treepl".equals(timingProg)) {
           runTask =  new HgtComTreePlTask(internalCmd, 1, (rootFolder + "/work"), tasksAlignLen.get(i), tasksGeneName.get(i));
       } else if ("hgt-par".equals(stage) && "treepl".equals(timingProg)) {
           runTask =  new HgtParTreePlTask(internalCmd, 1, (rootFolder + "/work"), tasksAlignLen.get(i), tasksGeneName.get(i), tasksWinName.get(i));
       } else if ("hgt-com".equals(stage) && "beast".equals(timingProg)) {
           runTask =  new HgtComBeastTask(internalCmd, 1, (rootFolder + "/work"), tasksAlignLen.get(i), tasksGeneName.get(i));
       } else if ("hgt-par".equals(stage) && "beast".equals(timingProg)) {
           runTask =  new HgtParBeastTask(internalCmd, 1, (rootFolder + "/work"), tasksAlignLen.get(i), tasksGeneName.get(i), tasksWinName.get(i));
       }
       
       return runTask;
        
        
    }

    static void executeTasks() throws FileNotFoundException, IOException {

        //executeOneWin("25/2-25-298");

        server = new Server(nbThreads);

        for (int i = 0; i < tasksId.size(); i++) {
            
            Runnable task = taskBuilder(i);
            
            server.executeTask(task);
            //TimeUnit.SECONDS.sleep(2);


        }
        server.endServer();
    }

    static void loadCommandLineOptions() {
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
                .withDescription("job name")
                .create("job");
        Option threadsNbOpt = OptionBuilder.withArgName("number")
                .hasArg()
                .withDescription("Concurrent threads")
                .create("threads");

        Option stageNameOpt = OptionBuilder.withArgName("name")
                .hasArg()
                .withDescription("stage name")
                .create("stage");

        Option timingProgNameOpt = OptionBuilder.withArgName("name")
                .hasArg()
                .withDescription("timing_prog name")
                .create("timing_prog");
        
        Option internalCmdOpt = OptionBuilder.withArgName("cmd")
                .hasArg()
                .withDescription("internal_cmd cmd")
                .create("internal_cmd");

        // create Options object
        options = new Options();
        options.addOption(helpOpt);
        options.addOption(logfileOpt);
        options.addOption(rootFolderOpt);
        options.addOption(geneNameOpt);
        options.addOption(threadsNbOpt);
        options.addOption(stageNameOpt);
        options.addOption(timingProgNameOpt);
        options.addOption(internalCmdOpt);
        







    }

    static void parseCommandLineOptions() {
        // has the buildfile argument been passed?
        if (line.hasOption("help")) {
            HelpFormatter formatter = new HelpFormatter();
            formatter.printHelp("HgtParTreePl", options);

        }

        // automatically generate the help statement

        if (line.hasOption("root")) {
            rootFolder = line.getOptionValue("root");
        }

        if (line.hasOption("job")) {
            jobName = line.getOptionValue("job");
        }

        if (line.hasOption("threads")) {
            nbThreads = Integer.valueOf(line.getOptionValue("threads"));
        }

        if (line.hasOption("stage")) {
            stage = line.getOptionValue("stage");
        }

        if (line.hasOption("timing_prog")) {
            timingProg = line.getOptionValue("timing_prog");
        }
        
        if (line.hasOption("internal_cmd")) {
            internalCmd = line.getOptionValue("internal_cmd");
        }


        System.out.println("job: " + jobName);
        System.out.println("root: " + rootFolder);
        System.out.println("stage: " + stage);
        System.out.println("timing_prog: " + timingProg);
        System.out.println("internal_cmd: " + internalCmd);
        
    }

    public static void main(String[] args)
            throws FileNotFoundException, IOException, InterruptedException {
        
        //-help -threads 2 -job 04001 -root /root/devel/proc_hom/files/hgt-par-110/timing/beast -stage hgt-par -timing_prog beast -internal_cmd "java -jar /root/local/BEASTv1.7.4/lib/beast.jar -overwrite gene_beast.xml"
        //-help -threads 2 -job 00201 -root /root/devel/proc_hom/files/hgt-com-110/hgt-com-raxml/timing/treepl -stage hgt-com -timing_prog treepl -internal_cmd "treePL gene_res.cfg"
        
        
        
        //load options
        loadCommandLineOptions();

        //parse command line
        CommandLineParser parser = new GnuParser();
        try {
            // parse the command line arguments
            line = parser.parse(options, args);
        } catch (ParseException exp) {
            // oops, something went wrong
            System.err.println("Parsing failed.  Reason: " + exp.getMessage());
        }
        //parse options
        parseCommandLineOptions();
        //load static jobs
        loadJobTasksList();

        //execute all tasks
        executeTasks();


        // hptp.readGeneConfig();

    }
}
