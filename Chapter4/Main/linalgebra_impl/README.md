 
5) Later, we were able to simplify the aggregating step, from our original Relational Algebra solution, transforming it to a Linear Algebra one. We implemented this solution only for the Complete Horizontal Gene Transfer, given in the folder chap4-linalgebra_impl.

It contains one R script for extracting the initial data from the database: 
proc-hom-v.0.2.R

Another Python script exemplify the whole approach:
proc-hom-v.0.2.py
The final value is the one from Table 4.1a. Mean HGT rates Complete HGT 75% bootstrap.

chap4-linalgebra_impl/files2 contains the data files.
chap4-linalgebra_impl/sql contains some sql queries transitively used to query the database.

We also provide another script file, able to also directly work with the core genes:
chap4-linalgebra_impl/core-files.R


### HGT-QFCLUST v.0.2

This software implements the HGT custom weighted clustering described in:

##### CHAPTER IV of Dunarel Badescu Ph.D. Thesis - UQAM 
##### Complete And Partial Horizontal Gene Transfers At The Core Of Prokaryotic Ecology And Evolution


###### Copyright (C) 2015 Dunarel Badescu, Abdoulaye Banire Diallo and Vladimir Makarenkov

### Licence 
   This software is distributed according to the BSD license (3-clause version).

   Our most recent implementation is available at the following URL address:
   http://www.info2.uqam.ca/~makarenkov_v/HgtQClust.zip.

### Authors pages:
  * Dunarel Badescu:         https://ca.linkedin.com/pub/dunarel-badescu/26/107/887
  * Vladimir Makarenkov:     http://accueil.labunix.uqam.ca/~makarenkov_v
  * Abdoulaye Banire Diallo: http://ancestors.bioinfo.uqam.ca/BioinfoLab/index.php
  
### Requirements
   * python 2.7, numpy and scipy numerical calculation packages

 
### HGT-QFCLUST contents:

  * README  - This file 
  * [license](license) - Full text of the BSD license (3-clause)
  
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

