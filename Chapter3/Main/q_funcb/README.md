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

   0-6 Q0-Q6
   
2. (--msa-fasta)
   A multiple sequence alignment fo the gene in FASTA format. 
  
3. (--align_type)

-  dna for DNA alignements.
-  protein is nonpublished and experimental
      it comes with other undocumented options:
  * --protmatrix: blosum80,blosum62
  * --dist: scoredist
   
4. (--calc_type)
   
-    auto is the option used to optimize the bipartition
   
5. (--x_ident_csv)
   
-   list of identifiers belonging to the X group (carcinogenic, invasive).
   
6. (--winl):
-   Length of the Multiple sequence alignment
   
7. (--win_step)
  
-    Number of nucleotides for sliding the window.

8. (--q_func_csv):
   The name of the resulting file in csv format. 
   
   Format is:
    win_length,x,dXY,dXY_inv,vX,vX_inv,vY,vY_inv,Q0,Q1,Q2,Q3,Q4,Q5,Q6,Q7,nx,ny,gap_prop,A_dXY,A_dXY_inv,A_vX,A_vX_inv,A_vY,A_vY_inv,A_Q0,A_Q1,A_Q2,A_\
Q3,A_Q4,A_Q5,A_Q6,A_Q7,A_nx,A_ny,A_rand_idx,A_adj_rand_idx,A_ham_idx

    functions prepended with A_ meaning _automatic_, optimised bipartition
    functions prepended wit Q meaning Q functions, without bipartition optimisation
    A_adj_rand_idx is the Adjuste Rand Index while A_ham_idx is the undocumented Hamming Index
  
9. (--dist)
   
-   ham - Hamming distance
-   scoredist - used for protein scoring - undocumented
   
   
10. (--optim)
-    km -  k-means type of optimisation, default, used throughout the article and applications
-    nj	- experimental, unpublished, based on Neighbor Joining bipartitions, faster, less accurate
    
### Example:

-   [example/hpv_e6/](example/hpv_e6/) An example of execution, using HPV alignement is given in.
-   [example/neiss/](example/neiss/) Another is given for Neisseria meningitidis

### Feedback and bug reports:
   Feedback is welcomed: dunarel(at)gmail(dot)com.

