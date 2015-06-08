
This repository releases the source code implementations of the clustering algorithms described in:

## Dunarel Badescu Ph.D. Thesis - [UQAM](http://www.uqam.ca) 2015
### Functional Genomic Region And Horizontal Gene Transfer Detection Using Sequence Variability Clustering: Applications To Viral And Prokaryotic Evolution
#### Supervisor Prof. Vladimir Makarenkov, Co-supervisor Prof. Abdoulaye Banire Diallo, Coauthor: Dr. Alix Boc

There are three __main__ projects, partaining each to one chapter of the thesis. They are working, compilable, and executable, independent software releases.

We also include __supplementary__ projects, those used to develop the current solution and to run simulations.
Some of them may be used independently for similar purposes, as they have their own build system.
Do not expect those to run outside the box, as they are taken out of their original context.


## Chapter III 
### Detecting Genomic Regions Associated With A Disease Using Aggregation Functions And Adjusted Rand Index

[Chapter3/Main/q_funcb/](Chapter3/Main/q_funcb/) is a C++ software implementation of the algorithm for detecting regions associated with a disease.

Refererence:
[Badescu, D., Boc. A., Diallo, A. B., and Makarenkov, V. (2011),
Detecting genomic regions associated with a disease using variability functions and Adjusted Rand Index, BMC Bioinformatics, 12(Suppl 9):S9.
](http://www.biomedcentral.com/1471-2105/12/S9/S9)

---

[Chapter3/Supplementary/q_func_java_ba/](Chapter3/Supplementary/q_func_java_ba/) is an innitial Java implementation of Q-functions without bipartition optimisation.
[Chapter3/Supplementary/q_func_jruby_ba/](Chapter3/Supplementary/q_func_jruby_ba/) is a Ruby wrapper of the above implementation, but more importantly was also used to extract Neisseria frpB outer membrane protein loops coordinates.

Simulations profiling the behaviour of Q-functions under Positive Selection/Lineage Specific Selection and Monophyletic/Polyphyletic conditions were conducted on the Licef Research Centre High Performance Cluster belonging to Universite Teluq.
[Chapter3/Supplementary/qfunc-cluster-simul/](Chapter3/Supplementary/qfunc-cluster-simul/) is the corresponding cluster project used to conduct those simulations.

Results were parsed and graphics drawn using [Chapter3/Supplementary/q_func_ruby_parsing/](Chapter3/Supplementary/q_func_ruby_parsing/).

## Chapter IV 
### Complete And Partial Horizontal Gene Transfers At The Core Of Prokaryotic Ecology And Evolution

[Chapter4/Main/linalgebra_impl/](Chapter4/Main/linalgebra_impl/) is a Python numpy/scipy Linear Algebra implementation of the custom clustering framework 
that we put in place, in order to characterise Complete HGT events, across Prokaryotic Families and Habitats.

Its main purpose is to linearise tree events, between branches, into fragment leaf transfers based on their Most Recent Common Ancestor (MRCA). 
It then reassembles and averages these fragments into major clustering families or groups, according to subgroup memberships. 
One nice property it has, is that the weighted scheme used, allows for having the same Weighted Average value, across classifications, even when one leaf (an Allele in our case) belonging to another subgroup (a Species in our case) belongs to multiple groups (one Habitat in our case). 

---

As this project was developped during several years, we chose the Relational Algebra modeling framework, as Relational Databases allow for explicit control of variable states, and easy debugging.
They also allow for better project extension, due to the connected nature of SQL.

All the algorithms used were either originally parallelized, or they were submited using a parallel task scheduler. 
We also chose HSQLDB, due to its good parallel insert performances.

The Ruby on Rails architecture was chosen due to its Active Record Object Relational Model being a comprehensive framework able to efficiently script third party applications.


Simulations were conducted on the Compute Canada/Calcul Quebec High Performance Cluster Mammouth MP2 at the University of Sherbrooke.
Scripts were used to calculate Maximum Likelihood gene trees, using RAxML and for infering Complete and respectively Partial Gene Transfers on Mammout MP2, using HGT-Detection software.

[Chapter4/Supplementary/cluster-scripts/hgt-com-cluster-scripts/](Chapter4/Supplementary/cluster-scripts/hgt-com-cluster-scripts/) is a collection of scripts used for inferring and dating Complete Gene Transfers.
[Chapter4/Supplementary/cluster-scripts/hgt-par-cluster-scripts/](Chapter4/Supplementary/cluster-scripts/hgt-par-cluster-scripts/) is taking the analysis one step further, into Partial Gene Transfers.




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


## CHAPTER V
### A New Fast Algorithm For Detecting And Validating Horizontal Gene Transfer Events Using Phylogenetic Trees And Aggregation Functions

The C++ code, Makefile, CodeLite Project and example files are located in:
chap5-hgt-qfunc.v.0.5.2

Simulations were done using Chapter IV wrapper Rake scripts, inside:
chap4-proc_hom/lib/tasks/hgt_com.rake



