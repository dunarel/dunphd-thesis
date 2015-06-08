package org.uqam.doct.proc.hom.ex;

import com.esotericsoftware.yamlbeans.YamlReader;
import java.io.BufferedWriter;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Date;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import org.apache.commons.exec.CommandLine;
import org.apache.commons.exec.DefaultExecutor;
import org.apache.commons.exec.PumpStreamHandler;

/**
 *
 * @author root
 */
public class HgtParTreePlTask implements Runnable {

    //constructor
    private final int spawnedNbThreads;
    private final String workRootFolder;
    private final String geneName;
    private final String winName;
    private final String alignLen;
    private final String internalCmd;
    
    //
    //constraints
    private String[] mrcas;
    private Boolean[] mrcaActiv;

    private void readGeneConfig()
            throws FileNotFoundException, IOException {

        String mrcasFile = workRootFolder + "/" + geneName + "/" + "mrcas.yaml";
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

    //constructor
    //internalCmd: "treePL gene_res.cfg"
    public HgtParTreePlTask(String internalCmd, int spawnedNbThreads, String workRootFolder, String alignLen, String geneName, String winName)
            throws FileNotFoundException, IOException {
        this.spawnedNbThreads = spawnedNbThreads;
        this.workRootFolder = workRootFolder;
        this.geneName = geneName;
        this.winName = winName;
        this.alignLen = alignLen;
        this.internalCmd = internalCmd;

        readGeneConfig();
    }
    //execute
    ByteArrayOutputStream stdout;
    PumpStreamHandler psh;
    CommandLine cl;
    DefaultExecutor exec;
    //        
    StringBuffer mrcasStr;
    BufferedWriter out;
    int nbConstr;

    private void executeWin()
            throws IOException, InterruptedException {

        
        String workingDir = workRootFolder + "/" + geneName + "/" + winName;
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
            out.write("nthreads = " + spawnedNbThreads + " \n");
            //add final optimisation
            //out.write("thorough \n");
            out.flush();

            out.close();
            //give disk time to flush
            Thread.sleep(200);
            //execute
            stdout = new ByteArrayOutputStream();
            psh = new PumpStreamHandler(stdout);
            cl = CommandLine.parse(internalCmd);
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
                //System.out.println(stdout.toString());
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
        out.write("nthreads = " + spawnedNbThreads + " \n");
        //add final optimisation
        out.write("thorough \n");
        out.flush();
        out.close();
        //give disk time to flush
        Thread.sleep(200);


        //check if output
        int maxRet = 40;
        datedTreeFile = new File(datedTree);
        while ((!datedTreeFile.exists() || datedTreeFile.length() == 0) && maxRet > 0) {


            double bytes = datedTreeFile.length();
            System.out.println("maxRet: " + maxRet + " file len: " + bytes);
            //execute
            stdout = new ByteArrayOutputStream();
            psh = new PumpStreamHandler(stdout);
            cl = CommandLine.parse(internalCmd);
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

    @Override
    public void run() {

        System.out.printf("thread_name: %s, geneName: %s, winName: %s\n", Thread.currentThread().getName(), geneName, winName);
        try {
            executeWin();


            //tag = Thread.currentThread().getName() + "tag";

            //starting
            //System.out.printf("%s: Task %s: Created on: %s\n", Thread.currentThread().getName(), name, initDate);
            //System.out.printf("%s: Task %s: Started on: %s\n", Thread.currentThread().getName(), name, new Date());
            //wait
            //try {
            //    Long duration = (long) (Math.random() * 10);
            //    System.out.printf("%s: Task %s: Doing a task during %d seconds \n", Thread.currentThread().getName(), name, duration);
            //    TimeUnit.SECONDS.sleep(duration);
            //} catch (InterruptedException e) {
            //    e.printStackTrace();
            //}
            //finish
            //        currentThread().getName(), name, new Date(), initDate);
            //        currentThread().getName(), name, new Date(), initDate);
        } catch (IOException ex) {
            Logger.getLogger(HgtParTreePlTask.class.getName()).log(Level.SEVERE, null, ex);
        } catch (InterruptedException ex) {
            Logger.getLogger(HgtParTreePlTask.class.getName()).log(Level.SEVERE, null, ex);
        }


    }
}
