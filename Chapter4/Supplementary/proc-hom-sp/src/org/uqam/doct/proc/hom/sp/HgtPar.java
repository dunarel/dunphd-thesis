/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.uqam.doct.proc.hom.sp;

import com.mockrunner.mock.jdbc.MockResultSet;
import com.sun.rowset.CachedRowSetImpl;
import gnu.trove.iterator.TIntIterator;
import gnu.trove.map.hash.TIntIntHashMap;
import gnu.trove.map.hash.TIntObjectHashMap;
import gnu.trove.set.hash.THashSet;
import java.sql.*;
import java.util.Calendar;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import javax.sql.*;
import org.jgrapht.graph.DefaultEdge;
import org.jgrapht.graph.SimpleGraph;

import org.apache.commons.lang3.Range;
import org.jgrapht.alg.ConnectivityInspector;
//rowset.CachedRowSet;

/**
 *
 * @author root
 */
public class HgtPar {

    public static ResultSet sizeByGroupGene(Connection conn, int group)
            throws java.sql.SQLException {

        //CREATE FUNCTION func1(IN P1 INT) 
//RETURNS TABLE(C1 INT) 
//SPECIFIC F1 LANGUAGE JAVA DETERMINISTIC EXTERNAL NAME 'CLASSPATH:proc_hom_sp.HgtPar.sizeByGroupGene'


        //java.sql.PreparedStatement stmt = conn.prepareStatement(
        //    "select * from mytable where col1 = ? or col1 = ?");

        //stmt.setInt(1, p1);
        //stmt.setInt(2, p2);

        //java.sql.ResultSet rs = stmt.executeQuery();
        MockResultSet mrs = new MockResultSet("sizeByGroupGene");

        mrs.addColumn("columnA", new Integer[]{120});

        //rs.addColumn("columnB", new String[]{"Column B Value"});
        //rs.addColumn("columnC", new Double[]{2.2});

        java.sql.ResultSet rs = (java.sql.ResultSet) mrs.clone();

        return rs;
    }

    public static ResultSet funcTest1(int p1, int p2)
            throws java.sql.SQLException {

        Connection conn =
                DriverManager.getConnection("jdbc:default:connection");
        java.sql.PreparedStatement stmt = conn.prepareStatement(
                "select * from mytable where col1 = ? or col1 = ?");

        stmt.setInt(1, p1);
        stmt.setInt(2, p2);

        java.sql.ResultSet rs = stmt.executeQuery();

        return rs;
    }

    public static void procTest2(int p1, int p2,
            Integer[] p3) throws java.sql.SQLException {

        Connection conn =
                DriverManager.getConnection("jdbc:default:connection");
        java.sql.Statement stmt = conn.createStatement();

        stmt.execute("insert into mytable values(" + p1 + ",'test1')");
        stmt.execute("insert into mytable values(" + p2 + ",'test2')");

        java.sql.ResultSet rs = stmt.executeQuery("select * from mytable");
        java.sql.ResultSetMetaData meta = rs.getMetaData();
        int cols = meta.getColumnCount();

        p3[0] = Integer.valueOf(cols);

        rs.close();
        stmt.close();
    }

    public static void testOne(Connection conn)
            throws Exception {

        Statement statement;
        /*
         * try { statement = conn.createStatement();
         *
         * ResultSet rs = statement.executeQuery( "call
         * \"org.hsqldb.test.TestStoredProcedure.procTest1\"()");
         *
         * rs.next();
         *
         * int cols = rs.getInt(1);
         *
         *
         * } catch (Exception e) {}
         */
        try {
            statement = conn.createStatement();

            System.out.println("0");
            // statement.execute(
            //    "CREATE TABLE MYTABLE(COL1 INTEGER,COL2 VARCHAR(10));");
            System.out.println("1");

            //statement.execute(
            //    "CREATE PROCEDURE proc1(IN P1 INT, IN P2 INT, OUT P3 INT) "
            //    + "SPECIFIC P2 LANGUAGE JAVA DETERMINISTIC MODIFIES SQL DATA EXTERNAL NAME 'CLASSPATH:proc_hom_sp.HgtPar.procTest2'");

            System.out.println("2");

            CallableStatement c = conn.prepareCall("call proc1(1,2,?)");

            c.execute();

            int value = c.getInt(1);

            System.out.println("output: " + value);
            c.close();

            /*
             *
             * statement.execute( "CREATE FUNCTION func1(IN P1 INT, IN P2 INT) "
             * + "RETURNS TABLE(C1 INT, C2 INT) " + "SPECIFIC F1 LANGUAGE JAVA
             * DETERMINISTIC EXTERNAL NAME
             * 'CLASSPATH:org.hsqldb.test.TestStoredProcedure.funcTest1'");
             *
             * c = conn.prepareCall("call func1(1,2)");
             *
             * boolean isResult = c.execute();
             *
             * assertTrue(isResult);
             *
             * ResultSet rs = c.getResultSet();
             *
             * rs.next(); assertEquals(value, 2);
             *
             * rs = c.executeQuery();
             *
             * rs.next(); assertEquals(value, 2);
             */
        } catch (Exception e) {
            System.out.println("unexpected error");
        } finally {
            conn.close();
        }
    }

    public static THashSet str_lin_arr(String from_subtree, String to_subtree) {


        THashSet<String> lin_arr = new THashSet();

        String[] farr, tarr;

        //decompose
        farr = from_subtree.split(",");
        tarr = to_subtree.split(",");

        int tr_nb = (farr.length * tarr.length);

        for (int src = 0; src < farr.length; src++) {
            for (int dst = 0; dst < tarr.length; dst++) {
                lin_arr.add(farr[src] + "," + tarr[dst]);
            }
        }


        return lin_arr;

    }

    public static double jaccard_sim_coef(String u_from,
            String u_to,
            String v_from,
            String v_to) {

        THashSet<String> first = str_lin_arr(u_from, u_to);
        THashSet<String> second = str_lin_arr(v_from, v_to);

        THashSet<String> union = new THashSet<String>(first);
        union.addAll(second);

        THashSet<String> intersection = new THashSet<String>(first);
        intersection.retainAll(second);



        double inter_size = intersection.size();
        double union_size = union.size();

        //union = first_arr | second_arr
        double jacc = inter_size / union_size;

        return jacc;

    }
    
   public static boolean is_fragm_conn(int ai, int af, int bi, int bf, int epsilon_dist_frag) {
     
       
    //using java range objects from appache commmons
    Range<Integer> rng_a = Range.between(ai,af);
    Range<Integer> rng_b = Range.between(bi,bf);

    boolean connect_frag = false;
    
    if (rng_a.isOverlappedBy(rng_b)) {
      //#connect overlapping fragments
      connect_frag = true;
      //#puts "rng_a: #{rng_a}, ----- intersection ---- #{rng_a.intersection_with(rng_b)} ----  rng_b: #{rng_b} "
    } else if (rng_a.isBeforeRange(rng_b)) {
      //connect non-overlaping near fragments
      int dist = rng_b.getMinimum() - rng_a.getMaximum();
      if (dist <= epsilon_dist_frag) {
       connect_frag = true;    
      }
      
      //puts "rng_a: #{rng_a}, ----before ---dist: #{dist} ----  rng_b: #{rng_b} "
 
   } else if (rng_a.isAfterRange(rng_b)) {
      //connect non-overlaping near fragments
      int dist = rng_a.getMinimum() - rng_b.getMaximum();
      if (dist <= epsilon_dist_frag) {
       connect_frag = true;    
      }
      //puts "rng_a: #{rng_a}, ----after ---dist: #{dist} ----  rng_b: #{rng_b} "

   }

    
       return connect_frag;
       
   }

  
    public static void constructGraphJava(Connection conn, int geneId, double epsilon_sim_frag,
                            int epsilon_dist_frag)
            throws java.sql.SQLException {

        String sql = "select id,"
                + "fen_idx_min,"
                + "fen_idx_max,"
                + "from_subtree,"
                + "to_subtree "
                + "from hgt_par_fragms "
                + "where gene_id = ? "
                + "order by id";

  
   
   long first, now;
   first = System.nanoTime();
  
   
  //now = cal.getTimeInMillis()
   System.out.println("Start: " + 0 );
   
   
  
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, geneId);

        ResultSet rs = pstmt.executeQuery();
        CachedRowSetImpl crs = new CachedRowSetImpl();
        crs.populate(rs);
        pstmt.close();
        
        crs.last();
        int n = crs.getRow();
        System.out.println("fragments number: " + n);

        TIntIntHashMap id = new TIntIntHashMap(n);
        TIntIntHashMap fen_idx_min = new TIntIntHashMap(n);
        TIntIntHashMap fen_idx_max = new TIntIntHashMap(n);
        TIntObjectHashMap from_subtree = new TIntObjectHashMap(n);
        TIntObjectHashMap to_subtree = new TIntObjectHashMap(n);


        crs.beforeFirst();
        while (crs.next()) {
            int row = crs.getRow();
            id.put(row, crs.getInt(1));
            fen_idx_min.put(row, crs.getInt(2));
            fen_idx_max.put(row, crs.getInt(3));
            from_subtree.put(row, crs.getString(4));
            to_subtree.put(row, crs.getString(5));




        }


        now = System.nanoTime();
        System.out.println("Reading data: " + ((now-first)/10000000) );
   
        //while (crs.next()) {
        //System.out.println("id" + crs.getInt("id"));
        //}

         
        SimpleGraph gr = new SimpleGraph(DefaultEdge.class);

        for (int i = 1; i <= n; i++) {
            gr.addVertex(i);
        }

        //enumerate only once each edge
        //asymetric

        for (int u = 1; u <= n; u++) {

            for (int v = u + 1; v <= n; v++) {

                //System.out.println("u: " + u + "v: " + v);

                //add edges

                String u_from = (String) from_subtree.get(u);
                String u_to = (String) to_subtree.get(u);


                String v_from = (String) from_subtree.get(v);
                String v_to = (String) to_subtree.get(v);


                //System.out.println("u_from : " + u_from + "u_to: " + u_to);
                
                //calculate Jaccard similarity
                double jac_dir =  jaccard_sim_coef(u_from, u_to, v_from, v_to);
                double jac_inv =  jaccard_sim_coef(u_from, u_to, v_to, v_from);

                if ( (jac_dir != 0) || (jac_inv !=0 )) {
                 //System.out.println("u: " + id.get(u) + " v: " + id.get(v) + " src_from: " + u_from + " src_to: " + u_to + 
                  //                  " jac_dir: " + jac_dir + " jac_inv: " + jac_inv);
   
                }
                
                if ((Math.max(jac_dir, jac_inv) > epsilon_sim_frag )  
                        &&
                     is_fragm_conn(fen_idx_min.get(u),fen_idx_max.get(u),
                                   fen_idx_min.get(v),fen_idx_max.get(v),epsilon_dist_frag)
                     ) {
                    gr.addEdge(u, v);
                    
                }
                    
            
        
            
          
                 

            }
        }

         now = System.nanoTime();
        System.out.println("Graph: " + ((now-first)/10000000) );
        
   ConnectivityInspector ci = new ConnectivityInspector(gr);
   
   List cs = ci.connectedSets();
   
  
  //System.out.println("#2 for");
	for (int i = 0; i < cs.size(); i++) {
		//System.out.println(cs.get(i));
	}
        
        
         now = System.nanoTime();
        System.out.println("Connectivity: " + ((now-first)/10000000) );
    //create contins 
    //HgtParContin.destroy_all
    //Statement stmt = conn.createStatement();
    //stmt.execute("delete from hgt_par_contins");
    //stmt.close();

    
    //insert contin
    
     pstmt = conn.prepareStatement("insert into hgt_par_contins "
             + "(gene_id) "
             + "values "
             + "(?)",new String[] {"ID"});
     
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
         
        
        HashSet el =  (HashSet) cs.get(i);
        Iterator it = el.iterator();

           while(it.hasNext()) {
                Integer id_key = (Integer) it.next();
                
              //we will update the contin_id
              int fragm_id = id.get( id_key );
              
              update_fragm_contin_id_pstmt.setInt(1, contin_id);
              update_fragm_contin_id_pstmt.setInt(2, fragm_id);
              update_fragm_contin_id_pstmt.executeUpdate();
              
              //System.out.println("fragm_id: " + fragm_id + "id_key: " + id_key);
           }
             
                
	}
   

        now = System.nanoTime();
        System.out.println("Update data: " + ((now-first)/10000000) );



    }

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) throws SQLException, Exception {
        // TODO code application logic here
        Connection conn =
                DriverManager.getConnection("jdbc:hsqldb:hsql://localhost:9005/proc_hom", "SA", "");
        conn.setAutoCommit(false);

        //testOne(conn);
        //constructGraphJava(conn, 167, 0.75, 10);
        
        HgtParConnCompBest conComp = new HgtParConnCompBest(conn, 167,50);
        conComp.loadNcbiSeqs();
        conComp.constructGraphJava(0.75, 10);  


        /*
         * ResultSet rs = sizeByGroupGene(conn, 1);
         *
         * while (rs.next()) { // retrieve and print the values for the current
         * row Integer i = rs.getInt("columnA"); //String s =
         * rs.getString("columnB"); //Double d = rs.getDouble("columnC");
         * System.out.println("ROW = " + i ); }
         *
         */
    }
}
