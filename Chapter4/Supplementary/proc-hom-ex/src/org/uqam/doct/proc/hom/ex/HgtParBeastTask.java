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
public class HgtParBeastTask implements Runnable {

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
    public HgtParBeastTask(String internalCmd, int spawnedNbThreads, String workRootFolder, String alignLen, String geneName, String winName)
            throws FileNotFoundException, IOException {
        this.spawnedNbThreads = spawnedNbThreads;
        this.workRootFolder = workRootFolder;
        this.geneName = geneName;
        this.winName = winName;
        this.alignLen = alignLen;
        this.internalCmd = internalCmd;

        //readGeneConfig();
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
        String datedTree = workingDir + "/dated_tree.nwk";
        File datedTreeFile;

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
            System.out.println(stdout.toString());

        }



        datedTreeFile = new File(datedTree);

        System.out.println("------------------len: " + datedTreeFile.length());

        Thread.sleep(200);

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

        } catch (IOException ex) {
            Logger.getLogger(HgtParBeastTask.class.getName()).log(Level.SEVERE, null, ex);
        } catch (InterruptedException ex) {
            Logger.getLogger(HgtParBeastTask.class.getName()).log(Level.SEVERE, null, ex);
        }


    }
}
