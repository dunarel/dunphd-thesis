
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

Simulations profiling the behaviour of Q-functions under Positive Selection/Lineage Specific Selection and Monophyletic/Polyphyletic conditions 
were conducted on the [Licef Research Centre](http://www.licef.ca) High Performance Cluster (HPC) belonging to Universite Teluq. 
[Chapter3/Supplementary/qfunc-cluster-simul/](Chapter3/Supplementary/qfunc-cluster-simul/) is the corresponding cluster project used to conduct those simulations.

Results were parsed and graphics drawn using [Chapter3/Supplementary/q_func_ruby_parsing/](Chapter3/Supplementary/q_func_ruby_parsing/).

## Chapter IV 
### Complete And Partial Horizontal Gene Transfers At The Core Of Prokaryotic Ecology And Evolution

[Chapter4/Main/linalgebra_impl/](Chapter4/Main/linalgebra_impl/) is a Python numpy/scipy Linear Algebra software implementation of the custom clustering framework 
that we put in place, in order to characterise Complete HGT events, across Prokaryotic Families and Habitats.

Its main purpose is to linearise tree events, between branches, into fragment leaf transfers based on their Most Recent Common Ancestor (MRCA). 
It then reassembles and averages these fragments into major clustering families or groups, according to subgroup memberships. 
One nice property it has, is that the weighted scheme used, allows for having the same Weighted Average value, across classifications, even when one leaf (Allele in our case) belonging to another subgroup (Species in our case) belongs to multiple groups (Habitats in our case). 

---

As this project was developped during several years, we chose the Relational Algebra modeling framework, knowing that Relational Databases allow for explicit control of variable states, and easy debugging.
They also allow for better project extension, due to the connected nature of SQL.
All the algorithms used were either originally parallelized, or they were submited using a parallel task scheduler, either the one provided by the cluster system (for Complete HGT) or our own (for Partial HGT). 

We also chose HSQLDB, due to its good parallel insert performances.
[Chapter4/Supplementary/db_scripts/](Chapter4/Supplementary/db_scripts/) contain the scripts used to configure and launch the database.

The Ruby on Rails architecture was chosen due to its Active Record Object Relational Model being a comprehensive framework able to efficiently script third party applications.
[Chapter4/Supplementary/proc_hom/](Chapter4/Supplementary/proc_hom/) is the main Ruby on Rails project, also containing database migrations, and models. 

Simulations were conducted on the Compute Canada/Calcul Quebec [Mammouth MP2 HPC](http://www.calculquebec.ca/en/resources/compute-servers/mammouth-parallele-ii) at the University of Sherbrooke.
Scripts were used to calculate Maximum Likelihood gene trees, using [RAxML](http://sco.h-its.org/exelixis/web/software/raxml/index.html) and for infering Complete and respectively Partial Gene Transfers, using [HGT-Detection](http://www.trex.uqam.ca/index.php?action=hgt).

[Chapter4/Supplementary/cluster-scripts/hgt-com-cluster-scripts/](Chapter4/Supplementary/cluster-scripts/hgt-com-cluster-scripts/) is a collection of scripts used for inferring and dating Complete Gene Transfers.
[Chapter4/Supplementary/cluster-scripts/hgt-par-cluster-scripts/](Chapter4/Supplementary/cluster-scripts/hgt-par-cluster-scripts/) is taking the analysis one step further, into Partial Gene Transfers.

Timing was done using TreePL and B.E.A.S.T. each, for both the Complete and Partial transfers.
When applying time constraints on gene trees, some of them were not mutually compatible. 
TreePL, one of the simulation software that we used, was not handling these conflicting constraints.
[Chapter4/Supplementary/proc-hom-ex/](Chapter4/Supplementary/proc-hom-ex/) is a Java Netbeans project, able to handle managed execution.

After running the simulations on the remote cluster, we performed an aggregating step, on the local computer.
We accelerated Partial HGT recovering of transfers, from their multiple superposing window fragments, by calculating Connected Components inside a Graph, based on Jaccard distance.
[Chapter4/Supplementary/proc-hom-sp/](Chapter4/Supplementary/proc-hom-sp/) is a custom JavaCL/Java Stored Procedure.
It uses the OpenCL heterogeneous parallelizing framework, on an NVIDIA Graphic Card. 

One of our earlier steps is validating the Multiple Sequence Alignments, ensuring orthology.
This is where the name of our project initially came from: __proc_hom__ i.e. __Proc__ ariotic __Hom__ ology.
[Chapter4/Supplementary/tribemcl/](Chapter4/Supplementary/tribemcl/) is a _bash_ script, doing reciprocal BLAST hits, and clustering using TribeMCL.


## CHAPTER V
### A New Fast Algorithm For Detecting And Validating Horizontal Gene Transfer Events Using Phylogenetic Trees And Aggregation Functions

[Chapter5/Main/hgt-qfunc.v.0.5.2/](Chapter5/Main/hgt-qfunc.v.0.5.2/) is a C++ software implementation of the Fast HGT detection algorithm, using Q-functions.
It is OpenMP parallelized and SSE vectorized.

Simulations were performed using Chapter IV wrapper Rake scripts, inside:
[Chapter4/Supplementary/proc_hom/lib/tasks/hgt_com.rake](Chapter4/Supplementary/proc_hom/lib/tasks/hgt_com.rake).



