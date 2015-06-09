### qfunc-cluster-simul


This Ruby Active Record project is performing simulations of the Q-functions in various evolutionnary conditions.

It consists of Ruby scripts running in a master/slave configuration.

The controling script running on the master node is [admin/spadb.rb](admin/spadb.rb).

The simulation is also using [create_tree/createTree](create_tree/createTree) for random tree generation.
See:
- Vladimir Makarenkov and Pierre Legendre. 
Journal of Computational Biology. January 2004, 11(1): 195-212. doi:10.1089/106652704773416966. 
implemented by Alix Boc - June 2008.

To simulate mutated sequences along branches of the tree we used [Seqgen](http://tree.bio.ed.ac.uk/software/seqgen/).

The main program is: 
simul_two_subtrees.rb

The original binary Linux executable used, compiled with g++ 4.4 is [bin/q_funcb](bin/q_funcb).


The simul_ruby/lib folder contains the Ruby scripts used for the simulations.

These were inserted into an Apache Derby database.
See http://db.apache.org/derby/. 

Active Record migration scripts are provided to recreate the database structures supporting the simulations.
They are found in the [migrate](migrate) folder.


### q_func_jruby_ba selected contents:

  * [lib/](lib/) - Source code 
  * [lib/migrate/](lib/migrate/) - Migrations to create the database. 
  
  * [gnu_plot/](gnu_plot/) and [gnu_plot2/](gnu_plot2/) - Gnuplot graphics
  * [nbproject/](nbproject/) - Netbeans IDE build system
  * [files/](files/) - Program input/output
  

  





