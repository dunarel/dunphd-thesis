/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.uqam.doct.proc.hom.sp;

import java.nio.ByteOrder;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.List;
import com.nativelibs4java.opencl.*;
import com.nativelibs4java.util.*;
import gnu.trove.set.hash.THashSet;
import java.io.File;
import java.io.IOException;
import java.nio.ByteOrder;
import java.sql.Array;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import org.apache.commons.lang3.Range;
import org.bridj.Pointer;
import org.hsqldb.jdbc.JDBCArrayBasic;
import org.hsqldb.jdbc.JDBCPool;
import org.jgrapht.alg.ConnectivityInspector;
import org.jgrapht.graph.DefaultEdge;
import org.jgrapht.graph.SimpleGraph;
import pal.tree.TreeParseException;

/**
 *
 * @author root
 */
public class HgtParConnCompBkp {

    private static JDBCPool HsqldbPool;
    public static final String HsqlDatabase = "jdbc:hsqldb:hsql://localhost:9005/proc_hom";
    public static final String AdminUser = "SA";
    public static final String AdminPass = "";

    static {


        timeInit();
        HsqldbPool = new JDBCPool();
        HsqldbPool.setDatabase(HsqlDatabase);
        HsqldbPool.setUser(AdminUser);
        HsqldbPool.setPassword(AdminPass);


        timeLap("initPool()");
    }
    public static int SqlInfin = 2147483647;
    public static long prev, now;
    public static float graph, frag, rap = 0.0f;
    List<Integer> ncbiSeqsArr;
    List<Integer> identArr;
    Pointer<Pointer<Integer>> from_ptr;
    Pointer<Pointer<Integer>> to_ptr;
    Pointer<Integer> id_ptr;
    Pointer<Pointer<Integer>> tst_ptr;
    //database
    String sql;
    Connection conn;
    Statement stmt;
    PreparedStatement pstmt;
    ResultSet rs;
    int nbFr;
    int rowNb;
    int geneId;
    int NcbiSeqsNb;
    int FragRowNbMax;
    int FragRowNb;
    int FragLenMax;
    int FragFloatNb;

    //constructor
    public HgtParConnCompBkp(Connection conn, int geneId) {

        this.conn = conn;
        this.geneId = geneId;
        //memory limits
        NcbiSeqsNb = 72;
        FragRowNbMax = 20000;
        FragRowNb = 0;
        FragLenMax = 256;
        FragFloatNb = FragLenMax / (8 * 4);
        System.out.println("FragFloatNb: " + FragFloatNb);

        timeLap("preallocate");
        from_ptr = Pointer.allocateInts(FragRowNbMax, FragFloatNb).order(ByteOrder.LITTLE_ENDIAN);
        to_ptr = Pointer.allocateInts(FragRowNbMax, FragFloatNb).order(ByteOrder.LITTLE_ENDIAN);
        id_ptr = Pointer.allocateInts(FragRowNbMax).order(ByteOrder.LITTLE_ENDIAN);
        timeLap("allocate");

        System.out.println("FragFloatNb: " + FragFloatNb);
    }

    public void updateGenesNcbiSeqsArr() throws SQLException {

        sql = "update genes gn "
                + "set gn.ncbi_seq_ids = ARRAY(select distinct gbs.NCBI_SEQ_ID "
                + "                            from GENE_BLO_SEQS gbs "
                + "                            where gbs.GENE_ID = gn.id "
                + "                            order by gbs.NCBI_SEQ_ID) "
                + "where gn.id = ? ";

        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, geneId);
        pstmt.executeUpdate();


    }

    public void updateFragmsArrs() {
    }

    public void release() {
        from_ptr.release();
        to_ptr.release();
        id_ptr.release();

    }

    public int[] decomposeStrList(String str) {
        int[] res = new int[FragFloatNb];
        //for(int i=0; i<res.length; i++) {
        //    res[i] = 0;
        //}

        //decompose
        String[] farr = str.split(",");

        for (String el : farr) {
            el = el.trim();
            int idx = ncbiSeqsArr.indexOf(Integer.parseInt(el));
            //System.out.println("el "+ el + " idx: " + idx);
            //find integer(32 bit) intNb at bitposition bitIdx
            int intNb = idx / 32;
            char bitIdx = (char) (idx % 32);
            //System.out.println("intNb: " + intNb + " bitIdx: " + bitIdx);
            //set bitIdx
            //res[intNb] |= (1 << bitIdx); //set bit 32
            //res[intNb] |= (1 << 32); //set bit 32
            res[intNb] |= (1 << bitIdx); //set bit 32
            //tst |= (1 << 3); //set bit 3


        }
        return res;

    }

    public void printBinStr(int[] arr) {
        StringBuffer sb = new StringBuffer();

        for (int el : arr) {
            String oneFl = String.format("%32s", Integer.toBinaryString(el)).replace(" ", "0");
            sb.append(oneFl);
            sb.append("-");

        }
        System.out.println(sb.toString());
        System.out.println("-----------");
    }

    public float concatJaccard(int[] a,
            int[] b,
            int[] c,
            int[] d) {

        float jacc = 0;


        int[] a_union_c = new int[FragFloatNb];
        int[] b_union_d = new int[FragFloatNb];
        int[] a_and_not_c = new int[FragFloatNb];
        int[] d_and_not_b = new int[FragFloatNb];
        int[] c_and_not_a = new int[FragFloatNb];
        int[] b_and_not_d = new int[FragFloatNb];

        int[] a_intersect_c = new int[FragFloatNb];
        int[] b_intersect_d = new int[FragFloatNb];

        int A_union_C = 0;
        int B_union_D = 0;
        int A_and_not_C = 0;
        int D_and_not_B = 0;
        int C_and_not_A = 0;
        int B_and_not_D = 0;

        int A_intersect_C = 0;
        int B_intersect_D = 0;

        for (int i = 0; i < FragFloatNb; i++) {
            a_union_c[i] = a[i] | c[i];
            A_union_C += Integer.bitCount(a_union_c[i]);
            b_union_d[i] = b[i] | d[i];
            B_union_D += Integer.bitCount(b_union_d[i]);

            a_and_not_c[i] = a[i] & (~c[i]);
            A_and_not_C += Integer.bitCount(a_and_not_c[i]);

            d_and_not_b[i] = d[i] & (~b[i]);
            D_and_not_B += Integer.bitCount(d_and_not_b[i]);

            c_and_not_a[i] = c[i] & (~a[i]);
            C_and_not_A += Integer.bitCount(c_and_not_a[i]);

            b_and_not_d[i] = b[i] & (~d[i]);
            B_and_not_D += Integer.bitCount(b_and_not_d[i]);

            a_intersect_c[i] = a[i] & c[i];
            A_intersect_C += Integer.bitCount(a_intersect_c[i]);

            b_intersect_d[i] = b[i] & d[i];
            B_intersect_D += Integer.bitCount(b_intersect_d[i]);

        }




        //System.out.println("a_union_c: ");
        //printBinStr(a_union_c);
        //System.out.println("A_union_C: " + A_union_C);

        //System.out.println("b_union_d: ");
        //printBinStr(b_union_d);
        //System.out.println("B_union_D: " + B_union_D);


        //System.out.println("d_and_not_b: ");
        //printBinStr(d_and_not_b);
        //System.out.println("D_and_not_B: " + D_and_not_B);        

        //System.out.println("c_and_not_a: ");
        //printBinStr(c_and_not_a);
        //System.out.println("C_and_not_A: " + C_and_not_A);        

        //System.out.println("b_and_not_d: ");
        //printBinStr(b_and_not_d);
        //System.out.println("B_and_not_D: " + B_and_not_D);        

        //System.out.println("a_intersect_c: ");
        //printBinStr(a_intersect_c);
        //System.out.println("A_intersect_C: " + A_intersect_C);        

        //System.out.println("b_intersect_d: ");
        //printBinStr(b_intersect_d);
        //System.out.println("B_intersect_D: " + B_intersect_D);        


        //THashSet<String> first = str_lin_arr(u_from, u_to);
        //THashSet<String> second = str_lin_arr(v_from, v_to);

        //THashSet<String> union = new THashSet<String>(first);
        //union.addAll(second);

        //THashSet<String> intersection = new THashSet<String>(first);
        //intersection.retainAll(second);



        //double inter_size = intersection.size();
        //double union_size = union.size();

        //union = first_arr | second_arr
        //double jacc = inter_size / union_size;
        int unionBits = (A_union_C * B_union_D) - (A_and_not_C * D_and_not_B) - (C_and_not_A * B_and_not_D);
        int intersectBits = A_intersect_C * B_intersect_D;
        jacc = (float) intersectBits / (float) unionBits;
        return jacc;

    }

    public void loadNcbiSeqsFromGenesArr() throws SQLException {
        sql = "select gn.NCBI_SEQ_IDS "
                + "from GENES gn "
                + "where gn.id = ?";

        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, geneId);


        rs = pstmt.executeQuery();

        rs.next();

        //Array dataSqlArr = rs.getArray(1);
        //Object[] objP = ( Object[] ) rs.getArray(1).getArray();

        //array as object
        Object objP = rs.getArray(1).getArray();
        //cast to integer array
        Integer[] integerArray = Arrays.copyOf((Object[]) objP, ((Object[]) objP).length, Integer[].class);
        //cast to integer list
        ncbiSeqsArr = Arrays.asList(integerArray);

        //System.out.println(integerArray.length);

        //for (Integer e: ncbiSeqsArr) {
        //    System.out.println("e: " + e);
        //}





        //Integer[] iP = (Integer[]) objP;


        /*
         ncbiSeqsArr = new ArrayList<Integer>()
        

         // default types defined in org.hsqldb.types.Type can be used
         //org.hsqldb.types.Type type = org.hsqldb.types.Type.SQL_VARCHAR_DEFAULT;
         org.hsqldb.types.Type type = org.hsqldb.types.Type.SQL_INTEGER;

         String[] data = yourList.toArray(new String[yourList.size()];
         connection.createArrayOf(typeName, data);
         * 
         JDBCArrayBasic array = new JDBCArrayBasic(data, type);
         pstmt.setArray(1, array);
        
        
        
         String ncbi_seq_id_str;
         int ncbi_seq_id;

         ncbiSeqsArr = new ArrayList<Integer>();
         //load ncbiSeqs
         while (rs.next()) {
         int pos = rs.getRow();
         ncbi_seq_id_str = rs.getString(1);

         ncbi_seq_id = Integer.parseInt(ncbi_seq_id_str);
         //System.out.println("ncbi_seq_id: " + ncbi_seq_id + " Pos: " + pos);
         //ncbiSeqs.set((pos-1),ncbi_seq_id);
         ncbiSeqsArr.add(ncbi_seq_id);
         //to_subtree.put(row, crs.getString(5));

         }


         */

    }

    public void loadNcbiSeqs() throws SQLException {
        sql = "select gbs.NCBI_SEQ_ID "
                + "from GENE_BLO_SEQS gbs "
                + "where gbs.GENE_ID = ? "
                + "order by gbs.NCBI_SEQ_ID";

        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, geneId);

        rs = pstmt.executeQuery();
        String ncbi_seq_id_str;
        int ncbi_seq_id;

        ncbiSeqsArr = new ArrayList<Integer>();
        //load ncbiSeqs
        while (rs.next()) {
            int pos = rs.getRow();
            ncbi_seq_id_str = rs.getString(1);

            ncbi_seq_id = Integer.parseInt(ncbi_seq_id_str);
            //System.out.println("ncbi_seq_id: " + ncbi_seq_id + " Pos: " + pos);
            //ncbiSeqs.set((pos-1),ncbi_seq_id);
            ncbiSeqsArr.add(ncbi_seq_id);
            //to_subtree.put(row, crs.getString(5));

        }



    }

    public void saveNcbiSeqs() throws SQLException {
        /*
         sql = "select gbs.NCBI_SEQ_ID "
         + "from GENE_BLO_SEQS gbs "
         + "where gbs.GENE_ID = ? "
         + "order by gbs.NCBI_SEQ_ID";

         pstmt = conn.prepareStatement(sql);
         pstmt.setInt(1, geneId);

         rs = pstmt.executeQuery();
         String ncbi_seq_id_str;
         int ncbi_seq_id;

         ncbiSeqsArr = new ArrayList<Integer>();
         //load ncbiSeqs
         while (rs.next()) {
         int pos = rs.getRow();
         ncbi_seq_id_str = rs.getString(1);

         ncbi_seq_id = Integer.parseInt(ncbi_seq_id_str);
         //System.out.println("ncbi_seq_id: " + ncbi_seq_id + " Pos: " + pos);
         //ncbiSeqs.set((pos-1),ncbi_seq_id);
         ncbiSeqsArr.add(ncbi_seq_id);
         //to_subtree.put(row, crs.getString(5));

         }


         */
    }

    public void loadFragments() throws SQLException {
        sql = "select id,"
                + "   fen_idx_min,"
                + "   fen_idx_max,"
                + "   from_subtree,"
                + "   to_subtree "
                + "from hgt_par_fragms "
                + "where gene_id = ? "
                + "order by id";

        pstmt = conn.prepareStatement(sql, ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
        pstmt.setInt(1, geneId);

        rs = pstmt.executeQuery();

        rs.last();
        nbFr = rs.getRow();
        System.out.println("fragments number: " + nbFr);
        rs.beforeFirst();



        //load ncbiSeqs
        while (rs.next()) {
            rowNb = rs.getRow() - 1;
            if (rowNb >= FragRowNbMax) {
                break;
            }
            //System.out.println("pos: " + rowNb);

            id_ptr.setIntAtIndex(rowNb, rs.getInt(1));

            int fen_idx_min = rs.getInt(2);
            int fen_idx_max = rs.getInt(3);
            String from_subtree = rs.getString(4);
            int[] from_subtree_arr = decomposeStrList(from_subtree);
            //printBinStr(from_subtree_arr);
            //set 
            from_ptr.get(rowNb).setInts(from_subtree_arr);

            //System.out.println();
            String to_subtree = rs.getString(5);
            int[] to_subtree_arr = decomposeStrList(to_subtree);
            to_ptr.get(rowNb).setInts(to_subtree_arr);

            //printBinStr(to_subtree_arr);

            //decompose



            //System.out.println("from subtree: " + from_subtree + " Pos: " + pos);


        }

        FragRowNb = rowNb;


        int[] x = from_ptr.get(0).getInts(FragFloatNb);

        //System.out.print("x: ");
        //printBinStr(x);
    }

    public void saveFragments() throws SQLException {
        sql = "update hgt_par_fragms "
                + "set from_arr,to_arr = (?, ?)"
                + "where id = ? ";



        pstmt = conn.prepareStatement(sql, ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);

        Object[] data = new Object[]{"one", "two"};

        // default types defined in org.hsqldb.types.Type can be used
        //org.hsqldb.types.Type type = org.hsqldb.types.Type.SQL_VARCHAR_DEFAULT;
        org.hsqldb.types.Type type = org.hsqldb.types.Type.SQL_INTEGER;


        JDBCArrayBasic array = new JDBCArrayBasic(data, type);
        pstmt.setArray(1, array);
        pstmt.setInt(2, 1000);
        pstmt.executeUpdate();


        // pstmt.setInt(1, geneId);

        //rs = pstmt.executeQuery();

        rs.last();
        nbFr = rs.getRow();
        System.out.println("fragments number: " + nbFr);
        rs.beforeFirst();



        //load ncbiSeqs
        while (rs.next()) {
            rowNb = rs.getRow() - 1;
            if (rowNb >= FragRowNbMax) {
                break;
            }
            //System.out.println("pos: " + rowNb);

            id_ptr.setIntAtIndex(rowNb, rs.getInt(1));

            int fen_idx_min = rs.getInt(2);
            int fen_idx_max = rs.getInt(3);
            String from_subtree = rs.getString(4);
            int[] from_subtree_arr = decomposeStrList(from_subtree);
            //printBinStr(from_subtree_arr);
            //set 
            from_ptr.get(rowNb).setInts(from_subtree_arr);

            //System.out.println();
            String to_subtree = rs.getString(5);
            int[] to_subtree_arr = decomposeStrList(to_subtree);
            to_ptr.get(rowNb).setInts(to_subtree_arr);

            //printBinStr(to_subtree_arr);

            //decompose



            //System.out.println("from subtree: " + from_subtree + " Pos: " + pos);


        }

        FragRowNb = rowNb;


        int[] x = from_ptr.get(0).getInts(FragFloatNb);

        //System.out.print("x: ");
        //printBinStr(x);
    }

    public void constructGraphJava(double epsilon_sim_frag,
            int epsilon_dist_frag)
            throws java.sql.SQLException {




        timeLap("Start");

        //test storage in native pointer
        //int[] tstArr = new int[FragLenMax];
        //tstArr = from_ptr.get(2).getInts();
        //System.out.println("testing:");
        //printBinStr(from_ptr.getInts());


        SimpleGraph gr = new SimpleGraph(DefaultEdge.class);

        for (int i = 1; i <= FragRowNb; i++) {
            gr.addVertex(i);
        }

        //enumerate only once each edge
        //asymetric

        System.out.println("FragRowNb: " + FragRowNb);
        for (int u = 1; u < FragRowNb; u++) {

            for (int v = u + 1; v < FragRowNb; v++) {

                //System.out.println("u: " + u + "v: " + v);

                //add edges

                int[] u_from = from_ptr.get(u).getInts(FragFloatNb);
                int[] u_to = to_ptr.get(u).getInts(FragFloatNb);


                int[] v_from = from_ptr.get(v).getInts(FragFloatNb);
                int[] v_to = to_ptr.get(v).getInts(FragFloatNb);


                //System.out.println("u_from : " + u_from + "u_to: " + u_to);

                //calculate Jaccard similarity
                double jac_dir = concatJaccard(u_from, u_to, v_from, v_to);
                double jac_inv = concatJaccard(u_from, u_to, v_to, v_from);

                if ((jac_dir != 0) || (jac_inv != 0)) {
                    //System.out.println("u: " + id.get(u) + " v: " + id.get(v) + " src_from: " + u_from + " src_to: " + u_to + 
                    //                  " jac_dir: " + jac_dir + " jac_inv: " + jac_inv);
                } else {
                    //System.out.println("no");
                }

                if ((Math.max(jac_dir, jac_inv) > epsilon_sim_frag)) {
                    //System.out.println("ok");
                    gr.addEdge(u, v);

                }










            }
        }


        int nbEdges = gr.edgeSet().size();
        int nbVertices = gr.vertexSet().size();

        timeLap("Graph" + " nbEdges: " + nbEdges + " nbVertices: " + nbVertices);

        ConnectivityInspector ci = new ConnectivityInspector(gr);

        List cs = ci.connectedSets();


        //System.out.println("#2 for");
        for (int i = 0; i < cs.size(); i++) {
            //System.out.println(cs.get(i));
        }


        timeLap("Connectivity");


        //create contins 
        //HgtParContin.destroy_all
        //Statement stmt = conn.createStatement();
        //stmt.execute("delete from hgt_par_contins");
        //stmt.close();


        //insert contin

        pstmt = conn.prepareStatement("insert into hgt_par_contins "
                + "(gene_id) "
                + "values "
                + "(?)", new String[]{"ID"});

        PreparedStatement update_fragm_contin_id_pstmt =
                conn.prepareStatement("update hgt_par_fragms "
                + "set hgt_par_contin_id = ? "
                + "where id = ? ");

        //cs.each insert contin
        for (int i = 0; i < cs.size(); i++) {

            pstmt.setInt(1, geneId);
            pstmt.execute();

            rs = pstmt.getGeneratedKeys();
            rs.next();
            int contin_id = rs.getInt(1);
            //System.out.println("contin_id: " + contin_id);


            HashSet el = (HashSet) cs.get(i);
            Iterator it = el.iterator();

            while (it.hasNext()) {
                Integer id_key = (Integer) it.next();

                //we will update the contin_id
                //indexes are one based in sql
                int fragm_id = id_ptr.get(id_key - 1);


                update_fragm_contin_id_pstmt.setInt(1, contin_id);
                update_fragm_contin_id_pstmt.setInt(2, fragm_id);
                update_fragm_contin_id_pstmt.addBatch();
                //update_fragm_contin_id_pstmt.executeUpdate();

                //System.out.println("fragm_id: " + fragm_id + "id_key: " + id_key);
            }


            int[] numUpdates = update_fragm_contin_id_pstmt.executeBatch();
            //System.out.println("numUpdates.length: " + numUpdates.length);


        }
        conn.commit();


        timeLap("Update data");



    }

    public void realignFragmsInContinsTransfers() {
        /*
         contins = @gene.hgt_par_contins.order("id")
         contins.each { |con|
    
   
         frgms = con.hgt_par_fragms.order("fen_idx_min ASC, fen_idx_max ASC")

         #first one is reference
         frgms[0].contin_realign_status = "Reference"
         #check for inversions
         (0..frgms.length-2).each { |i|
         u = frgms[i]
         v = frgms[i+1] 

         #jac_dir =  jaccard_sim_coef(u.from_subtree, u.to_subtree, v.from_subtree, v.to_subtree)
         jac_dir =  JavaHgtPar.jaccard_sim_coef(u.from_subtree, u.to_subtree, v.from_subtree, v.to_subtree)
         #jac_inv =  jaccard_sim_coef(u.from_subtree, u.to_subtree, v.to_subtree, v.from_subtree)
         jac_inv =  JavaHgtPar.jaccard_sim_coef(u.from_subtree, u.to_subtree, v.to_subtree, v.from_subtree)

         if jac_inv > jac_dir 
         #swap from and to subfields
         v.from_subtree, v.to_subtree =  v.to_subtree, v.from_subtree
         v.from_cnt, v.to_cnt = v.to_cnt, v.from_cnt
         v.bs_direct, v.bs_inverse = v.bs_inverse, v.bs_direct
         #mention change
         v.contin_realign_status = "Realigned"

         else
         #mention original
         v.contin_realign_status = "Original"
         end
     
     
         #puts "u.fen_idx_min: #{u.fen_idx_min}, jac_dir: #{jac_dir}, jac_inv: #{jac_inv}"
      

         }    

 
         frgms.each { |fr|

         #save changes on fragments of same contin
         fr.save
         #next unless test_pair.include? [fr.from_subtree, fr.to_subtree]

         #puts "#{fr.hgt_par_contin_id}, #{fr.fen_idx_min}, #{fr.fen_idx_max}, #{fr.from_subtree}, #{fr.to_subtree}, #{fr.from_cnt}, #{fr.to_cnt}, #{fr.bs_val}, #{fr.bs_direct}, #{fr.bs_inverse}, #{fr.contin_realign_status}"
         #fr.contin_realign_status = "Original"
         #fr.save

         }

         #calculate contins aggregate values
         con.fen_idx_min = frgms.collect{|e| e.fen_idx_min }.min
         con.fen_idx_max = frgms.collect{|e| e.fen_idx_max }.max
         con.length = con.fen_idx_max - con.fen_idx_min
         #bootstrap average values 
         #useless for maximum
         #bs_direct_a = frgms.collect{|e| e.bs_direct }
         #bs_inverse_a = frgms.collect{|e| e.bs_inverse }
         #average
         #con.bs_direct = bs_direct_a.sum.to_f / bs_direct_a.size.to_f
         #con.bs_inverse = bs_inverse_a.sum.to_f / bs_inverse_a.size.to_f
         #replaced by maximum
         con.bs_direct = frgms.collect{|e| e.bs_direct }.max
         con.bs_inverse = frgms.collect{|e| e.bs_inverse }.max
         #
         con.bs_val = con.bs_direct + con.bs_inverse
         #save contin
         con.save

         #calculate individual transfer components
         transfers_count = frgms.collect{|e| str_lin_arr(e.from_subtree, e.to_subtree)  }.flatten(1).size.to_f
         transfers_h =  frgms.inject({}) { |h,e| h[ e.id ]= str_lin_arr(e.from_subtree, e.to_subtree); h}
         #

         #puts "contin id: #{con.id}, #{con.fen_idx_min}, #{con.fen_idx_max}, #{con.length}, #{con.bs_val}, #{con.bs_direct}, #{con.bs_inverse}"
         #puts "transfers_count: #{transfers_count}"
         #puts "transfers_h: #{transfers_h.inspect}"

         #if contin is worthy
         #insert transfers
         if con.bs_val >= @thres
         #now check direction
         transfers_h.each_pair { |k,v| 
         #k is hgt_par_fragm_id
         #v is array [source,dest]
         v.each { |tr|
         trsf = HgtParTransfer.new
         #check direction
         if con.bs_direct >= con.bs_inverse
         #direct transfer
         trsf.ncbi_seq_source_id = tr[0].to_i
         trsf.ncbi_seq_dest_id = tr[1].to_i
         else
         #inverse transfer
         trsf.ncbi_seq_source_id = tr[1].to_i
         trsf.ncbi_seq_dest_id = tr[0].to_i
         end

         trsf.weight = 1 / transfers_count
         trsf.hgt_par_fragm_id = k
         trsf.hgt_par_contin = con
         trsf.save
          
         } #v
         
            
         } #transfers_h



         end #end if con.bs_val 



         }
         */
    }

    public static void timeInit() {
        prev = System.nanoTime();

    }

    public static void timeLap(String message) {
        now = System.nanoTime();
        float tm = (float) (now - prev) / 100000000;

        DecimalFormat df = new DecimalFormat("0.0000");

        //String tmStr = String.format("%.5g%n", tm);
        String tmStr = df.format(tm);

        System.out.println("              " + message + ": " + tmStr + " sec");
        prev = System.nanoTime();

    }

    private static int roundUp(int groupSize, int globalSize) {
        int r = globalSize % groupSize;
        if (r == 0) {
            return globalSize;
        } else {
            return globalSize + groupSize - r;
        }
    }

    public static void test1() throws SQLException {
        //gene id: 190 Graph nbEdges: 403567 nbVertices: 10406: 646.4194 sec total time: 1 minute 6 seconds

        //gene id: 172 Graph nbEdges: 98 nbVertices: 155: 1.1308 sec


        timeInit();

        HgtParConnCompBkp hp = new HgtParConnCompBkp(HsqldbPool.getConnection(), 190);

        timeLap("Constructor");


        //hp.loadNcbiSeqs();
        hp.updateGenesNcbiSeqsArr();
        hp.loadNcbiSeqsFromGenesArr();
        timeLap("loadNcbiSeqs");

        //fragments need ncbiSeqs
        hp.loadFragments();
        timeLap("loadFragments()");

        hp.constructGraphJava(0.75, SqlInfin);
        //timeLap("constructGraphJava(0.75, SqlInfin)");

        hp.release();
        timeLap("release");

    }

    public static void test2() throws SQLException {

        timeInit();

        HgtParConnCompBkp hp = new HgtParConnCompBkp(HsqldbPool.getConnection(), 172);

        timeLap("Constructor");

        hp.updateGenesNcbiSeqsArr();

        hp.loadNcbiSeqsFromGenesArr();

    }

    public static void main(String[] args) throws TreeParseException, IOException, SQLException {

        test1();








    }
}
