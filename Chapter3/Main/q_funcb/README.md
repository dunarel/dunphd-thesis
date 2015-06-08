### QFUNC v.0.5


This software implements the algorithm for detecting regions associated with a disease. described in:

[Badescu, D., Boc. A., Diallo, A. B., and Makarenkov, V. (2011),
Detecting genomic regions associated with a disease using variability functions and Adjusted Rand Index, BMC Bioinformatics, 12(Suppl 9):S9.
](http://www.biomedcentral.com/1471-2105/12/S9/S9)

###### Copyright (C) 2015 Dunarel Badescu, Alix Boc, Abdoulaye Banire Diallo and Vladimir Makarenkov

### Licence 
   This software is distributed according to the BSD license (3-clause version).

### Authors pages:
  * Dunarel Badescu:         https://ca.linkedin.com/pub/dunarel-badescu/26/107/887
  * Vladimir Makarenkov:     http://accueil.labunix.uqam.ca/~makarenkov_v
  * Abdoulaye Banire Diallo: http://ancestors.bioinfo.uqam.ca/BioinfoLab/index.php
  * Alix Boc:                https://ca.linkedin.com/in/alixboc		
  
### Requirements
   * gcc/g++ and BOOST C++ libraries (they are present with major Linux package managers)

### Dependencies (found in [deps/](deps/) folder)

  * [tclap](http://tclap.sourceforge.net/)
    Templatized C++ Command Line Parser Library
    
### How to build code?
  * make TARGET=debug clean
  * make TARGET=debug 
  
    install gcc/g++ and BOOST using either yum, zypper on workstations, or module load commands on clusters.
 
### QFUNC contents:

  * README  - This file 
  * [license](license) - Full text of the BSD license (3-clause)
  
  * [src/main.cpp](src/main.cpp) - Main program
  * [src/q_func_hgt_appl.cpp](src/q_func_hgt_appl.cpp) - Application container
  * [src/q_func_hgt.cpp](src/q_func_hgt.cpp) - Application code
  * [src/aligned_storage.hpp](src/aligned_storage.hpp) - Aligned matrix class to use for fast vector operations
  
  
### Usage:
   
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
   An example of execution, using HPV alignement is given in.

### Feedback and bug reports:
   Feedback is welcomed: dunarel(at)gmail(dot)com.

