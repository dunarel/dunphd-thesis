
require 'hgt'

namespace :hgt_par  do
   

  #SqlInfin
  SqlInfin = 2147483647
 
  desc "default job[thres]"
  task :default, [:thres] => :environment do |task, args|
    puts "running default job"
    
    #import dataset
    #do_dataset_import = false
    
    do_core = false
    #do calculations
    do_calc_transfers = true
    #do calculations for graph
    do_calc_normal_graphs = true
    
    #export dataset
    #do_dataset_export = false
    
    
    #export heatmaps and matrices
    do_export_normal_graphs = true
    #export timing
    do_export_timing_graphs = false


    # for each phylogenetic method
    ["raxml"].each { |ml|


      #[:regular, :all].each { |htype|
      [:regular].each { |htype|
      
        #[50,75].each { |th|
        [args.thres.to_i].each { |th|

      
          #operations :sum_weight,:count_col
          #fragm_thres = 10, epsilon_sim_frag = 0.75, epsilon_dist_frag = 10
     
          #hp=HgtPar.new(htype, ml, th, :sum_weight, 10, 0.75, 2147483647)
          #hp=HgtPar.new(htype, ml, th, :sum_weight, 10, 0.75, 0)
          
          #hp=HgtPar.new(htype, ml, th, :sum_weight, 10, 0.999, SqlInfin)

          hp=Hgt.new :hgt_par
          if do_core
            hp.genes_switch_core() 
          else
            hp.genes_switch_ubiq()          
          end
          hp.phylo_prog = ml

          #equivalent to former init_base_transfer(hgt_type, thres, one_dim_op)
          hp.hgt_type = htype
          hp.thres = th
          hp.one_dim_op = :sum_weight



          #former hp.init_hgt_par(10, 0.75, SqlInfin)
          hp.fragm_thres = 10
          hp.epsilon_sim_frag = 0.75
          hp.epsilon_dist_frag = SqlInfin

          #from hgt_clus_par
          hp.calc_section = :hgt
          #should be based on fen_stages table
          hp.fen_stage = 2
          hp.prev_fen_stage = 1
          
          
          #if do_dataset_import
          #  hp.dataset_import
          #end      
          
          
          if do_calc_transfers
            #old data
             #hp.import_fragms_by_gene()
            #new data
             hp.import_fragms_by_fens()

            #old method
             #hp.contin_realign_fragms_javacl_med()
            #new method
             hp.contin_realign_fragms_javacl_max()

             #hp.contin_fragms()
             #hp.realign_fragms()
            
            
            #
            hp.elim_trivial_intra()
            
            #specific join
            hp.prepare_hgt_par_trsf_taxons()
            #common
            hp.prepare_hgt_trsf_prkgrs()
            hp.prepare_gene_groups_vals()
          end
          
          #debugging outside
           
           
          
        
          
          
          
          #if do_dataset_export
          #  hp.dataset_export
          #end      
          
          
          if do_calc_normal_graphs
              #hp.transfer_groups()
          
            #load arrays in memory for fast access to
            #@arGeneGroupsVal
            #@arGeneGroupCnt
            hp.calc_transf_stats()
            [:family,:habitat].each {|crit|
              #[:family].each {|crit|

              hp.crit=(crit)
              #take ids and len for crit
              hp.calc_mat_stats()
              hp.calc_exp_relative_values_for_crit()
            }
          end
          
          
          #procaryotes general hgt rate
          #hp.calc_global_hgt_rate()
          
          
          if do_export_normal_graphs
            [:family,:habitat].each {|crit|
            #[:family].each {|crit|
    
              hp.crit=(crit)
              #take ids and len for crit
              hp.calc_mat_stats()
            
              hp.load_tr_mtx_for_crit()
              
             
              #[:abs,:rel].each {|ct|
              [:rel].each {|ct|
            
                hp.calc_type = ct
                
                # calculate values to export
                hp.calc_exp_transf_gr_mat_data
                hp.calc_transf_gr_mat_sums
                
                hp.gn_mt_min_th = 0
                hp.calc_transf_gr_total_one_dim
                
              
                hp.calc_mat_local_stats() #to review
                
                #export files
                 #hp.export_transfer_groups_matrix_tex
                 hp.export_transfer_groups_matrix_xls

                 #hp.exp_transf_gr_heatmap_gp_pdf
                 hp.exp_transf_gr_heatmap_gp_svg
                 #hp.exp_transf_gr_heatmap_gp_png_emf
              
                #only one of
                #alternative using table data
                #hp.export_transfer_groups_totals_csv
                # alternative unsing only one dimension
                hp.exp_transf_gr_total_one_dim_csv if ct == :rel
              
                #only for :family and :relative
              
                #only after complete transfer has run
                #exports both complete and partial values
                hp.export_hgts_ink if crit == :family and ct == :rel
         
              }
   
       
            }
          end #do_export_normal_graphs

          
          if do_export_timing_graphs

          #calculate timings
          hp.load_hgt_par_framgs_timings
          hp.insert_hgt_par_trsf_timings
          hp.elim_invalid_timings

            #timing
            [:timing].each {|crit|

              hp.crit=(crit)

              #hp.exp_age_transfers_csv
              #hp.exp_age_transfers_bp
              #hp.exp_age_transfers_kn
              #groups for histograms
              [200,250,300,350,400,450,500].each {|st|
                hp.hg_step = st
               
               hp.exp_age_trsf_gr_csv
               hp.exp_age_transfers_hg
              }
              
              #hp.exp_age_transfers_qq
              
              

            }
          end
        
      
        }
       
      }
     
    }
   
   
  end

  task :test   => :environment do
 
   
    hp=HgtPar.new(:raxml,50)

    
    #first = ["1, 3, 5", "4, 6"]
    #sec = ["5, 1, 3", "6, 8" ]
    #puts hp.inspect
    #hp.jaccard_sim_coef(first,sec)
   
    hp.construct_graph
   
   
  end

  task :sp   => :environment do
 
   
    hp=HgtPar.new(:regular, "raxml", 75, 10, 0.75, 10)
    hp.test_sp2()
    hp.test_sp3()
    
    
   
  end
  
end
