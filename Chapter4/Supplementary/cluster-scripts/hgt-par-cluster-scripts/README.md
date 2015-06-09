This project is extensively using Rake tasks, located in:
chap4-proc_hom/lib/tasks

Associated JRuby classes are in:
chap4-proc_hom/lib

Database migration scripts are located in:
chap4-proc_hom/db/migrate 


1) For the Complete Horizontal Gene Transfer, having a relatively reduced number of genes (110), 
we compacted the execution of multiple serial tasks using "bqsub", a scripting solution developped by MP2 cluster administrators.

2) When enlarging our study to the Partial Horizontal Gene Transfer, we faced an increased number of windows, in the thousands. 
We therefore developed our own task scheduler, to take better advantage of the "qsub" standard submission system and reduce the number of concurrent jobs. These are called: chap4-hgt-par-cluster-scripts/hgt/raxml/exec/sched-jobs-hgt-raxml.rb and chap4-hgt-par-cluster-scripts/hgt/raxml/exec/win-task-hgt-raxml.rb


These are called:
chap4-hgt-par-cluster-scripts/hgt/raxml/exec/sched-jobs-hgt-raxml.rb 
and 
chap4-hgt-par-cluster-scripts/hgt/raxml/exec/win-task-hgt-raxml.rb


### proc_hom

This the Main project used to develop and run:

##### CHAPTER IV of Dunarel Badescu Ph.D. Thesis - UQAM 
##### Complete And Partial Horizontal Gene Transfers At The Core Of Prokaryotic Ecology And Evolution

This is heterogeneous software, using the Ruby on Rails rake build system. 
It uses an HSQLDB database, that it populates using Active Record migrations.

Simulations are run on a remote Compute Canada cluster, then results are recuperated and inserted into the database.
Following aggregation final statistics are exported from the database and graphics are drawn.




Ruby Active Record project is performing simulations of the Q-functions in various evolutionnary conditions.
It uses an [Apache Derby](http://db.apache.org/derby/) database.

It consists of Ruby scripts running in a master/slave configuration.
The controling script running on the master node is [admin/spadb.rb](admin/spadm.rb).

The simulation is also using [create_tree/createTree](create_tree/createTree) for random tree generation.
See:
- Vladimir Makarenkov and Pierre Legendre. 
Journal of Computational Biology. January 2004, 11(1): 195-212. doi:10.1089/106652704773416966. 
  * implemented by Alix Boc - June 2008.

To simulate mutated sequences along branches of the tree we used [Seqgen](http://tree.bio.ed.ac.uk/software/seqgen/).

The main program is [lib/simul_two_subtrees.rb](lib/simul_two_subtrees.rb).

The original binary Linux executable used, compiled with g++ 4.4 is [bin/q_funcb](bin/q_funcb).

### Other qfunc-cluster-simul selected contents:

  * [admin/](admin/) - Cluster task control 
  * [lib/](lib/) - Source code used for performing simulations
  * [migrate/](migrate/) - Active Record Migrations to create the database structures supporting the simulations. 
  
  