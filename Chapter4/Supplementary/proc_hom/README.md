This project is extensively using Rake tasks, located in:
chap4-proc_hom/lib/tasks

Associated JRuby classes are in:
chap4-proc_hom/lib

Database migration scripts are located in:
chap4-proc_hom/db/migrate 


1) For the Complete Horizontal Gene Transfer, having a relatively reduced number of genes (110), we compacted the execution of multiple serial tasks using "bqsub", a scripting solution developped by MP2 cluster administrators.

2) When enlarging our study to the Partial Horizontal Gene Transfer, we faced an increased number of windows, in the thousands. We therefore developed our own task scheduler, to take better advantage of the "qsub" standard submission system and reduce the number of concurrent jobs. These are called: chap4-hgt-par-cluster-scripts/hgt/raxml/exec/sched-jobs-hgt-raxml.rb and chap4-hgt-par-cluster-scripts/hgt/raxml/exec/win-task-hgt-raxml.rb

1) For the Complete Horizontal Gene Transfer, having a relatively reduced number of genes (110), we compacted the execution of multiple serial tasks using "bqsub", a scripting solution developped by MP2 cluster administrators. 

2) When enlarging our study to the Partial Horizontal Gene Transfer, we faced an increased number of windows, in the thousands.
We therefore developed our own task scheduler, to take better advantage of the "qsub" standard submission system and reduce the number of concurrent jobs.
These are called:
chap4-hgt-par-cluster-scripts/hgt/raxml/exec/sched-jobs-hgt-raxml.rb 
and 
chap4-hgt-par-cluster-scripts/hgt/raxml/exec/win-task-hgt-raxml.rb


