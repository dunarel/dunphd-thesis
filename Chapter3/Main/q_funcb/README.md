## QFUNC v.0.5

   Dunarel Badescu Ph.D. Thesis, UQAM 2015
   
   Supervisor Prof. Vladimir Makarenkov
   Co-supervisor Prof. Abdoulaye Baniré Diallo
   Coauthor: Dr. Alix Boc
   
 Title:
   FUNCTIONAL GENOMIC REGION AND HORIZONTAL GENE TRANSFER DETECTION 
   USING SEQUENCE VARIABILITY CLUSTERING: APPLICATIONS TO VIRAL AND PROKARYOTIC EVOLUTION
 see Chapter III:
   A NEW FAST ALGORITHM FOR DETECTING AND VALIDATING HORIZONTAL GENE TRANSFER EVENTS 
   USING PHYLOGENETIC TREES AND AGGREGATION FUNCTIONS

## Copyright (C) 2015 Dunarel Badescu, Alix Boc, Abdoulaye Banire Diallo and Vladimir Makarenkov

## Licence 
   This software is distributed according to the BSD license (3-clause version).

   Our most recent implementation is available at the following URL address:
   http://www.info2.uqam.ca/~makarenkov_v/Qfunc.zip.

### Authors pages:
   Dunarel Badescu:         https://ca.linkedin.com/pub/dunarel-badescu/26/107/887
   Vladimir Makarenkov:     http://accueil.labunix.uqam.ca/~makarenkov_v
   Abdoulaye Banire Diallo: http://ancestors.bioinfo.uqam.ca/BioinfoLab/index.php
   Alix Boc: 
  
### Requirements
   * gcc/g++ and BOOST C++ libraries (they are present with major Linux package managers)

### Dependencies (found in deps folder)
  *(tclap)
    Templatized C++ Command Line Parser Library
    http://tclap.sourceforge.net/
  

### How to build code?
  * make TARGET=debug clean
  * make TARGET=debug 
  
    install gcc/g++ and BOOST using either yum, zypper on workstations, or module load commands on clusters.


### QFUNC contents:

  * README  - This file 
  * license - Full text of the BSD license (3-clause)

  * src/main.cpp - Main program
  * src/q_func_hgt_appl.cpp - Application container
  * src/q_func_hgt.cpp - Application code
  
  
  
### Usage:
   We provide a binary Linux executable, compiled on the Compute Quebec/Canada Cluster Guillimin, using g++ and BOOST using:
   module load gcc
   module load BOOST
   make TARGET=debug clean
   make TARGET=debug

   The executable name is: hgt-qfunc-deb 
   Parameters are:
 
 1) (--f_opt_max)
   Function index:

   1 Q7a (eq 5.21) -> Q7 in graphics
   2 Q8a (eq 5.22)
   3 Q8b (eq 5.23)
   4 Q9a (eq 5.24) -> Q9 in graphics

 2) (--msa-fasta):
   A multiple sequence alignment fo the gene in FASTA format. 
   Parser is basic, so make sure the name contains only the identifier.
   
 3) (--winl):
   Length of the Multiple sequence alignment

 4) (--gr-seqs-csv):
   A file in csv format, detailing which sequence belongs to which group.
   The header is of this format:
   "","PROK_GROUP_ID","NCBI_SEQ_ID"
   "1",1,15608435
 
 5) (--q-func-hgts-csv):
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

