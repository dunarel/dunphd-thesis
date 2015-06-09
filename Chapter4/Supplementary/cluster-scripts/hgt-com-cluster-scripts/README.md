### hgt-com-cluster-scripts

These scripts are used to generate and submit parallel jobs on the Calcul Quebec MP2 cluster.

- [gene_blo_seqs_raxml](gene_blo_seqs_raxml/) contains the script to run RAxML Maximum Likelihood tree inference. 
As this version is already parallelized using threads, we used the regular __qsub__ submission.

- [hgt-com-raxml](hgt-com-raxml/) contains the scripts to run HGT-Detection for HGT inference. 
As this version is serial, we are packing jobs using the __bqsub__ submission scripts, developed by the MP2 Cluster team.

- [timing](timing) contains the scripts to run TreePL and B.E.A.S.T. for time inference.
They are using our custom Java scheduler [proc-hom-ex](../proc-hom-ex)

  
