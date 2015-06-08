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

//OpenCL imports
import com.nativelibs4java.opencl.*;
import com.nativelibs4java.opencl.CLMem.Usage;
import com.nativelibs4java.opencl.util.*;
import com.nativelibs4java.util.*;
import java.io.File;
import org.bridj.Pointer;
import static org.bridj.Pointer.*;
import static java.lang.Math.*;
import java.io.IOException;
import java.nio.ByteOrder;
import com.nativelibs4java.opencl.CLEvent;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.apache.commons.beanutils.BasicDynaClass;
import org.apache.commons.beanutils.DynaBean;
import org.apache.commons.beanutils.DynaClass;
import org.apache.commons.beanutils.DynaProperty;
import org.apache.commons.beanutils.RowSetDynaClass;

/**
 *
 * @author root
 */
public class HgtParConnCompBest {

    private static JDBCPool HsqldbPool;
    public static final String HsqlDatabase = "jdbc:hsqldb:hsql://localhost:9005/proc_hom";
    public static final String AdminUser = "SA";
    public static final String AdminPass = "";

    public static void initHsqldbPool() {

        timeInit();
        HsqldbPool = new JDBCPool();
        HsqldbPool.setDatabase(HsqlDatabase);
        HsqldbPool.setUser(AdminUser);
        HsqldbPool.setPassword(AdminPass);


        timeLap("initPool()");

    }
    //OpenCL
    static CLPlatform[] platforms;
    static CLPlatform platform;
    static CLDevice[] devices;
    static CLDevice device;
    static CLContext context;
    static CLQueue queue;
    static ByteOrder byteOrder;
    static CLProgram program;
    static int[] globalSizes,
            localSizes;
    static int globalWorkSize,
            localWorkSize;

    public static void initJavacl() {
        //CLContext context = JavaCL.createBestContext();
        platforms = JavaCL.listPlatforms();
        platform = platforms[0];
        //platform = platforms[1];

        System.out.println("Platform: " + platform.getName());
        //System.out.println("Platforms[1]"+ platforms[1].getName());

        devices = platform.listGPUDevices(true);
        //devices = platform.listCPUDevices(true);
        device = devices[0];
        System.out.println("Device: " + device.toString());


        context = JavaCL.createContext(null, device);



        queue = context.createDefaultQueue();
        byteOrder = context.getByteOrder();

        System.out.println("ByteOrder: " + byteOrder.toString());


    }
    
    public static void staticCleanupJavacl() {
        queue.release();
        context.release();
        device.release();
        platform.release();
    }
    

    public void cleanupJavacl() {

       System.out.println("..............in cleanupJavacl");


        from_arr_ptr.release();
        to_arr_ptr.release();
        id_ptr.release();
        //added
        //tst_ptr.release();
        

        edge_list_from_ptr.release();
        edge_list_to_ptr.release();
        edge_nb_ptr.release();
        edge_nb_tested_ptr.release();
        frgm_parent_ptr.release();
        frgm_source_ptr.release();
        frgm_status_ptr.release();
        frgm_contin_id_ptr.release();
        frgm_invalid_ptr.release();
        
        Runtime r = Runtime.getRuntime();
        r.gc();

    }
    
    
    public static int SqlInfin = 2147483647;
    public static long prev, now;
    public static float graph, frag, rap = 0.0f;
    List<Integer> ncbiSeqsArr;
    List<Integer> identArr;
    //Fragments
    int FragRowNbMax;
    int FragRowNb;
    int FragLenMax;
    int FragFloatNb;
    //real number of rows
    int FragRowNbAvail;
    Pointer<Pointer<Integer>> from_arr_ptr;
    CLBuffer<Integer> from_arr_buf;
    List<String> from_subtree_lst;
    List<Integer> from_cnt_lst;
    Pointer<Pointer<Integer>> to_arr_ptr;
    CLBuffer<Integer> to_arr_buf;
    List<String> to_subtree_lst;
    List<Integer> to_cnt_lst;
    Pointer<Integer> id_ptr;
    List<Float> bs_direct_lst;
    List<Float> bs_inverse_lst;
    CLEvent fillEvt;
    CLEvent realignEvt;
    CLEvent realignStatusEvt;
    Pointer<Pointer<Integer>> tst_ptr;
    //Edges
    int edgeNbMax; // theoretic maximum
    int edgeNbAlloc; //allocated padded
    int edgeNb; //real obtained
    int edgeNbTested; // n² tested
    Pointer<Integer> edge_list_from_ptr;
    Pointer<Integer> edge_list_to_ptr;
    Pointer<Integer> edge_nb_ptr;
    Pointer<Integer> edge_nb_tested_ptr;
    //ConnectedComponents
    Pointer<Integer> frgm_parent_ptr;
    //PointerJumping
    Pointer<Integer> frgm_source_ptr;
    CLBuffer<Integer> frgm_source_buf;
    //
    Pointer<Integer> frgm_status_ptr;
    CLBuffer<Integer> frgm_status_buf;
    //store contin_ids from database
    Pointer<Integer> frgm_contin_id_ptr;
    //
    Map<Integer, Integer> contin_best_frgm_map;
    Map<Integer, Float> contin_best_val_map;
    Pointer<Integer> frgm_invalid_ptr;
    //database
    String sql;
    Connection conn;
    Statement stmt;
    PreparedStatement pstmt;
    ResultSet rs;
    int rowNb;
    int geneId;
    int NcbiSeqsNb;
    //
    public float thres;

    //constructor
    public HgtParConnCompBest(Connection conn, int geneId, float thres) {

        this.conn = conn;
        this.geneId = geneId;
        this.thres = thres;
        //memory limits
        NcbiSeqsNb = 72;
        //for debugging limit number of elements
        FragRowNbMax = 20000;
        FragRowNb = 0;
        FragLenMax = 256;
        FragFloatNb = FragLenMax / (8 * 4);
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
        from_arr_ptr.release();
        to_arr_ptr.release();
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
                + "   to_subtree,"
                + "   from_cnt,"
                + "   to_cnt,"
                + "   bs_direct, "
                + "   bs_inverse "
                + "from hgt_par_fragms "
                + "where gene_id = ? "
                + "order by id";

        pstmt = conn.prepareStatement(sql, ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
        pstmt.setInt(1, geneId);

        rs = pstmt.executeQuery();

        rs.last();
        FragRowNbAvail = rs.getRow();
        System.out.println("available fragments number: " + FragRowNbAvail);
        rs.beforeFirst();

        //now we can allocate
        //int localWorkSize = min(device.getMaxWorkGroupSize(), 256);  // Local work size dimensions
        localWorkSize = 16;  // Local work size dimensions
        globalWorkSize = roundUp(localWorkSize, FragRowNbAvail);   // rounded up to the nearest multiple of the localWorkSize

        System.out.println("globalWorkSize: " + globalWorkSize);


        timeLap("preallocate");
        from_arr_ptr = Pointer.allocateInts(globalWorkSize, FragFloatNb).order(byteOrder);
        from_subtree_lst = new ArrayList<String>();
        from_cnt_lst = new ArrayList<Integer>();

        to_arr_ptr = Pointer.allocateInts(globalWorkSize, FragFloatNb).order(byteOrder);
        to_subtree_lst = new ArrayList<String>();
        to_cnt_lst = new ArrayList<Integer>();

        id_ptr = Pointer.allocateInts(globalWorkSize).order(byteOrder);

        bs_direct_lst = new ArrayList<Float>();
        bs_inverse_lst = new ArrayList<Float>();

        timeLap("allocate");




        //load ncbiSeqs
        while (rs.next()) {
            rowNb = rs.getRow() - 1;
            if (rowNb >= FragRowNbMax - 1) {
                break;
            }
            //System.out.println("pos: " + rowNb);

            id_ptr.setIntAtIndex(rowNb, rs.getInt(1));

            int fen_idx_min = rs.getInt(2);
            int fen_idx_max = rs.getInt(3);


            from_cnt_lst.add(rs.getInt("from_cnt"));
            to_cnt_lst.add(rs.getInt("to_cnt"));

            String from_subtree = rs.getString("from_subtree");
            from_subtree_lst.add(from_subtree);
            int[] from_subtree_arr = decomposeStrList(from_subtree);
            //printBinStr(from_subtree_arr);
            from_arr_ptr.get(rowNb).setInts(from_subtree_arr);

            String to_subtree = rs.getString("to_subtree");
            to_subtree_lst.add(to_subtree);
            int[] to_subtree_arr = decomposeStrList(to_subtree);
            to_arr_ptr.get(rowNb).setInts(to_subtree_arr);

            bs_direct_lst.add(rs.getFloat("bs_direct"));
            bs_inverse_lst.add(rs.getFloat("bs_inverse"));
            //printBinStr(to_subtree_arr);

            //decompose



            //System.out.println("from subtree: " + from_subtree + " Pos: " + pos);


        }

        //update real row number to 
        FragRowNb = rowNb + 1;
        System.out.println("final FragRowNb: " + FragRowNb);

        int[] x = from_arr_ptr.get(0).getInts(FragFloatNb);

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
        FragRowNbAvail = rs.getRow();
        System.out.println("fragments number: " + FragRowNbAvail);
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
            from_arr_ptr.get(rowNb).setInts(from_subtree_arr);

            //System.out.println();
            String to_subtree = rs.getString(5);
            int[] to_subtree_arr = decomposeStrList(to_subtree);
            to_arr_ptr.get(rowNb).setInts(to_subtree_arr);

            //printBinStr(to_subtree_arr);

            //decompose



            //System.out.println("from subtree: " + from_subtree + " Pos: " + pos);


        }

        FragRowNb = rowNb;


        int[] x = from_arr_ptr.get(0).getInts(FragFloatNb);

        //System.out.print("x: ");
        //printBinStr(x);
    }

    public void constructGraphOpenCl(double epsilon_sim_frag,
            int epsilon_dist_frag)
            throws java.sql.SQLException, IOException {

        System.out.println("entering constructGraphOpenCl...");


        int n = FragRowNb;



        // Create OpenCL input buffers (using the native memory pointers aPtr and bPtr) :
        from_arr_buf = context.createIntBuffer(Usage.Input, from_arr_ptr.as(Integer.class));
        to_arr_buf = context.createIntBuffer(Usage.Input, to_arr_ptr.as(Integer.class));


        // Create an OpenCL output buffer :
        //CLBuffer<Float> out = context.createFloatBuffer(Usage.Output, n);

        // Read the program sources and compile them :
        //
        String src = IOUtils.readText(new File("/root/devel/db_srv/sp_projects/proc-hom-sp/src/Connected4ComponentsKernels.cl"));
        program = context.createProgram(src);
        program.build();

        System.out.println("compiled.......");



        // Get and call the kernel :
        CLKernel detectEdgesKernel = program.createKernel("detect_4edges");

        edge_nb_tested_ptr = Pointer.allocateInt().order(byteOrder);
        edge_nb_tested_ptr.set(0);
        CLBuffer<Integer> edge_nb_tested_buf = context.createIntBuffer(Usage.InputOutput, edge_nb_tested_ptr);

        edge_nb_ptr = Pointer.allocateInt().order(byteOrder);
        edge_nb_ptr.set(0);
        CLBuffer<Integer> edge_nb_buf = context.createIntBuffer(Usage.InputOutput, edge_nb_ptr);

        //sparse matrix
        edgeNbMax = FragRowNb * 1000;
        edgeNbAlloc = edgeNbMax;

        edge_list_from_ptr = Pointer.allocateInts(edgeNbAlloc).order(byteOrder);
        CLBuffer<Integer> edge_list_from_buf = context.createIntBuffer(Usage.InputOutput, edge_list_from_ptr);

        edge_list_to_ptr = Pointer.allocateInts(edgeNbAlloc).order(byteOrder);
        CLBuffer<Integer> edge_list_to_buf = context.createIntBuffer(Usage.InputOutput, edge_list_to_ptr);

        detectEdgesKernel.setArgs(from_arr_buf, to_arr_buf, edge_nb_tested_buf, edge_nb_buf, n, edge_list_from_buf, edge_list_to_buf);

        globalSizes = new int[]{globalWorkSize, globalWorkSize, 1};
        localSizes = new int[]{localWorkSize, localWorkSize, 1};

        fillEvt = detectEdgesKernel.enqueueNDRange(queue, globalSizes, localSizes, null);

        //CLEvent addEvt = addFloatsKernel.enqueueNDRange(queue, globalSizes,fillEvt);

        //Pointer<Float> outPtr = out.read(queue, addEvt); // blocks until add_floats finished
        edge_nb_tested_ptr = edge_nb_tested_buf.read(queue, fillEvt);
        edge_nb_ptr = edge_nb_buf.read(queue, fillEvt);
        edge_list_from_ptr = edge_list_from_buf.read(queue, fillEvt);
        edge_list_to_ptr = edge_list_to_buf.read(queue, fillEvt);

        queue.finish();

        System.out.println("edge_nb_tested_ptr: " + edge_nb_tested_ptr.get());
        System.out.println("edge_nb_ptr: " + edge_nb_ptr.get());


        // Print the first 10 output values :
        // for (int i = 0; i < 10 && i < n; i++) {
        //    System.out.println("outs[" + i + "] = " + outPtr.get(i));
        //}

        // Print the first 10 output values :


        //int id = 2;
        //for (int x = 0; x < 8; x++) {
        //    int j = id * 8 + x;

        //  System.out.println("id: " + id + "x: " + x + ": " + from_arr_ptr.get(id).getIntAtIndex(x));
        //}



        //globalSizes = new int[]{globalWorkSize,1,1};
        //localSizes = new int[]{localWorkSize,1,1};




    }

    public void connectComponOpenCl() {

        //alocate parents 
        frgm_parent_ptr = Pointer.allocateInts(FragRowNb).order(byteOrder);
        //Initialize Parent[i] = i;
        for (int i = 0; i < FragRowNb; i++) {
            frgm_parent_ptr.setIntAtIndex(i, i);
        }

        //for each edge (u; v)
        for (int i = 0; i < edge_nb_ptr.get(); i++) {
            //      System.out.println("edge " + i + " from " + edge_list_from_ptr.get(i) + " to " + edge_list_to_ptr.get(i) 
            //             + " (" + id_ptr.get(edge_list_from_ptr.get(i)) 
            //            + "," + id_ptr.get(edge_list_to_ptr.get(i)) + ")");
            int U = edge_list_from_ptr.get(i);
            int V = edge_list_to_ptr.get(i);

            int parU = frgm_parent_ptr.get(U);
            int parV = frgm_parent_ptr.get(V);

            if (parU != parV) {
                int minPar = Math.min(parU, parV);
                int maxPar = Math.max(parU, parV);
                frgm_parent_ptr.set(maxPar, minPar);
            }


        }


        //Multilevel pointer jumping();
        /* forall i ∈ 1 : n do
         S[i] ← P[i]
         enddo
         */
        //alocate sources = parents 
        frgm_source_ptr = Pointer.allocateInts(FragRowNb).order(byteOrder);
        //Initialize Parent[i] = i;
        for (int i = 0; i < FragRowNb; i++) {
            frgm_source_ptr.set(i, frgm_parent_ptr.get(i));
        }
        /*
         for k = 1 to lg n do
         forall i ∈ 1 : n do
         S[i] ← S[S[i]]
         enddo
         enddo
         */
        for (int k = 0; k < Math.log(FragRowNb) / Math.log(2); k++) {
            //System.out.println("FragRowNb: " +FragRowNb + " k: " + k);
            for (int i = 0; i < FragRowNb; i++) {
                frgm_source_ptr.set(i, frgm_source_ptr.get(frgm_source_ptr.get(i)));
            }
        }


        //for (int i = 0; i < FragRowNb; i++) {
        // System.out.println("i " + i + " frgm_source_ptr: " + frgm_source_ptr.get(i));

        //}

        frgm_source_buf = context.createIntBuffer(Usage.InputOutput, frgm_source_ptr);

        frgm_status_ptr = Pointer.allocateInts(FragRowNb).order(byteOrder);
        frgm_status_buf = context.createIntBuffer(Usage.InputOutput, frgm_status_ptr);

        // Get and call the kernel :
        CLKernel realignFragmsKernel = program.createKernel("realign_4framgs");

        realignFragmsKernel.setArgs(from_arr_buf, to_arr_buf, FragRowNb, frgm_source_buf, frgm_status_buf);

        localWorkSize = 16;  // Local work size dimensions
        globalWorkSize = roundUp(localWorkSize, FragRowNb);   // rounded up to the nearest multiple of the localWorkSize

        System.out.println("globalWorkSize: " + globalWorkSize);

        globalSizes = new int[]{globalWorkSize, 1, 1};
        localSizes = new int[]{localWorkSize, 1, 1};

        realignEvt = realignFragmsKernel.enqueueNDRange(queue, globalSizes, localSizes, null);
        //recuperate status
        frgm_status_ptr = frgm_status_buf.read(queue, realignEvt);
        //show status
        //System.out.println("show status....., FragRowNb: " + FragRowNb);
        //for (int i = 0; i < FragRowNb; i++) {
        //System.out.println("i " + i + " frgm_status_ptr: " + frgm_status_ptr.get(i));
        //}



        queue.finish();



    }

    public void insertContinsUpdateFragms() throws SQLException {

        contin_best_frgm_map = new HashMap<Integer, Integer>();
        contin_best_val_map = new HashMap<Integer, Float>();

        //create contins
        //allocate contin ids
        frgm_contin_id_ptr = Pointer.allocateInts(FragRowNb).order(byteOrder);
        //allocate every fragment status
        frgm_invalid_ptr = Pointer.allocateInts(FragRowNb).order(byteOrder);

        pstmt = conn.prepareStatement("insert into hgt_par_contins "
                + "(gene_id) "
                + "values "
                + "(?)", new String[]{"ID"});

        int contin_id = 0;
        String contin_realign_status = "";

        String from_subtree = "";
        String to_subtree = "";
        int from_cnt = 0;
        int to_cnt = 0;
        float bs_direct = 0;
        float bs_inverse = 0;

        //
        for (int i = 0; i < FragRowNb; i++) {
            //System.out.println("i " + i + " frgm_status_ptr: " + frgm_status_ptr.get(i));
            //if root 
            //insert a contin and recuperate its id at same position
            if (frgm_status_ptr.get(i) == 1) {
                pstmt.setInt(1, geneId);
                pstmt.execute();

                rs = pstmt.getGeneratedKeys();
                rs.next();
                contin_id = rs.getInt(1);
                //
                frgm_contin_id_ptr.set(i, contin_id);
                //intialize contin best fragm 
                contin_best_frgm_map.put(contin_id, 0);
                contin_best_val_map.put(contin_id, 0.0F);

            }

        }
        //update fragms and realign
        PreparedStatement update_fragm_contin_id_pstmt =
                conn.prepareStatement("update hgt_par_fragms "
                + "set hgt_par_contin_id = ?, "
                + "    contin_realign_status = ?,"
                + "    from_subtree = ?, "
                + "    to_subtree = ?,"
                + "    from_cnt = ?,"
                + "    to_cnt = ?,"
                + "    bs_direct = ?,"
                + "    bs_inverse = ? "
                + "where id = ? ");

        //realign
        for (int i = 0; i < FragRowNb; i++) {

////////////////////////////////////////////////

            int fragm_id = id_ptr.get(i);
            int source_id = frgm_source_ptr.get(i);
            contin_id = frgm_contin_id_ptr.get(source_id);
            //update contin of fragment, usefull for reduction later
            frgm_contin_id_ptr.set(i, contin_id);

            if (frgm_status_ptr.get(i) == 1) {
                contin_realign_status = "Reference";
                //normal order
                from_subtree = from_subtree_lst.get(i);
                to_subtree = to_subtree_lst.get(i);
                from_cnt = from_cnt_lst.get(i);
                to_cnt = to_cnt_lst.get(i);
                bs_direct = bs_direct_lst.get(i);
                bs_inverse = bs_inverse_lst.get(i);


            } else if (frgm_status_ptr.get(i) == 2) {
                contin_realign_status = "Original";
                //normal order
                from_subtree = from_subtree_lst.get(i);
                to_subtree = to_subtree_lst.get(i);
                from_cnt = from_cnt_lst.get(i);
                to_cnt = to_cnt_lst.get(i);
                bs_direct = bs_direct_lst.get(i);
                bs_inverse = bs_inverse_lst.get(i);


            } else if (frgm_status_ptr.get(i) == 3) {
                contin_realign_status = "Realigned";
                //reverse order
                from_subtree = to_subtree_lst.get(i);
                to_subtree = from_subtree_lst.get(i);
                from_cnt = to_cnt_lst.get(i);
                to_cnt = from_cnt_lst.get(i);
                bs_direct = bs_inverse_lst.get(i);
                bs_inverse = bs_direct_lst.get(i);

            }




            update_fragm_contin_id_pstmt.setInt(1, contin_id);

            update_fragm_contin_id_pstmt.setString(2, contin_realign_status);
            update_fragm_contin_id_pstmt.setString(3, from_subtree);
            update_fragm_contin_id_pstmt.setString(4, to_subtree);
            update_fragm_contin_id_pstmt.setInt(5, from_cnt);
            update_fragm_contin_id_pstmt.setInt(6, to_cnt);
            update_fragm_contin_id_pstmt.setFloat(7, bs_direct);
            update_fragm_contin_id_pstmt.setFloat(8, bs_inverse);

            update_fragm_contin_id_pstmt.setInt(9, fragm_id);


            update_fragm_contin_id_pstmt.addBatch();
            //System.out.println("fragm_id: " + fragm_id + " contin_id: " + contin_id);

            //update best fragm match for each contin_id
            float bs_val = bs_direct + bs_inverse;

            if (bs_val > contin_best_val_map.get(contin_id)) {
                contin_best_val_map.put(contin_id, bs_val);
                contin_best_frgm_map.put(contin_id, fragm_id);
            }


        }


        int[] numUpdates = update_fragm_contin_id_pstmt.executeBatch();
        System.out.println("numUpdates.length: " + numUpdates.length);

        conn.commit();

        int cv_len = contin_best_val_map.size();
        System.out.println("cv_len: " + cv_len);

        //debug

        //for (int i : contin_best_frgm_map.keySet()) {
        //    System.out.println("i: " + i + " cval: " + contin_best_val_map.get(i) + " cfragm: " + contin_best_frgm_map.get(i));

        //}

        //validate rows
        for (int i = 0; i < FragRowNb; i++) {
            contin_id = frgm_contin_id_ptr.get(i);
            int fragm_id = id_ptr.get(i);
            //System.out.println("contin_id: " + contin_id + " fragm_id: " + fragm_id);

            int best_frgm = contin_best_frgm_map.get(contin_id);
            //if this is the best row for its contin_id

            if (fragm_id == contin_best_frgm_map.get(contin_id)) {
                //flag fragm as valid
                frgm_invalid_ptr.set(i, 0);
                //
                //System.out.println("1: contin_id: " + contin_id + " fragm_id: " + fragm_id);
            } else {
                //set as invalid
                frgm_invalid_ptr.set(i, 1);
                //System.out.println("0: contin_id: " + contin_id + " fragm_id: " + fragm_id);
            }

        }

        //new code added for timing optimization
        
        //update fragms and realign
        PreparedStatement delete_invalid_fragm_pstmt =
                conn.prepareStatement("delete from hgt_par_fragms "
                + "where id = ? ");

        //debug validate rows
        for (int i = 0; i < FragRowNb; i++) {
            contin_id = frgm_contin_id_ptr.get(i);
            int fragm_id = id_ptr.get(i);
            int invalid = frgm_invalid_ptr.get(i);

            //System.out.println("contin_id: " + contin_id + " fragm_id: " + fragm_id + " invalid: " + invalid);

            if (invalid == 1) {
                delete_invalid_fragm_pstmt.setInt(1, fragm_id);
                delete_invalid_fragm_pstmt.addBatch();
            }

        }
        //inactivated
        
        try {
            numUpdates = delete_invalid_fragm_pstmt.executeBatch();
        } catch (SQLException ex) {
            //Logger.getLogger(HgtParConnCompBest.class.getName()).log(Level.SEVERE, null, ex);
        }
        
        
        System.out.println("numUpdates.length: " + numUpdates.length);
        
        conn.commit();



    }

    public void updateContins() throws SQLException {
        sql = "update HGT_PAR_CONTINS hpc "
                + "set (hpc.FEN_IDX_MIN, "
                + "     hpc.FEN_IDX_MAX, "
                + "     hpc.LENGTH, "
                + "     hpc.BS_DIRECT, "
                + "     hpc.BS_INVERSE, "
                + "     hpc.BS_VAL) = (select min(hpf.FEN_IDX_MIN), "
                + "                           max(hpf.FEN_IDX_MAX), "
                + "                           max(hpf.FEN_IDX_MAX)-min(hpf.FEN_IDX_MIN), "
                + "                           max(hpf.BS_DIRECT), "
                + "                           max(hpf.BS_INVERSE), "
                //+ "                           max(hpf.BS_DIRECT)+max(hpf.BS_INVERSE) "
                + "                           max(hpf.BS_VAL) "
                + "                         from HGT_PAR_FRAGMS hpf "
                + "                         where hpf.HGT_PAR_CONTIN_ID=hpc.ID)"
                + "where hpc.GENE_ID = ? ";

        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, geneId);
        pstmt.executeUpdate();

        conn.commit();


        //remove contins and fragments less than thres
        PreparedStatement delete_contins_pstmt =
                conn.prepareStatement("delete from HGT_PAR_CONTINS hpc "
                + "where hpc.BS_VAL < ? and "
                + "      hpc.gene_id = ? ");
        delete_contins_pstmt.setFloat(1, thres);
        delete_contins_pstmt.setInt(2, geneId);
        delete_contins_pstmt.executeUpdate();

        
        PreparedStatement delete_fragms_pstmt =
                conn.prepareStatement("delete from HGT_PAR_FRAGMS hpf "
                + "where hpf.BS_VAL < ? and "
                + "      hpf.gene_id = ? ");
        
        delete_fragms_pstmt.setFloat(1, thres);
        delete_fragms_pstmt.setInt(2, geneId);
        delete_fragms_pstmt.executeUpdate();



    }

    public void insertTrsfs() throws SQLException, IllegalAccessException, InstantiationException {

        int batchContent = 0;

        System.out.println("----------------------Entering insertTrsfs().....");

        sql = "select hpc.id, "
                + "       hpc.BS_VAL, "
                + "       hpc.BS_DIRECT > hpc.BS_INVERSE as normal_order, "
                + "       sum (hpf.FROM_CNT * hpf.TO_CNT) as comb_nb "
                + "from hgt_par_contins hpc "
                + "join HGT_PAR_FRAGMS hpf on hpf.HGT_PAR_CONTIN_ID = hpc.id "
                + "where gene_id = ? "
                + "group by hpc.id "
                + "order by hpc.id ";

        PreparedStatement contins_pstmt =
                conn.prepareStatement(sql, ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
        contins_pstmt.setInt(1, geneId);
        ResultSet contins_rs = contins_pstmt.executeQuery();
        RowSetDynaClass contins_rsdc = new RowSetDynaClass(contins_rs);
        contins_rs.close();
        contins_pstmt.close();
        List<DynaBean> contins_lst = contins_rsdc.getRows();
        //convert list to map
        //usefull for using it like a lookup table in joined tables
        Map<Integer, DynaBean> contins_map = new HashMap<Integer, DynaBean>();
        for (DynaBean bean : contins_lst) {
            //rows_map.put(Integer.parseInt(bean.get("id").toString()),bean);
            contins_map.put((Integer) bean.get("id"), bean);
        }


        //System.err.println(rows_map.toString());

        //load fragments
        sql = "select hpf.id, "
                + "       hpf.HGT_PAR_CONTIN_ID, "
                + "       hpf.FROM_SUBTREE, "
                + "       hpf.TO_SUBTREE "
                + "from HGT_PAR_FRAGMS hpf "
                + "where hpf.GENE_ID = ? "
                + "order by hpf.HGT_PAR_CONTIN_ID, "
                + "         hpf.id";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, geneId);

        contins_rs.close();
        contins_pstmt.close();

        List<DynaBean> frgms_lst = (new RowSetDynaClass(pstmt.executeQuery())).getRows();

        //convert list to map
        //usefull for using it like a lookup table in joined tables
        Map<Integer, DynaBean> frgms_map = new HashMap<Integer, DynaBean>();

        for (DynaBean bean : frgms_lst) {
            frgms_map.put((Integer) bean.get("id"), bean);
        }


        //System.err.println(frgms_map.toString());
        System.err.println("contins rows: " + contins_lst.size());
        System.err.println("frgms rows: " + frgms_lst.size());

        //populate new Transfers
        DynaProperty[] properties = {
            new DynaProperty("hgt_par_fragm_id", Integer.class),
            new DynaProperty("hgt_par_contin_id", Integer.class),
            new DynaProperty("ncbi_seq_source_id", Integer.class),
            new DynaProperty("ncbi_seq_dest_id", Integer.class),
            new DynaProperty("weight", Float.class)};

        DynaClass trsfDynaClass;
        trsfDynaClass = new BasicDynaClass("trsf", null, properties);

        //trsf.set("loginDate", new Date());



        sql = "insert into HGT_PAR_TRANSFERS hpt "
                + "(hgt_par_fragm_id, "
                + " hgt_par_contin_id, "
                + " ncbi_seq_source_id, "
                + " ncbi_seq_dest_id,weight) "
                + "values  "
                + "(?,?,?,?,?)";

        pstmt = conn.prepareStatement(sql);


        //cycle fragments
        for (DynaBean frg : frgms_lst) {
            Integer contin_id = (Integer) frg.get("hgt_par_contin_id");
            //map indexed by id, primary key
            DynaBean contin = contins_map.get(contin_id);

            //add only contins over thres
            if ((Double) contin.get("bs_val") >= thres) {
                //decompose from_subtree and to_subtree
                String[] farr = ((String) frg.get("from_subtree")).split(",");
                String[] tarr = ((String) frg.get("to_subtree")).split(",");
                for (String fr : farr) {
                    for (String to : tarr) {
                        fr = fr.trim();
                        to = to.trim();
                        Integer fr_i = Integer.parseInt(fr);
                        Integer to_i = Integer.parseInt(to);
                        //create new row 
                        DynaBean trsf = trsfDynaClass.newInstance();
                        trsf.set("hgt_par_fragm_id", frg.get("id"));
                        trsf.set("hgt_par_contin_id", contin_id);

                        //System.out.println("contin_id: " + contin_id);
                        if ((Boolean) contin.get("normal_order")) {
                            trsf.set("ncbi_seq_source_id", fr_i);
                            trsf.set("ncbi_seq_dest_id", to_i);

                            //System.out.println("normal order " + contin_id);
                        } else {
                            trsf.set("ncbi_seq_source_id", to_i);
                            trsf.set("ncbi_seq_dest_id", fr_i);

                            //System.out.println("reverse order " + contin_id);
                        }

                        trsf.set("weight", 1 / ((BigDecimal) contin.get("comb_nb")).floatValue());
                        //insert row
                        pstmt.setInt(1, (Integer) trsf.get("hgt_par_fragm_id"));
                        pstmt.setInt(2, (Integer) trsf.get("hgt_par_contin_id"));
                        pstmt.setInt(3, (Integer) trsf.get("ncbi_seq_source_id"));
                        pstmt.setInt(4, (Integer) trsf.get("ncbi_seq_dest_id"));
                        pstmt.setFloat(5, (Float) trsf.get("weight"));
                        batchContent++;
                        pstmt.addBatch();


                    }
                }





            }





        }

        System.out.println("batchContent: " + batchContent);
        if (batchContent != 0) {
            int[] numUpdates = pstmt.executeBatch();
            System.out.println("Trsf numUpdates.length: " + numUpdates.length);

        }
        //



    }

    void constructGraphJava(double epsilon_sim_frag,
            int epsilon_dist_frag)
            throws java.sql.SQLException {




        //test storage in native pointer
        //int[] tstArr = new int[FragLenMax];
        //tstArr = from_arr_ptr.get(2).getInts();
        //System.out.println("testing:");
        //printBinStr(from_arr_ptr.getInts());


        SimpleGraph gr = new SimpleGraph(DefaultEdge.class);

        for (int i = 1;
                i <= FragRowNb;
                i++) {
            gr.addVertex(i);
        }

        //enumerate only once each edge
        //asymetric
        System.out.println(
                "FragRowNb: " + FragRowNb);
        for (int u = 1;
                u < FragRowNb;
                u++) {

            for (int v = u + 1; v < FragRowNb; v++) {

                //System.out.println("u: " + u + "v: " + v);

                //add edges

                int[] u_from = from_arr_ptr.get(u).getInts(FragFloatNb);
                int[] u_to = to_arr_ptr.get(u).getInts(FragFloatNb);


                int[] v_from = from_arr_ptr.get(v).getInts(FragFloatNb);
                int[] v_to = to_arr_ptr.get(v).getInts(FragFloatNb);


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

        timeLap(
                "Graph" + " nbEdges: " + nbEdges + " nbVertices: " + nbVertices);

        ConnectivityInspector ci = new ConnectivityInspector(gr);
        List cs = ci.connectedSets();
        //System.out.println("#2 for");
        for (int i = 0;
                i < cs.size();
                i++) {
            //System.out.println(cs.get(i));
        }


        timeLap(
                "Connectivity");


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
        for (int i = 0;
                i < cs.size();
                i++) {

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

    public static void timeInit() {
        prev = System.nanoTime();

    }

    public static void timeLap(String message) {
        now = System.nanoTime();
        float tm = (float) (now - prev) / 1000000000;

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

        HgtParConnCompBest hp = new HgtParConnCompBest(HsqldbPool.getConnection(), 172, 50);

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

        HgtParConnCompBest hp = new HgtParConnCompBest(HsqldbPool.getConnection(), 172, 50);

        timeLap("Constructor");

        hp.updateGenesNcbiSeqsArr();

        hp.loadNcbiSeqsFromGenesArr();



    }

    public static void test3() throws SQLException, IOException, IllegalAccessException, InstantiationException {
        //gene id: 190 Graph nbEdges: 403567 nbVertices: 10406: 646.4194 sec total time: 1 minute 6 seconds

        //gene id: 172 Graph nbEdges: 98 nbVertices: 155: 1.1308 sec


      
      HgtParConnCompBest hp = new HgtParConnCompBest(HsqldbPool.getConnection(), 172, 50);
      
      initJavacl();

      hp.updateGenesNcbiSeqsArr();
      hp.loadNcbiSeqsFromGenesArr();
      //fragments need ncbiSeqs
      hp.loadFragments();
      hp.constructGraphOpenCl(0.75, SqlInfin);
      hp.connectComponOpenCl();
      hp.insertContinsUpdateFragms();
      hp.updateContins();
      //should delete useless fragms
      //do not generate useless coresponding transfers
      //delete_useless_fragms()

      hp.insertTrsfs();
      
      //JavaHgtParConnComp.staticCleanJavacl();
      hp.cleanupJavacl();
      
        
        
       /* 
      //initHsqldbPool();
     // hp.initJavacl();
     //timeLap("Constructor");


        //hp.loadNcbiSeqs();
        hp.updateGenesNcbiSeqsArr();
        hp.loadNcbiSeqsFromGenesArr();
        timeLap("loadNcbiSeqs");

        //fragments need ncbiSeqs
        hp.loadFragments();
        timeLap("loadFragments()");

        hp.constructGraphOpenCl(0.75, SqlInfin);
        //timeLap("constructGraphJava(0.75, SqlInfin)");
        hp.connectComponOpenCl();
        hp.insertContinsUpdateFragms();
        //hp.updateContins();
        //hp.insertTrsfs();

        hp.release();
        timeLap("release");

        hp.cleanupJavacl();
        */

    }

    public static void main(String[] args) throws TreeParseException, IOException, SQLException, IllegalAccessException, InstantiationException {

        initHsqldbPool();
        test3();








    }
}
