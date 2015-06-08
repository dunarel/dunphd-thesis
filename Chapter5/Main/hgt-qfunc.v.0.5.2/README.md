## HGT-QFUNC v.0.5.2

This software implements the HGT detection method described in:

##### CHAPTER V of Dunarel Badescu Ph.D. Thesis - UQAM 
##### A New Fast Algorithm For Detecting And Validating Horizontal Gene Transfer Events Using Phylogenetic Trees And Aggregation Functions


###### Copyright (C) 2015 Dunarel Badescu, Abdoulaye Banire Diallo and Vladimir Makarenkov

### Licence 
   This software is distributed according to the BSD license (3-clause version).

   Our most recent implementation is available at the following URL address:
   http://www.info2.uqam.ca/~makarenkov_v/fastHGT.zip.

### Authors pages:
  * Dunarel Badescu:         https://ca.linkedin.com/pub/dunarel-badescu/26/107/887
  * Vladimir Makarenkov:     http://accueil.labunix.uqam.ca/~makarenkov_v
  * Abdoulaye Banire Diallo: http://ancestors.bioinfo.uqam.ca/BioinfoLab/index.php
  
### Requirements
   * gcc/g++ and BOOST C++ libraries (they are present with major Linux package managers)

### Dependencies (found in [deps/](deps/) folder)
  * [deps/yannisun] (https://sites.google.com/site/yannisun/)
    Fasta file parser released by Yanni Sun @Michigan State University 
      * http://www.cse.msu.edu/~yannisun/cse891/hmm-EM/fasta.c
      * http://www.cse.msu.edu/~yannisun/cse891/hmm-EM/fasta.h

  * [assoc_vector](https://github.com/wo3kie/AssocVector)
    AssocVector is a sorted vector optimized for insert and erase operations 

  * [fast-cpp-csv-parser](https://code.google.com/p/fast-cpp-csv-parser/ )
    Small, easy-to-use and fast header-only library for reading comma separated value (CSV) files.
    
  * [simdpp](https://github.com/p12tic/libsimdpp)
    Header-only zero-overhead C++ wrapper for SIMD intrinsics of multiple instruction sets.

  * [tclap](http://tclap.sourceforge.net/)
    Templatized C++ Command Line Parser Library
    
  

### How to build code?
  * make TARGET=debug clean
  * make TARGET=debug 
  
    install gcc/g++ and BOOST using either yum, zypper on workstations, or module load commands on clusters.

    We also provide a codelite 5.2 workspace (hgt-qfunc.workspace) and project file (hgtqfunc5.project) defining a custom build. 
    This is convenient to use as an IDE, having the same standard Makefile build system.
 
### HGT-QFUNC contents:

  * README  - This file 
  * license - Full text of the BSD license (3-clause)
  
  * [src/main.cpp](src/main.cpp) - Main program
  * [src/q_func_hgt_appl.cpp](src/q_func_hgt_appl.cpp) - Application container
  * [src/q_func_hgt.cpp](src/q_func_hgt.cpp) - Application code
  * [src/aligned_storage.hpp](src/aligned_storage.hpp) - Aligned matrix class to use for fast vector operations
  
  
### Usage:
   We provide a binary Linux executable, compiled on the Compute Quebec/Canada Cluster Guillimin, using g++ and BOOST using:
   module load gcc
   module load BOOST
   make TARGET=debug clean
   make TARGET=debug

   The executable name is: hgt-qfunc-deb 
   Parameters are:
 
1. (--f_opt_max)
   Function index:

   1 Q7a (eq 5.21) -> Q7 in graphics
   2 Q8a (eq 5.22)
   3 Q8b (eq 5.23)
   4 Q9a (eq 5.24) -> Q9 in graphics

2. (--msa-fasta):
   A multiple sequence alignment fo the gene in FASTA format. 
   Parser is basic, so make sure the name contains only the identifier.
   
3. (--winl):
   Length of the Multiple sequence alignment

4. (--gr-seqs-csv):
   A file in csv format, detailing which sequence belongs to which group.
   The header is of this format:
   "","PROK_GROUP_ID","NCBI_SEQ_ID"
   "1",1,15608435
 
5. (--q-func-hgts-csv):
   The name of the resulting file in csv format. 
   The most important results are: seqid_i,seqid_j,val,pval

   Results are also detailing the global, local group memberships and the group components of the formulas.
   An example header follows:
   grpidx_i,grpidx_j,i_size,j_size,locseqidx_i,locseqidx_j,grpid_i,grpid_j,seqid_i,seqid_j,val,pval,dXX,dYY,dXY,flE

   Note that flE is denoting D(x0,y0) or xy throughout the text, while dXX,dYY and dXY are the intragroups and intergroup distances.    

### Example:
   An example of execution is given in the example folder.

### Feedback and bug reports:
   Feedback is welcomed: dunarel(at)gmail(dot)com.

