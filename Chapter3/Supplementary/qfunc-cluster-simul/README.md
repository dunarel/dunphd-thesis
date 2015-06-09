### qfunc-cluster-simul


This Ruby Active Record project is performing simulations of the Q-functions in various evolutionnary conditions.
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
  
  





