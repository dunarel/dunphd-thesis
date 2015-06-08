require 'hgt_com'

namespace :time_estim_com  do
   

  #SqlInfin
  SqlInfin = 2147483647
 
  desc "default job"
  task :default => :environment do
    puts "running default job"
    
    
    
    hc=Hgt.new :hgt_com
    hc.phylo_prog = "raxml"

    #root input tree from raxml by hgt
    #hc.prepare_all_input_trees

   
    hc.timing_prog = :beast
    #hc.timing_prog = :treepl

    hc.prepare_all_input_files
    #hc.rsync_folder(:work)
    

    #hc.exp_tasks_yaml(20, 100)
    #hc.rsync_folder(:jobs)
    #hc.rsync_folder(:res)
    hc.parse_all_output_files if hc.timing_prog == :beast
    
    
    

    

    #debug
    #hc.test_time_estim()


    
  end


  task :rsync  => :environment do


    hc=Hgt.new :hgt_com
    hc.phylo_prog = "raxml"

    #hc.timing_prog = :beast
    hc.timing_prog = :treepl


    hc.rsync_proc_hom_ex

    #hc.rsync_jobs_folder()
    #hc.rsync_folder(:work)
    #hc.rsync_res_folder()

    #hc.rsync_folder(:jobs)
    #hc.rsync_folder(:res)


  end

  task :test   => :environment do


    puts "testing..."

  end

end
