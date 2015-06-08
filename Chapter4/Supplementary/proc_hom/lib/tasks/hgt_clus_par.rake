require 'hgt'

namespace :hgt_clus_par  do


  #SqlInfin
  SqlInfin = 2147483647

  desc "default job"
  task :default => :environment do
    puts "running default job"

    hp=Hgt.new :hgt_par
    hp.phylo_prog = "raxml"

    #--------------------------  phylo  ------------------------------------------

    #hp.calc_section = :phylo

    #hp.hgt_type = :all
    #hp.thres = 50
    #hp.scan_hgt_par_fens()
    
    #hp.section_prep_all_inp_files(:alix_design)
    #hp.section_prep_all_inp_files(:phylo_err_nocalc)
    #hp.section_rsync_folder(:work)
    #hp.section_exp_tasks_yaml(66, 100, "alix_design")
    #hp.section_rsync_folder(:exec)
    #hp.section_rsync_folder(:jobs)
   
    #hp.section_rsync_folder(:res)
   
    #hp.section_parse_all_out_files()
    #
    #hp.rsync_proc_hom_ex()
    #hp.timing_prog = :beast
    #hp.timing_prog = :treepl

    #--------------------- hgt ------------------------------------

    #hp.calc_section = :hgt
    #should be based on fen_stages table
    #hp.fen_stage = 2
    #hp.prev_fen_stage = 1

    #hp.section_prep_all_inp_files()

    #hp.section_rsync_folder(:work)

    #hp.update_sel_from_status("hgt_err_nocalc")
    #hp.section_exp_tasks_yaml(20, 100, "hgt_err_nocalc")

    #hp.section_rsync_folder(:jobs)
    #
    #hp.section_rsync_folder(:exec)
    

    #hp.section_rsync_folder(:res)



    #hp.section_parse_all_out_files()


    #hp.rsync_proc_hom_ex()

    #-----------------------timing ----------------------------------------

    hp.calc_section = :timing
    #should be based on fen_stages table
    hp.fen_stage = 4 #4 = beast  
   
    #hp.fen_stage = 3 #3=treepl 
    hp.prev_fen_stage = 2  #same previous 2

    #root input tree from raxml by hgt
    #hp.prepare_all_input_trees(:reg75)

    hp.timing_prog = :beast
    #hp.timing_prog = :treepl



    #hp.section_prep_all_inp_files(:reg75)
    #hp.section_rsync_folder(:work)

    #hp.update_sel_from_status(hp.prev_fen_stage,"reg75")
    #hp.section_exp_tasks_yaml(20, 100, "reg75")
    #hp.section_rsync_folder(:jobs)

    #hp.section_rsync_folder(:res)
    hp.section_parse_all_out_files(:reg75)






  end

  
end

