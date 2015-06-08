require 'hgt_com'

namespace :time_estim_par  do
   

  #SqlInfin
  SqlInfin = 2147483647
 
  desc "default job"
  task :default => :environment do
    puts "running default job"
    
    

    hp=Hgt.new :hgt_par
    #hp.rsync_proc_hom_ex()

    hp.phylo_prog = "raxml"
    hp.timing_prog = :beast
    #hp.timing_prog = :treepl


    #hp.prepare_all_input_files
    #hp.rsync_folder(:work)




    #global procedure now
    #not anymore on one gene


   #tasks = hp.tasks_already_worked_out
   #puts "tasks: #{tasks.inspect}"
   #puts tasks.length
    
    #batch dim, index_start, win_size
    #hp.exp_tasks_yaml(20, 300, 50)
    #hp.rsync_folder(:jobs)

    #hp.rsync_folder(:res)

    #hp.parse_all_output_files


  
     
  end

  task :rsync  => :environment do


    hp = HgtPar.new()
    hp.phylo_prog = "raxml"
    hp.timing_prog = :treepl

    hp.rsync_folder(:jobs)
    #hp.rsync_work_folder()
    #hp.rsync_res_folder()


  end

 
end
  
