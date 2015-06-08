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
public class HgtComBeastTask implements Runnable {

    //constructor
    private final int spawnedNbThreads;
    private final String workRootFolder;
    private final String geneName;
    private final String alignLen;
    private final String internalCmd;

    //constructor
     //internalCmd: "treePL gene_res.cfg"
    public HgtComBeastTask(String internalCmd, int spawnedNbThreads, String workRootFolder, String alignLen, String geneName)
            throws FileNotFoundException, IOException {
        this.spawnedNbThreads = spawnedNbThreads;
        this.workRootFolder = workRootFolder;
        this.geneName = geneName;
        this.alignLen = alignLen;
        this.internalCmd = internalCmd;

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

    private void executeGene()
            throws IOException, InterruptedException {

        
        String workingDir = workRootFolder + "/" + geneName;
        //String datedTree = workingDir + "/dated_tree.nwk";
        //File datedTreeFile;

        
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
            
            //System.out.println("------------------len: " + datedTreeFile.length());

            Thread.sleep(200);
        



    }

    @Override
    public void run() {

        System.out.printf("thread_name: %s, geneName: %s \n", Thread.currentThread().getName(), geneName);
        try {
            executeGene();


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
            Logger.getLogger(HgtComBeastTask.class.getName()).log(Level.SEVERE, null, ex);
        } catch (InterruptedException ex) {
            Logger.getLogger(HgtComBeastTask.class.getName()).log(Level.SEVERE, null, ex);
        }


    }
}
