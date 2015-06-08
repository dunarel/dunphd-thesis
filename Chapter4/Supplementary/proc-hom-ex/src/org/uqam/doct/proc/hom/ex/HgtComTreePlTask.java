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
public class HgtComTreePlTask implements Runnable {

    //constructor
    private final int spawnedNbThreads;
    private final String workRootFolder;
    private final String geneName;
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
        for (int i = 0; i < mrcas.length; i++) {
        //show
            if (!mrcas[i].equals("")) {
                System.out.println("i: " + i + " mrca: " + mrcas[i]);
           }

        }

    }

    //constructor
     //internalCmd: "treePL gene_res.cfg"
    public HgtComTreePlTask(String internalCmd, int spawnedNbThreads, String workRootFolder, String alignLen, String geneName)
            throws FileNotFoundException, IOException {
        this.spawnedNbThreads = spawnedNbThreads;
        this.workRootFolder = workRootFolder;
        this.geneName = geneName;
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
    
    //retry nb for each constraint
    int maxRnd;
    int nbRnd;

    private void executeGene()
            throws IOException, InterruptedException {

        
        String workingDir = workRootFolder + "/" + geneName;
        String treeplCfg = workingDir + "/gene_res.cfg";
        String datedTree = workingDir + "/dated_tree.nwk";
        File datedTreeFile;
        //Start with small error probability
        maxRnd = 10;

        //test activate constraints
        for (int x = 0; x < mrcas.length; x++) {
            
          //for each constraint take maximum dynamic probability
          nbRnd=maxRnd;
          boolean passed = false;
          
          while (passed == false && nbRnd >= 0 ) {
          
            mrcasStr = new StringBuffer();
            //include previous activated constraints
            for (int prevIdx = 0; prevIdx < x; prevIdx++) {
                if (mrcaActiv[prevIdx].equals(true)) {
                    mrcasStr.append(mrcas[prevIdx]);
                    mrcasStr.append("\n");
                }
            }
            //all cases include current step 
            mrcasStr.append(mrcas[x]);

            //test current constraints 
            out = new BufferedWriter(new FileWriter(treeplCfg));
            out.write("treefile  = gene_rooted.nwk \n");
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

            //skip retry if activated
            if ( mrcaActiv[x] == true) {
                passed = true;
            } else {
                nbRnd--;
                System.out.println("Go into retry: " + nbRnd);
            }
                
            // less retry anyway
            
            
            
           } //end while retry
          
          //if activated after some work
          if ( mrcaActiv[x] == true && nbRnd != maxRnd) {
              //next activations more difficult
              //so give more chances
              maxRnd += 5;
              System.out.println("Increased maxRnd to: " + maxRnd);
            }

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
                mrcasStr.append("\n");
            } else {
                mrcasStr.append("# skiped constraint " + i + " \n");
            }
        }

        //test final constraints 
        out = new BufferedWriter(new FileWriter(treeplCfg));
        out.write("treefile  = gene_rooted.nwk \n");
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
            Logger.getLogger(HgtComTreePlTask.class.getName()).log(Level.SEVERE, null, ex);
        } catch (InterruptedException ex) {
            Logger.getLogger(HgtComTreePlTask.class.getName()).log(Level.SEVERE, null, ex);
        }


    }
}
