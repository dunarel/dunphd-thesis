### proc_hom

This the Main project used to develop and run:

##### CHAPTER IV of Dunarel Badescu Ph.D. Thesis - UQAM 
##### Complete And Partial Horizontal Gene Transfers At The Core Of Prokaryotic Ecology And Evolution

This is heterogeneous software, using the Ruby on Rails rake build system. 

This project is extensively using Rake tasks, located in [lib/tasks/](lib/tasks/).
The main tasks are:
- [lib/tasks/hgt_com.rake](lib/tasks/hgt_com.rake) Complete HGT Detection
- [lib/tasks/hgt_par.rake](lib/tasks/hgt_par.rake) Partial HGT Detection
- [lib/tasks/hgt_tot.rake](lib/tasks/hgt_tot.rake) Complete and Partial HGT Detection
- [lib/tasks/hgt_clus.rake](lib/tasks/hgt_clus.rake) Running synthetic results, like those combining Complete and Partial HGT
- [lib/tasks/hgt_clus_par.rake](lib/tasks/hgt_clus_par.rake) Manages communication with the Cluster results.

Associated JRuby classes are in [lib/](lib/).

It uses an HSQLDB database, that it populates using Active Record migrations, located in [db/migrate](db/migrate).

Simulations are run on a remote Compute Canada cluster, then results are recuperated and inserted into the database.
Following aggregation final statistics are exported from the database and graphics are drawn.

### Other proc_hom selected contents:

  * [app/](app/) - Rails Object Relational Models
  * [config/](config/) - Rails configurations
  * [core_files/](core_files/) - R scripts to work with core genes.
  * [db/exports/](db/exports/) - Postprocessing of results using graphical scripts, essentially gnuplot and R.
  * [nbproject/](nbproject/) - Netbeans IDE build system
  * [r_lang/](r_lang/) - R Server scripts (RServ). This is used to calculate some of the histograms used for time inference. 
  It is communicating live with the Ruby scripts, using a binary protocol. We also provide scripts to start the server in daemon mode.
  * [sessions/](sessions/) - This is a large collection of unstructures SQL snippets used during development.
  
  
  
