### hgt-par-cluster-scripts

These scripts are used to generate, submit and schedule parallel jobs on the Calcul Quebec MP2 cluster.

- When enlarging our study to the Partial Horizontal Gene Transfer, we faced an increased number of windows, in the thousands. 
We therefore developed our own task scheduler, to take better advantage of the __qsub__ standard submission system and reduce the number of concurrent jobs.

  * For Hgt-Detection, these are composed of:
  [hgt/raxml/exec/sched-jobs-hgt-raxml.rb](hgt/raxml/exec/sched-jobs-hgt-raxml.rb) which schedules tasks.
  [hgt/raxml/exec/win-task-hgt-raxml.rb](hgt/raxml/exec/win-task-hgt-raxml.rb) which executes one task.
 
  * For RAxML, these are composed of:
  [phylo/raxml/exec/sched-jobs-phylo-raxml.rb](phylo/raxml/exec/sched-jobs-phylo-raxml.rb) which schedules tasks.
  [win-task-phylo-raxml.rb](win-task-phylo-raxml.rb) which executes one task.
 
These folder contain the rest of the scripts:
 - [phylo/raxml](phylo/raxml) contains the scripts to run RAxML Maximum Likelihood tree inference.
 - [hgt/raxml/](hgt/raxml/) contains the scripts to run HGT-Detection for HGT inference.

Timing is performed similar to [hgt-com-cluster-scripts](../hgt-com-cluster-scripts):

- [timing](timing) contains the scripts to run TreePL and B.E.A.S.T. for time inference.
They are using our custom Java scheduler [proc-hom-ex](../../proc-hom-ex)
