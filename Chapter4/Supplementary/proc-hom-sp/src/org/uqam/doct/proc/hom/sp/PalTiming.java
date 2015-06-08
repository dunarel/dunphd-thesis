/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package org.uqam.doct.proc.hom.sp;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.Writer;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import org.hsqldb.jdbc.JDBCPool;
import org.rosuda.REngine.REXPMismatchException;
import org.rosuda.REngine.REngineException;
import org.rosuda.REngine.RFactor;
import org.rosuda.REngine.RList;
import org.rosuda.REngine.Rserve.RConnection;
import org.rosuda.REngine.Rserve.RserveException;
import pal.tree.Node;
import pal.tree.NodeUtils;
import pal.tree.ReadTree;
import pal.tree.RootedTreeUtils;
import pal.tree.SimpleNode;
import pal.tree.SimpleTree;
import pal.tree.Tree;
import pal.tree.TreeManipulator;
import pal.tree.TreeParseException;
import pal.tree.TreeTool;
import pal.tree.TreeUtils;
import pal.treesearch.TreeSearchTool;
import sun.reflect.generics.tree.VoidDescriptor;

/**
 *
 * @author root
 */
public class PalTiming {

    private static JDBCPool HsqldbPool;
    public static final String HsqlDatabase = "jdbc:hsqldb:hsql://localhost:9005/proc_hom";
    public static final String AdminUser = "SA";
    public static final String AdminPass = "";

    public static void initHsqldbPool() {


        HsqldbPool = new JDBCPool();
        HsqldbPool.setDatabase(HsqlDatabase);
        HsqldbPool.setUser(AdminUser);
        HsqldbPool.setPassword(AdminPass);




    }
    //original unrooted, given by RAXML in subtitutions per site
    //private String unrootedTreeName;
    //rooted(midpoint), scaled to 
    //private String rootedTreeName;
    Tree unrootedTree;
    Tree rootedTree;
    Node root;
    private Connection conn;
    //scaling factor
    private double rootAge;
    //array of all unrootedTree branches dimensions
    double[] scaledTreeBranches;
    double[] originalTreeBranches;
    //R linked statistics
    private double rstNormalMean;
    private double rstNormalStdev;
    //these are in RealSpace
    private double rstLogNormalMu;
    private double rstLogNormalSigma;
    //exponential
    //private double fdrExpMeanRate;
    //private double fdrExpSdRate;
    //lognormal
    //private double fdrEstimateMeanlog;
    //private double fdrEstimateSdlog;
    //private double fdrSdMeanlog;
    //private double fdrSdSdlog;
    

    public PalTiming() {
    }

    public void loadUnrootedTree(String unrootedTreeName) throws TreeParseException, IOException {
        unrootedTree = new ReadTree(unrootedTreeName);
    }

    public void midpointRootTree() {
        rootedTree = TreeTool.getMidPointRooted(unrootedTree);
        root = rootedTree.getRoot();
        //have to set it before scaling
        rootAge = 0.0;

    }

    public void saveRootedTree(String rootedTreeName) throws IOException {

        File myFile = new File(rootedTreeName);
        PrintWriter output = new PrintWriter(new BufferedWriter(new FileWriter(myFile)));

        TreeUtils.printNH(rootedTree, output, true, true);

        output.close();

    }

    public void loadRootedTree(String rootedTreeName) throws TreeParseException, IOException {
        rootedTree = new ReadTree(rootedTreeName);
        root = rootedTree.getRoot();
        System.out.println("root height: " + root.getNodeHeight());
        System.out.println("root branch: " + root.getBranchLength());
    }

    public Node getTransferNode(String transfer) {

        String[] splits = transfer.split("[ ,]+");
        Node[] nodes = new Node[splits.length];

        for (int i = 0; i < splits.length; i++) {
            String spl = splits[i];
            //System.out.println("Split: >" + spl + "<");
            nodes[i] = TreeUtils.getNodeByName(root, spl);
            //System.out.println("i: " + i);
            //System.out.println("heigh: " + nodes[i]);
        }


        //nodes[0] = TreeUtils.getNodeByName(root, "16080278");
        //nodes[1] = TreeUtils.getNodeByName(root, "305675819");



        Node trNode = NodeUtils.getFirstCommonAncestor(nodes);
        //System.out.println(trNode.getNodeHeight());
        return trNode;
    }

    public float getAgeNodeParent(String tr) {

        Node fromNode, fromNodeParent;

        fromNode = getTransferNode(tr);
        fromNodeParent = fromNode.getParent();


        float len = (float) NodeUtils.getMaximumPathLengthLengthToLeaf(fromNodeParent);



        return len;

    }

    public float getAgeNode(String tr) {

        float len = (float) NodeUtils.getMaximumPathLengthLengthToLeaf(getTransferNode(tr));



        return len;

    }

    public float getRelativeAgeNd(String toTr) {

        //Node toNodeParent;
        Node toNode;
        toNode = getTransferNode(toTr);

        //do not go higher than root
        //do not go higher than root
        //if (toNode.isRoot()) {
        //    toNodeParent = toNode;
        //} else {
        //   toNodeParent = toNode.getParent();
        //}


        float toLen = (float) toNode.getNodeHeight();

        //NodeUtils.get MaximumPathLengthLengthToLeaf(toNode);
        //float toLen = (float) NodeUtils.getMaximumPathLengthLengthToLeaf(toNode);
        //float toLenParent = (float) NodeUtils.getMaximumPathLengthLengthToLeaf(toNodeParent);


        //System.out.println("fromLen: " + fromLen + " fromLenParent: " + fromLenParent);
        //System.out.println("toLen: " + toLen + " toLenParent: " + toLenParent);

        //float result = (toLen + toLenParent) / 2;
        float result = toLen;
        //System.out.println("result: " + result);
        return result;

    }

    public float getRelativeAgeBr(String toTr) {

        System.out.println("getRelativeAgeBr(" + toTr + ")");

        Node toNodeParent;
        Node toNode;
        toNode = getTransferNode(toTr);

        //do not go higher than root
        //do not go higher than root
        if (toNode.isRoot()) {
            toNodeParent = toNode;
        } else {
            toNodeParent = toNode.getParent();
        }


        float toLen = (float) toNode.getNodeHeight();
        float toLenParent = (float) toNodeParent.getNodeHeight();

        //NodeUtils.get MaximumPathLengthLengthToLeaf(toNode);
        //float toLen = (float) NodeUtils.getMaximumPathLengthLengthToLeaf(toNode);



        System.out.println("toLen: " + toLen + " toLenParent: " + toLenParent);
        //System.out.println("fromLen: " + fromLen + " fromLenParent: " + fromLenParent);
        //System.out.println("toLen: " + toLen + " toLenParent: " + toLenParent);

        float result = (toLen + toLenParent) / 2;
        //float result = toLen;
        //System.out.println("result: " + result);
        return result;

    }

    //for :beast, get node branch age
    public float getAbsoluteAgeNd(String toTr) {



        //Node toNodeParent;
        Node toNode;
        toNode = getTransferNode(toTr);

        //do not go higher than root
        //do not go higher than root
        //if (toNode.isRoot()) {
        //    toNodeParent = toNode;
        //} else {
        //    toNodeParent = toNode.getParent();
        //}


        //float toLen = (float) NodeUtils.getMaximumPathLengthLengthToLeaf(toNode);
        float toLen = (float) toNode.getBranchLength();

        //float toLenParent = (float) NodeUtils.getMaximumPathLengthLengthToLeaf(toNodeParent);


        //System.out.println("fromLen: " + fromLen + " fromLenParent: " + fromLenParent);
        //System.out.println("toLen: " + toLen + " toLenParent: " + toLenParent);

        //float result = (toLen + toLenParent) / 2;
        float result = toLen;

        System.out.println("is leaf: " + toNode.isLeaf());
        return result;

    }

    //for :beast, get node branch age
    public float getAbsoluteAgeBr(String toTr) {
        System.out.println("getAbsoluteAgeBr(" + toTr + ")");


        Node toNodeParent;
        Node toNode;
        toNode = getTransferNode(toTr);

        //do not go higher than root
        //do not go higher than root
        if (toNode.isRoot()) {
            toNodeParent = toNode;
        } else {
            toNodeParent = toNode.getParent();
        }


        //float toLen = (float) NodeUtils.getMaximumPathLengthLengthToLeaf(toNode);
        float toLen = (float) toNode.getBranchLength();
        float toLenParent = (float) toNodeParent.getBranchLength();


        System.out.println("toLen: " + toLen + " toLenParent: " + toLenParent);
        //System.out.println("toLen: " + toLen + " toLenParent: " + toLenParent);

        float result = (toLen + toLenParent) / 2;
        //float result = toLen;

        //System.out.println("result: " + result);
        return result;

    }

    public float getAge(String fromTr, String toTr) {

        Node fromNode, fromNodeParent, toNode, toNodeParent;
        fromNode = getTransferNode(fromTr);
        toNode = getTransferNode(toTr);

        //do not go higher than root
        if (fromNode.isRoot()) {
            fromNodeParent = fromNode;
        } else {
            fromNodeParent = fromNode.getParent();
        }

        //do not go higher than root
        if (toNode.isRoot()) {
            toNodeParent = toNode;
        } else {
            toNodeParent = toNode.getParent();
        }


        float fromLen = (float) NodeUtils.getMaximumPathLengthLengthToLeaf(fromNode);
        float fromLenParent = (float) NodeUtils.getMaximumPathLengthLengthToLeaf(fromNodeParent);
        float toLen = (float) NodeUtils.getMaximumPathLengthLengthToLeaf(toNode);
        float toLenParent = (float) NodeUtils.getMaximumPathLengthLengthToLeaf(toNodeParent);


        //System.out.println("fromLen: " + fromLen + " fromLenParent: " + fromLenParent);
        //System.out.println("toLen: " + toLen + " toLenParent: " + toLenParent);

        float result = (fromLen + fromLenParent + toLen + toLenParent) / 4;

        //System.out.println("result: " + result);
        return result;

    }

    public void test_small_branch_len() throws IOException, TreeParseException {
        /*
         float age;

         PalTiming pt = new PalTiming(conn, "/root/devel/proc_hom/files/hgt-com-110/hgt-com-raxml/results/hgt-com-raxml_geneargS_id110.BQ/gene_res_java4.tr");
         //age = pt.getAge("154687337, 308174920","16080278, 305675819");
         //System.out.println("age : " + age);

         //age = pt.getAgeSimple("301053523, 52143451");
         //System.out.println("age : " + age);

         // TODO code application logic here
         TreeManipulator treeMan = new TreeManipulator(pt.rootedTree);
         TreeManipulator.BranchAccess[] brAcce = treeMan.getBranchAccess();

         for (int i = 0; i < brAcce.length; i++) {
         }


         int int_node_cnt = pt.rootedTree.getInternalNodeCount();
         for (int i = 0; i < int_node_cnt; i++) {
         Node nd = pt.rootedTree.getInternalNode(i);
         System.out.println("internal nd: " + i + " brench len: " + nd.getBranchLength() + "is leaf: " + nd.isLeaf() + "isRoot: " + nd.isRoot());
         if (nd.getBranchLength() < 0.001) {
         System.out.println("internal Hit");
         nd.setBranchLength(0.01);
         System.out.println("internal nd: " + i + " brench len: " + nd.getBranchLength() + "is leaf: " + nd.isLeaf());
         //nd.setBranchLength(j);
         }
         }

         System.out.println("============External nodes=====================");
         int ext_node_cnt = pt.rootedTree.getExternalNodeCount();
         for (int j = 0; j < ext_node_cnt; j++) {
         Node nd = pt.rootedTree.getExternalNode(j);
         System.out.println("external nd: " + j + " brench len: " + nd.getBranchLength() + "is leaf: " + nd.isLeaf() + "isRoot: " + nd.isRoot());


         if (nd.getBranchLength() < 0.001) {
         System.out.println("external Hit");
         nd.setBranchLength(0.01);
         }

         }

         Tree unrooted = TreeTool.getUnrooted(pt.rootedTree);

         File myFile = new File("/root/devel/proc_hom/files/hgt-com-110/hgt-com-raxml/results/hgt-com-raxml_geneargS_id110.BQ/gene_res_java5.tr");
         PrintWriter output = new PrintWriter(new BufferedWriter(new FileWriter(myFile)));

         TreeUtils.printNH(unrooted, output, true, true);

         output.close();

         Node nd = pt.rootedTree.getInternalNode(58);
         System.out.println("internal nd: " + 58 + " brench len: " + nd.getBranchLength() + "is leaf: " + nd.isLeaf());
         */
    }

    protected void scaleBranch(Node nd) {
        double beforeLen = nd.getBranchLength();
        double afterLen = beforeLen / root.getNodeHeight() * rootAge;

        nd.setBranchLength(afterLen);

    }

    public void scaleRootedTree() throws IOException, RserveException, REngineException, REXPMismatchException {

        //prepare list of branches
        //do not add zero lenght root branch
        int nbBranches = rootedTree.getInternalNodeCount()
                + rootedTree.getExternalNodeCount() - 1;
        System.out.println("nbBranches: " + nbBranches);

        originalTreeBranches = new double[nbBranches];
        scaledTreeBranches = new double[nbBranches];


        int brIndex = 0;

        //for(int i=0; i< 20; i++) {
        //    dataX[i]= i*i;
        //    dataY[i]= 200;
        //}

        //



        float ageMd = (float) root.getNodeHeight();
        System.out.println("ageMd: " + ageMd);

        //4290
        double rootHeight = root.getNodeHeight();
        double rootLen = NodeUtils.getMaximumPathLengthLengthToLeaf(root);
        System.out.println("rootHeight: " + rootHeight + " rootLen: " + rootLen);

        int int_node_cnt = rootedTree.getInternalNodeCount();
        for (int i = 0; i < int_node_cnt; i++) {
            Node nd = rootedTree.getInternalNode(i);
            System.out.println("brIndex: " + brIndex + " internal nd: " + i + " brench len: " + nd.getBranchLength() + " is leaf: " + nd.isLeaf() + " isRoot: " + nd.isRoot());



            //add to list
            if (nd.isRoot()) {
                //only scale  
                scaleBranch(nd);

            } else {
                //take snapshot
                originalTreeBranches[brIndex] = nd.getBranchLength();
                //scale
                scaleBranch(nd);
                //snapshot again
                scaledTreeBranches[brIndex] = nd.getBranchLength();
                //next
                brIndex++;
            }


            //if (nd.getBranchLength() < 0.001) {
            //    System.out.println("internal Hit");
            //    nd.setBranchLength(0.01);
            //    System.out.println("internal nd: " + i + " brench len: " + nd.getBranchLength() + "is leaf: " + nd.isLeaf());
            //nd.setBranchLength(j);
            //}
        }

        System.out.println("============External nodes=====================");
        int ext_node_cnt = rootedTree.getExternalNodeCount();
        for (int j = 0; j < ext_node_cnt; j++) {
            Node nd = rootedTree.getExternalNode(j);
            System.out.println("brIndex: " + brIndex + " external nd: " + j + " brench len: " + nd.getBranchLength() + " is leaf: " + nd.isLeaf() + " isRoot: " + nd.isRoot());


            //add to list
            //take snapshot
            originalTreeBranches[brIndex] = nd.getBranchLength();
            //scale
            scaleBranch(nd);
            //snapshot again
            scaledTreeBranches[brIndex] = nd.getBranchLength();
            //next
            brIndex++;


            //if (nd.getBranchLength() < 0.001) {
            //    System.out.println("external Hit");
            //    nd.setBranchLength(0.01);
            //}

        }

        //Tree unrooted = TreeTool.getUnrooted(rootedTree);

        //4290
        rootHeight = root.getNodeHeight();
        rootLen = NodeUtils.getMaximumPathLengthLengthToLeaf(root);
        System.out.println("rootHeight: " + rootHeight + " rootLen: " + rootLen);






    }

    public void calculateRStatistics() throws RserveException, REngineException, REXPMismatchException {
        //send to R
        RConnection c = new RConnection();

        //c.assign("stbr", scaledTreeBranches);
        //use original unscaled tree branches
        c.assign("stbr", originalTreeBranches);

        for (int i = 0; i < originalTreeBranches.length; i++) {
            double x = originalTreeBranches[i];
            double y = scaledTreeBranches[i];
            System.out.println("i: " + i + " x:" + x + " y: " + y);
        }

        String script = " \n"
                + "mn = mean(stbr)\n"
                + "va = var(stbr)\n"
                + "sd = sqrt(va)\n"
                + "log_mu = log((mn^2)/sqrt(va+mn^2))\n"
                + "log_sigma = sqrt(log(va/(mn^2)+1))\n"
                + "mu = exp(log_mu)\n"
                + "sg = exp(log_sigma)";

        /*        
         String script = "library(MASS); \n"
         + "setwd(\"/root/devel/proc_hom/r_lang/test2\"); \n"
         + "write.csv(stbr, file = \"stbr.csv\"); \n"
         + "fdr<-fitdistr(stbr, 'exponential'); \n";
        
         //+ "fdr<-fitdistr(stbr, 'lognormal'); \n";

         //        + "fdr_estimate_meanlog <- fdr$estimate[1];"
         //        + "fdr_estimate_sdlog <- fdr$estimate[2];"
         //        + "fdr_sd_meanlog <- fdr$sd[1];"
         //        + "fdr_sd_sdlog <- fdr$sd[2];";
         */

        System.out.println("script " + script);
        c.voidEval(script);
        setRstNormalMean(c.eval("mn").asDouble());
        setRstNormalStdev(c.eval("sd").asDouble());
        setRstLogNormalMu(c.eval("mu").asDouble());
        setRstLogNormalSigma(c.eval("sg").asDouble());
        
        
        
        System.out.println("mean: " + getRstNormalMean());
        System.out.println("stdev: " + getRstNormalStdev());
        System.out.println("mu: " + getRstLogNormalMu());
        System.out.println("sg: " + getRstLogNormalSigma());
        //fdrExpMeanRate = c.eval("fdr$estimate[\"rate\"]").asDouble();
        //fdrExpSdRate = c.eval("fdr$sd[\"rate\"]").asDouble();
 
        //fdrEstimateMeanlog = c.eval("fdr$estimate[1]").asDouble();
        //fdrEstimateSdlog = c.eval("fdr$estimate[2]").asDouble();
        //fdrSdMeanlog = c.eval("fdr$sd[1]").asDouble();
        //fdrSdSdlog = c.eval("fdr$sd[2]").asDouble();


        //c.voidEval("");

        //c.assign("y", dataY);
        //double[] l = c.eval("fdr").asDoubles();
        //System.out.println(" response: " +l.toString());

        //asList();
        //double x = l.at(0).asDouble();
        //double y = l.at(1).asDouble();
        //System.out.println("x: "+ x + " y: " + y);

        //double[] lx = l.at("x").asDoubles();
        //double[] ly = l.at("y").asDoubles();

        //c.voidEval("setwd(\"/root/devel/proc_hom/r_lang\")");
        //c.voidEval("save.image()");

        c.close();
    }

    public static void test1() throws SQLException, TreeParseException, IOException {



        PalTiming pt = new PalTiming();

        //HsqldbPool.getConnection(),
        pt.loadUnrootedTree("/root/devel/proc_hom/files/hgt-com-110/hgt-com-raxml/results/hgt-com-raxml_geneatpD_id164.BQ/gene_dat.tre");
        //pt.setRootedTreeName("/root/local/whme_beast/hgt_com/secE/gene_res_rooted_scaled.tre");


        float ageMd;
        String fromTr = "152980404, 300313646, 339327668, 94312425";

        String toTr = "117626005, 16131600, 170083233, 215489070, 218556303, 218560807, 218692020, 218697458, 218702582, 218707378, 238902823, 254163684, 254795738, 260846483, 260857853, 260870466, 26250476, 291285156, 291615580, 62182347, 91213257";

        //Node fromNode = pt.getTransferNode(fromTr);

        //Node fromParentNode = fromNode.getParent();
        //System.out.println("parentNode: " + fromNode.isRoot());

        //float fromLen = (float) NodeUtils.getMaximumPathLengthLengthToLeaf(fromNode);
        //float fromLenParent = (float) NodeUtils.getMaximumPathLengthLengthToLeaf(fromParentNode);



        //Node toNode = pt.getTransferNode(to_subtree);
        // System.out.println("is root" + toNode.isRoot());

        //float toLen = (float) NodeUtils.getMaximumPathLengthLengthToLeaf();
        // Node toParentNode = toNode.getParent(); 

        //System.out.println("is root" + toNode.isRoot() + " " + toParentNode.isRoot());
        //float toLenParent = (float) NodeUtils.getMaximumPathLengthLengthToLeaf(getTransferNode(fromTr).getParent());


        //    System.out.println("fromLen: " + fromLen + " fromLenParent: " + fromLenParent);
        //   System.out.println("toLen: " + toLen + " toLenParent: " + toLenParent);

        // float result = (fromLen + fromLenParent + toLen + toLenParent) / 4;

        //   System.out.println("result: " + result);
        //   return result;


        ageMd = pt.getAge(fromTr, toTr);
        System.out.println("ageMd: " + ageMd);



    }

    public static void test2() throws SQLException, TreeParseException, IOException, RserveException, REngineException, REXPMismatchException {

        String inputTreeF = "/root/local/whme_beast/hgt_com/secE/gene_res.tr";
        //String inputTreeF  = "/root/local/whme_beast/hgt_com/secE/out.tre";

        String outputTreeF = "/root/local/whme_beast/hgt_com/secE/gene_res_rooted_scaled.tre";

        PalTiming pt = new PalTiming();
        //pt.setConn(HsqldbPool.getConnection());
        pt.loadUnrootedTree(inputTreeF);

        pt.midpointRootTree();
        //scale to root of prokaryotes
        pt.setRootAge(4290);
        pt.scaleRootedTree();

        pt.saveRootedTree(outputTreeF);
        pt.calculateRStatistics();

       // System.out.println("estimate: mean: " + pt.getFdrEstimateMeanlog() + " sd: " + pt.getFdrEstimateSdlog());
       // System.out.println("sd      : mean: " + pt.getFdrSdMeanlog() + " sd: " + pt.getFdrSdSdlog());


    }

    public static void test3()
            throws SQLException, TreeParseException, IOException, RserveException, REXPMismatchException, REngineException {

        double[] dataX = new double[20];
        double[] dataY = new double[20];

        for (int i = 0; i < 20; i++) {
            dataX[i] = i * i;
            dataY[i] = 200;
        }

        RConnection c = new RConnection();
        c.assign("x", dataX);
        c.assign("y", dataY);
        RList l = c.eval("lowess(x,y)").asList();
        double[] lx = l.at("x").asDoubles();
        double[] ly = l.at("y").asDoubles();

        c.voidEval("setwd(\"/root/devel/proc_hom/r_lang\")");
        c.voidEval("save.image()");


        //RConnection c = new RConnection();
        //double d[] = c.eval("rnorm(7)").asDoubles();
        //c.voidEval("save.image()");

        //for (double i : d) {
        //   System.out.println("i: " + i);
        //}
    }

    public static void test4() throws TreeParseException, IOException {
        //String inputTreeF = "/root/devel/files_srv/db_files/proc_hom/hgt-com-110/hgt-com-raxml/timing/beast/fabG/dated_tree.nwk";
        String inputTreeF;
        PalTiming pt;

        inputTreeF = "/root/devel/proc_hom/files/hgt-com-110/hgt-com-raxml/timing/treepl/results/thrC/dated_tree.nwk";
        pt = new PalTiming();
        //pt.setConn(HsqldbPool.getConnection());
        pt.loadRootedTree(inputTreeF);
        //System.out.println("mrca beast: " + pt.getAbsoluteAgeNd("119899719, 94312271"));
        //System.out.println("mrca beast: " + pt.getAbsoluteAgeNd("94312271"));
        // System.out.println("estimate: mean: " + pt.getFdrEstimateMeanlog() + " sd: " + pt.getFdrEstimateSdlog());
        // System.out.println("sd      : mean: " + pt.getFdrSdMeanlog() + " sd: " + pt.getFdrSdSdlog());

        System.out.println("mrca treepl: " + pt.getRelativeAgeNd("32476680"));

        inputTreeF = "/root/devel/proc_hom/files/hgt-com-110/hgt-com-raxml/timing/beast/results/thrC/dated_tree_med.nwk";
        pt = new PalTiming();
        //pt.setConn(HsqldbPool.getConnection());
        pt.loadRootedTree(inputTreeF);
        //System.out.println("mrca treepl: " + pt.getRelativeAgeNd("119899719, 94312271"));
        //System.out.println("mrca treepl: " + pt.getRelativeAgeNd("94312271"));
        //System.out.println("mrca dated_tree_med: " + pt.getAbsoluteAgeBr("16330350,172037359"));
        System.out.println("mrca dated_tree_med: " + pt.getAbsoluteAgeBr("16330350"));


        inputTreeF = "/root/devel/proc_hom/files/hgt-com-110/hgt-com-raxml/timing/beast/results/thrC/dated_tree_orig.nwk";
        pt = new PalTiming();
        //pt.setConn(HsqldbPool.getConnection());
        pt.loadRootedTree(inputTreeF);
        //System.out.println("mrca treepl: " + pt.getRelativeAgeNd("119899719, 94312271"));
        //System.out.println("mrca treepl: " + pt.getRelativeAgeNd("94312271"));
        //System.out.println("mrca dated_tree_orig: " + pt.getRelativeAgeBr("16330350,172037359"));
        System.out.println("mrca dated_tree_orig: " + pt.getRelativeAgeBr("16330350"));



        // System.out.println("estimate: mean: " + pt.getFdrEstimateMeanlog() + " sd: " + pt.getFdrEstimateSdlog());
        // System.out.println("sd      : mean: " + pt.getFdrSdMeanlog() + " sd: " + pt.getFdrSdSdlog());



    }

    public void test5() throws TreeParseException, IOException {
        //String inputTreeF = "/root/devel/files_srv/db_files/proc_hom/hgt-com-110/hgt-com-raxml/timing/beast/fabG/dated_tree.nwk";
        String inputTreeF;


        //inputTreeF = "/root/devel/proc_hom/files/hgt-com-110/hgt-com-raxml/results/hgt-com-raxml_genesecE_id172.BQ/gn_tr_dn.nwk";
        inputTreeF = "/root/devel/proc_hom/files/hgt-com-110/hgt-com-raxml/secE/test/gene_tree.nwk";


        //pt.setConn(HsqldbPool.getConnection());
        loadUnrootedTree(inputTreeF);
        TreeUtils.labelInternalNodes(unrootedTree);

        Node n2 = TreeUtils.getNodeByName(unrootedTree, "45656641");
        //n2.getParent();
        n2.addChild(new SimpleNode("fake_root", 1.0));
        TreeUtils.reroot(unrootedTree, n2);





        String leftS = "45656641,110681151,294675842,209964024,190891341,86357291,222085662,27380528,39936338,162448674,197117310,340785583,300309441,152980358,339327541,94312271,119899719,320449271,225874473";

        String[] splits = leftS.split(",");
        Node[] nodesL = new Node[splits.length];

        for (int i = 0; i < splits.length; i++) {
            String spl = splits[i];
            //System.out.println("Split: >" + spl + "<");
            nodesL[i] = TreeUtils.getNodeByName(unrootedTree, spl);
            Node nd = nodesL[i];
            System.out.println("i: " + i + " Number: " + nd.getNumber() + " Identifier: " + nd.getIdentifier().toString());

        }


        //nodes[0] = TreeUtils.getNodeByName(root, "16080278");
        //nodes[1] = TreeUtils.getNodeByName(root, "305675819");



        Node leftRootNode = NodeUtils.getFirstCommonAncestor(nodesL);
        System.out.println(" Number: " + leftRootNode.getNumber() + " leftRootNode Name: " + leftRootNode.getIdentifier().getName());

        //TreeUtils.labelInternalNodes(unrootedTree);
        //TreeUtils.reroot(unrootedTree, leftRootNode);

        //System.out.println("mrca beast: " + pt.getAbsoluteAgeNd("119899719, 94312271"));
        //System.out.println("mrca beast: " + pt.getAbsoluteAgeNd("94312271"));
        // System.out.println("estimate: mean: " + pt.getFdrEstimateMeanlog() + " sd: " + pt.getFdrEstimateSdlog());
        // System.out.println("sd      : mean: " + pt.getFdrSdMeanlog() + " sd: " + pt.getFdrSdSdlog());


        String rightS = "189218810,347535704,150025254,120436721,110640210,21672990,238903037,16131811,170083441,291285395,218692262,260870692,260846781,218702611,218707599,218697688,218561047,218556535,215489313,260858090,254795979,254163922,117626245,91212814,26250750,291615762,62182601,172035144,217076741,302036652,15607136";
        splits = rightS.split(",");
        Node[] nodesR = new Node[splits.length];

        for (int i = 0; i < splits.length; i++) {
            String spl = splits[i];
            //System.out.println("Split: >" + spl + "<");
            nodesR[i] = TreeUtils.getNodeByName(unrootedTree, spl);
            Node nd = nodesR[i];
            System.out.println("i: " + i + " Number: " + nd.getNumber() + " Identifier: " + nd.getIdentifier().toString());
        }


        //nodes[0] = TreeUtils.getNodeByName(root, "16080278");
        //nodes[1] = TreeUtils.getNodeByName(root, "305675819");



        Node rightRootNode = NodeUtils.getFirstCommonAncestor(nodesR);
        System.out.println(" Number: " + rightRootNode.getNumber() + " rightRootNode Name: " + rightRootNode.getIdentifier().getName());


        Node nR2 = TreeUtils.getNodeByName(unrootedTree, rightRootNode.getIdentifier().getName());
        Node nR1 = nR2.getParent();

        //Node nR = new SimpleNode("root2",1);


        //nR2.setParent(nR);
        //nR1.setParent(nR);


        //Node root = unrootedTree.getRoot();
        //root.getChild(0).remove;


        //n2.getParent().removeChild(0);


        //print to file
        String outputTreeF = "/root/devel/proc_hom/files/hgt-com-110/hgt-com-raxml/secE/test/gene_tst.nwk";
        File myFile = new File(outputTreeF);
        PrintWriter output = new PrintWriter(new BufferedWriter(new FileWriter(myFile)));

        Tree sub1 = new SimpleTree(nR2);
        Tree sub2 = new SimpleTree(nR1);
        Tree sub3 = new SimpleTree();



        TreeUtils.printNH(sub2, output, true, true);

        output.close();


        //iterate over sub2 subtree and remove nodes from original tree



        TreeUtils.reroot(unrootedTree, nR1);
        leftRootNode = NodeUtils.getFirstCommonAncestor(nodesL);
        System.out.println(" Number: " + leftRootNode.getNumber() + " leftRootNode Name: " + leftRootNode.getIdentifier().getName());



        //Node x = NodeUtils.(unrootedTree, )


    }

    public void test6() throws TreeParseException, IOException, RserveException, REngineException, REXPMismatchException {
        //String inputTreeF = "/root/devel/files_srv/db_files/proc_hom/hgt-com-110/hgt-com-raxml/timing/beast/fabG/dated_tree.nwk";
        String inputTreeF;
        String outputTreeF;


        //inputTreeF = "/root/devel/proc_hom/files/hgt-com-110/hgt-com-raxml/results/hgt-com-raxml_genesecE_id172.BQ/gn_tr_dn.nwk";
        inputTreeF = "/root/devel/files_srv/db_files/proc_hom/hgt-com-110/hgt-com-raxml/timing/beast/work/purB/gene_rooted.nwk";
        outputTreeF = "/root/devel/files_srv/db_files/proc_hom/hgt-com-110/hgt-com-raxml/timing/beast/work/purB/starting_tree.nwk";


        //pt.setConn(HsqldbPool.getConnection());
        loadRootedTree(inputTreeF);


        setRootAge(4290);
        scaleRootedTree();
        saveRootedTree(outputTreeF);
        calculateRStatistics();




    }

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) throws TreeParseException, IOException, SQLException, RserveException, REXPMismatchException, REngineException {

        initHsqldbPool();
        PalTiming pt;
        pt = new PalTiming();

        //test1();
        //test2();
        //pt.test5();
        pt.test6();



        //Connection conn =
        //          DriverManager.getConnection("jdbc:hsqldb:hsql://localhost:9005/proc_hom", "SA", "");





    }

   
    /**
     * @return the rootAge
     */
    public double getRootAge() {
        return rootAge;
    }

    /**
     * @param rootAge the rootAge to set
     */
    public void setRootAge(double rootAge) {
        this.rootAge = rootAge;
    }

    /**
     * @return the unrootedTreeName
     */
    //public String getUnrootedTreeName() {
    //    return unrootedTreeName;
    //}
    /**
     * @param unrootedTreeName the unrootedTreeName to set
     */
    //public void setUnrootedTreeName(String unrootedTreeName) {
    //    this.unrootedTreeName = unrootedTreeName;
    //}
    /**
     * @return the rootedTreeName
     */
    //public String getRootedTreeName() {
    //    return rootedTreeName;
    //}
    /**
     * @param rootedTreeName the rootedTreeName to set
     */
    //public void setRootedTreeName(String rootedTreeName) {
    //    this.rootedTreeName = rootedTreeName;
    //}
    /**
     * @return the conn
     */
    public Connection getConn() {
        return conn;
    }

    /**
     * @param conn the conn to set
     */
    public void setConn(Connection conn) {
        this.conn = conn;
    }

    /**
     * @return the rstNormalMean
     */
    public double getRstNormalMean() {
        return rstNormalMean;
    }

    /**
     * @param rstNormalMean the rstNormalMean to set
     */
    public void setRstNormalMean(double rstNormalMean) {
        this.rstNormalMean = rstNormalMean;
    }

    /**
     * @return the rstNormalStdev
     */
    public double getRstNormalStdev() {
        return rstNormalStdev;
    }

    /**
     * @param rstNormalStdev the rstNormalStdev to set
     */
    public void setRstNormalStdev(double rstNormalStdev) {
        this.rstNormalStdev = rstNormalStdev;
    }

    /**
     * @return the rstLogNormalMu
     */
    public double getRstLogNormalMu() {
        return rstLogNormalMu;
    }

    /**
     * @param rstLogNormalMu the rstLogNormalMu to set
     */
    public void setRstLogNormalMu(double rstLogNormalMu) {
        this.rstLogNormalMu = rstLogNormalMu;
    }

    /**
     * @return the rstLogNormalSigma
     */
    public double getRstLogNormalSigma() {
        return rstLogNormalSigma;
    }

    /**
     * @param rstLogNormalSigma the rstLogNormalSigma to set
     */
    public void setRstLogNormalSigma(double rstLogNormalSigma) {
        this.rstLogNormalSigma = rstLogNormalSigma;
    }
}
