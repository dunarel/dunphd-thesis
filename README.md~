# Dunarel Badescu PhD Thesis

This repository releases the source code implementations of the clustering algorithms described in Dunarel Badescu PhD Thesis (Universite du Quebec a Montreal).
There are three __main__ projects, partaining each to one chapter of the thesis. They are working, compilable, and executable, independent software releases.

We also include __supplementary__ projects, those used to develop the current solution and to run simulations.
Some of them may be used independently for similar purposes, as they have their own build system.


# Chapter III 
## Detecting Genomic Regions Associated With A Disease Using Aggregation Functions And Adjusted Rand Index

This software implments the algorithm for detecting regions associated with a disease.
[Chapter3/Main/q_funcb](Chapter3/Main/q_funcb)

Refererence:
Badescu, D., Boc. A., Diallo, A. B., and Makarenkov, V. (2011), Detecting genomic regions associated with a disease using variability functions and Adjusted Rand Index, BMC Bioinformatics, 12(Suppl 9):S9.




Simulations profiling the behaviour of Q-functions under Positive Selection/Lineage Specific Selection and Monophyletic/Polyphyletic conditions were conducted on the Licef Research Centre High Performance Cluster belonging to Université Teluq.

The project code that was used is located in folowing folder: 
chap3-qfunc-cluster-simul
It consists of Ruby scripts running in a master/slave configuration.

The controling script running on the master node is admin/spadb.rb.

The original source code implementation of Q-functions, used at that time is found in q_funcb folder.
It is a Netbeans IDE project, compiled with g++ 4.4
The binary Linux executable used is simul_ruby/bin/q_funcb.

The simulation is also using simul_ruby/create_tree/createTree for random tree generation:
see Vladimir Makarenkov and Pierre Legendre. 
Journal of Computational Biology. January 2004, 11(1): 195-212. doi:10.1089/106652704773416966. 
implemented by Alix Boc - June 2008.

To simulate mutated sequences along branches of the tree we used:
Seqgen
http://tree.bio.ed.ac.uk/software/seqgen/

The simul_ruby/lib folder contains the Ruby scripts used for the simulations.

These were inserted into an Apache Derby database.
See http://db.apache.org/derby/. 

Active Record migration scripts are provided to recreate the database structures supporting the simulations.
They are found in the simul_ruby/migrate folder.

In addition to the original Q-function implementation, we are providing the most up to date C++ version of the software that we posess, in chap3-qfuncp.v.0.9 folder.

A Makefile is provided for compilation on Linux 64 bit architectures.



# Chapter IV 
## Complete And Partial Horizontal Gene Transfers At The Core Of Prokaryotic Ecology And Evolution


Our statistical framework and its application on clustering Complete and partial HGT events, across Prokaryotic Families, Habitats and Historical Age, was developped during several years. In order to explicitely control species and alleles behaviour, and to tame the project growing complexity, we used at its center a Relational Database, and its Relational Algebra paradigm. We chose HSQLDB, due to its good parallel insert performances.

The Ruby on Rails architecture was chosen due to its Active Record Object Relational Model being a comprehensive framework able to efficiently script third party applications.

The Project folder containing the custom code to start and stop the database is located at:
chap4-db_srv

The main locally executing project scripts are located in: 
chap4-proc_hom

This project is extensively using Rake tasks, located in:
chap4-proc_hom/lib/tasks

Associated JRuby classes are in:
chap4-proc_hom/lib

Database migration scripts are located in:
chap4-proc_hom/db/migrate 

Simulations were conducted on the Compute Canada/Calcul Quebec High Performance Cluster Mammouth MP2 at the University of Sherbrooke.
Those scripts used to calculate Maximum Likelihood gene trees, using RAxML and for infering Complete and respectively Partial Gene Transfers on Mammout MP2, using HGT-Detection are located in folowing folders:

chap4-hgt-com-cluster-scripts
chap4-hgt-par-cluster-scripts



1) For the Complete Horizontal Gene Transfer, having a relatively reduced number of genes (110), we compacted the execution of multiple serial tasks using "bqsub", a scripting solution developped by MP2 cluster administrators. 

2) When enlarging our study to the Partial Horizontal Gene Transfer, we faced an increased number of windows, in the thousands.
We therefore developed our own task scheduler, to take better advantage of the "qsub" standard submission system and reduce the number of concurrent jobs.
These are called:
chap4-hgt-par-cluster-scripts/hgt/raxml/exec/sched-jobs-hgt-raxml.rb 
and 
chap4-hgt-par-cluster-scripts/hgt/raxml/exec/win-task-hgt-raxml.rb



3) Later we added a Timing Step, which was done using TreePL and B.E.A.S.T. each, for both the Complete and Partial transfers.
When applying time constraints on gene trees, some of them were not mutually compatible. As TreePL, one of the simulation software that we used was not handling these conflicting constraints, we developped a separate Java Netbeans project, able to handle managed execution.
It is found in:
chap4-proc_hom/ex_projects/proc-hom-ex/

This Java application, dynamically runs successive instances of TreePL, and changes parameters as the software crashes.


All these 3 stages have a different project structure.

4) After running the simulations on the remote cluster, we performed an aggregating step, on the local computer, which required the use of an NVIDIA Graphic Card, and JavaCL/OpenCL parallelizing software, for the Partial Horizontal Gene Transfer.

We developed a custom Java Stored Procedure, that recover transfers from their multiple superposing window fragments by calculating Connected Components inside a Graph, based on Jaccard distance.

This is a Java Netbeans IDE project at following location:
chap4-proc_hom/ex_projects/proc-hom-ex/

We also provide the code used to ensure orthology, as one of our earlier steps in validating the Multiple Sequence Alignemnts.
We were doing reciprocal BLAST hits, and clustering using TribeMCL, in a separate project: 
chap4-tribemcl


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


# CHAPTER V
## A New Fast Algorithm For Detecting And Validating Horizontal Gene Transfer Events Using Phylogenetic Trees And Aggregation Functions

The C++ code, Makefile, CodeLite Project and example files are located in:
chap5-hgt-qfunc.v.0.5.2

Simulations were done using Chapter IV wrapper Rake scripts, inside:
chap4-proc_hom/lib/tasks/hgt_com.rake



