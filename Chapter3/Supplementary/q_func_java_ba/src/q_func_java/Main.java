package q_func_java;

import java.io.FileNotFoundException;
import java.io.IOException;

public class Main {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) throws FileNotFoundException, IOException {
        HitFunctionQ hfq = new HitFunctionQ();
        System.out.println("start");
        hfq.setInputFile("files/gene_align_seqs_E1_.yaml");
        hfq.setOutputFile("files/q_e1_java_ba.txt");
        hfq.initializeCanceroSquam();
        hfq.parseMsa();
        hfq.eliminateNonUsed();
        hfq.layoutSeqs();

        long t, t0;
        t = System.currentTimeMillis();
        hfq.calculate();

        t0 = (System.currentTimeMillis() - t) / 1000;
        System.out.println("temps calcul : " + t0);
    }
}
