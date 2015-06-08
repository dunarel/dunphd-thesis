package q_func_java;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import java.util.Arrays;
import java.util.Set;

/**
 *
 * Calcul des fonctions Q
 * Implantation avec ByteArray
 */
public class HitFunctionQ {

    //io - valeurs par defaut
    File infile = new File("files/gene_align_seqs_E1_.yaml"),
            outfile = new File("files/q_e1_java_opti.txt");
    Map<String, String> align_mult_types = new HashMap<String, String>();
    List<String> cancero_squam = new ArrayList<String>();
    List<String> cancero_types = new ArrayList<String>();
    List<String> non_cancero_types = new ArrayList<String>();
    List<String> non_exist_cancero_types = new ArrayList<String>();
    List<String> all_types = new ArrayList<String>();
    int align_length = 0;
    int nx = 0;
    int ny = 0;
    byte[] seqs_x, seqs_y;

    public HitFunctionQ() {
        
    }

    /*
     * Initialisation par procédure
     */
    public void initializeCanceroSquam() {
        String[] canc_s = {"HPV-16", "HPV-18", "HPV-11", "HPV-26", "HPV-31", "HPV-33", "HPV-35", "HPV-39", "HPV-45", "HPV-52", "HPV-53",
            "HPV-55", "HPV-56", "HPV-58", "HPV-59", "HPV-6", "HPV-66", "HPV-73", "HPV-81", "HPV-82", "HPV-83"};

        cancero_squam = new ArrayList<String>(Arrays.asList(canc_s));

        System.out.println("cancero squam size: " + cancero_squam.size());

    }

    /* Directionnement des entrées
     */
    public void setInputFile(String in) {
        infile = new File(in);
    }

    /* Directionnement des sorties
     */
    public void setOutputFile(String out) {
        outfile = new File(out);
    }

    /* Interface pour JRuby,
     * Spécifie les types cancereux, ou invasifs
     */
    public void setCanceroTypes(ArrayList<String> ct) {

        this.cancero_types = ct;
        this.nx = cancero_types.size();

        for (String elem : cancero_types) {
            System.out.println("cancero_types_array_list: " + elem);
        }

    }

    /* Interface pour JRuby,
     * Spécifie les types non-cancereux, ou non-invasifs
     */
    public void setNonCanceroTypes(String[] nct) {
        this.non_cancero_types = new ArrayList<String>(Arrays.asList(nct));
        this.ny = non_cancero_types.size();
  
        for (String elem : non_cancero_types) {
            System.out.println("non_cancero_types: " + elem);
        }

    }
    /* Interface externe(JRuby) pour charger un alignement multiple
     */
    public void setAlignMultTypes(Map<String, String> amt) {
        this.align_mult_types = amt;
        for (String s : align_mult_types.keySet()) {
            align_length = Math.max(align_length, align_mult_types.get(s).length());
            //System.out.println(s + " : " + align_mult_types.get(s));

        }
        System.out.println("align_length = " + align_length);

    }

    /* Analyseur syntaxique pour alignements multiples en
     * format Yaml (Ruby), séparateur ":"
     */
    public void parseMsa()
            throws FileNotFoundException, IOException {

        BufferedReader reader = new BufferedReader(new FileReader(infile));
        all_types.clear();
        align_mult_types.clear();

        String s = null;
        int line_no = 0;
        while ((s = reader.readLine()) != null) {
            if (line_no != 0) {

                String[] sa = s.split(": ");

                all_types.add(sa[0]);
                align_mult_types.put(sa[0], sa[1]);
                align_length = Math.max(align_length, sa[1].length());

            }
            line_no++;

        }
        reader.close();

        //System.out.println("all_types size:" + all_types.size());
        //System.out.println("HPV-18 pos:" + all_types.indexOf("HPV-18"));
    }

    /* Longueur de l'alignement
     */
    public void setAllignLength(int al) {
        this.align_length = al;
    }

    /* Certains types sont cancereux ou invasifs en général,
     * pourtant on ne detient pas des données.
     * L'algorithme travaille sur les types existants.
     *
     * Élimination des types non-existants dans les alignements
     */
    public void eliminateNonUsed() {

        cancero_types = new ArrayList<String>(cancero_squam);

        non_cancero_types = new ArrayList<String>(all_types);
        non_cancero_types.removeAll(cancero_types);


        non_exist_cancero_types = new ArrayList<String>(cancero_types);
        non_exist_cancero_types.removeAll(all_types);
        System.out.println("non_exist_cancero_types: " + non_exist_cancero_types.size());
        System.out.println(non_exist_cancero_types.toString());

        cancero_types.removeAll(non_exist_cancero_types);

        nx = cancero_types.size();
        ny = non_cancero_types.size();

        Collections.sort(cancero_types);
        //Collections.sort(non_cancero_types);
        System.out.println("cancero_types" + cancero_types.toString());
        System.out.println(non_cancero_types.toString());

    }

    public void show_align_mult_types() {

         for (String s : align_mult_types.keySet()) {
           System.out.println("Key:\t"+ s);
         }


         for (String s : cancero_types) {
           System.out.println("cancero_types:\t"+ s);
         }

         for (String s : non_cancero_types) {
           System.out.println("non_cancero_types:\t"+ s);
         }


    }

    

    /* Disposition en mémoire, dans un ByteArray,
     * pour éfficacité de calcul
     */
    public void layoutSeqs() {

        System.out.println("align_length: " + align_length);
        System.out.println("nx: " + nx);
        System.out.println("ny: " + ny);


        seqs_x = new byte[align_length * nx];
        seqs_y = new byte[align_length * ny];
        int pos;


        for (String s : align_mult_types.keySet()) {
            if (cancero_types.contains(s)) {
                pos = cancero_types.indexOf(s);

                System.arraycopy(align_mult_types.get(s).getBytes(), 0,
                        seqs_x, pos * align_length, align_length);

            } else {
                pos = non_cancero_types.indexOf(s);
                //sa1 = new byte[sa[1].length()];

                System.arraycopy(align_mult_types.get(s).getBytes(), 0,
                        seqs_y, pos * align_length, align_length);

            }
        }
    }

    /* Calcul des 5 fonctions,
     *  Q0 pour les VPH,
     *  Q1-4 pour le Neisseria Meningitidis
     */
    public void calculate() throws IOException {
        BufferedWriter wr = new BufferedWriter(new FileWriter(outfile));
        PrintWriter pr = new PrintWriter(wr);
        pr.format("win_length,index,dXY,vX,vY,q0,q1,q2,q3,q4 \n");

        // Taille de la fenêtre 3-20 nucleotides
        //for (int win_length = 20; win_length >= 3; win_length--) {
        for (int win_length = 20; win_length >= 20; win_length--) {
            for (int x = 0; x < (align_length - (win_length - 1)); x++) {
//////////////////////////////////////////////////////////////////////////
                //vX
                double vX = 0.0;

                for (int i = 0; i < nx; i++) {
                    for (int j = 0; j < nx && j != i; j++) {

                        double d_seq = 0.0;
                        double d_seqn = 0.0;

                        for (int h = 0; h < win_length; h++) {


                            //d_seq += (seqs_x.get(i * align_length + x + h) == seqs_x.get(j * align_length + x + h)) ? 0.0 : 1.0;
                            d_seq += (seqs_x[i * align_length + x + h] == seqs_x[j * align_length + x + h]) ? 0.0 : 1.0;

                        //dx += (seqs_x.get(h) == seqs_y.get(x)) ? 0.0 : 1.0;
                        }
                        d_seqn = d_seq / win_length;
                        vX += (d_seqn * d_seqn);


                    }
                }

                vX /= (nx * (nx - 1) / 2.0);
///////////////////////////////////////////////////////////////////////
                //vY
                double vY = 0.0;

                for (int i = 0; i < ny; i++) {
                    for (int j = 0; j < ny && j != i; j++) {

                        double d_seq = 0.0;
                        double d_seqn = 0.0;

                        for (int h = 0; h < win_length; h++) {


                            //d_seq += (seqs_x.get(i * align_length + x + h) == seqs_x.get(j * align_length + x + h)) ? 0.0 : 1.0;
                            d_seq += (seqs_y[i * align_length + x + h] == seqs_y[j * align_length + x + h]) ? 0.0 : 1.0;

                        //dx += (seqs_x.get(h) == seqs_y.get(x)) ? 0.0 : 1.0;
                        }
                        d_seqn = d_seq / win_length;
                        vY += (d_seqn * d_seqn);


                    }
                }

                vY /= (ny * (ny - 1) / 2.0);

//////////////////////////////////////////////////////////////////////
                // dXY
                double dXY = 0.0f;

                for (int i = 0; i < nx; i++) {
                    for (int j = 0; j < ny; j++) {
                        double d_seq = 0.0;
                        double d_seqn = 0.0;

                        //dy = dist_2seq(x, win_length, seqs_x, i, seqs_y, j);
                        for (int h = 0; h < win_length; h++) {
                            //d_seq += (seqs_x.get(i * align_length + x + h) == seqs_y.get(j * align_length + x + h)) ? 0.0 : 1.0;
                            d_seq += (seqs_x[i * align_length + x + h] == seqs_y[j * align_length + x + h]) ? 0.0 : 1.0;
                        // dy += (seqs_x.get(h) == seqs_y.get(x)) ? 0.0 : 1.0;

                        }
                        d_seqn = d_seq / win_length;

                        dXY += (d_seqn * d_seqn);

                    }
                }
                dXY /= (nx * ny);

                double q0 = Math.log(1 + dXY - vX);
                double q1 = dXY - vX;
                double q2 = dXY - vY;
                double q3 = (2 * dXY) - vX - vY;
                double q4 = dXY;

                pr.format("%d,%d,%f,%f,%f,%f,%f,%f,%f,%f\n", win_length, x, dXY, vX, vY, q0, q1, q2, q3, q4);
            }
        }
        pr.close();
    }
}
