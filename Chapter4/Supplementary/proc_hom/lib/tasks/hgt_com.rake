require 'hgt'

namespace :hgt_com  do
   
 
 
  desc "default job[thres]"
  task :default, [:thres] => :environment do |task, args|
 
    do_core = false
    #do calculations
    do_calc_transfers = true
    #do calculations for graphs
    do_calc_normal_graphs = true
    #export heatmaps and matrices
    do_export_normal_graphs = true
    #export timing
    do_export_timing_graphs = false
  
    #Rails.logger.level = 0
    #["phyml","raxml"].each { |ml|
    ["raxml"].each { |ml|
      #[:regular,:all].each { |htype|
      [:regular].each { |htype|
   
        #[75,50].each { |th|
        #[75].each { |th|
        #puts args.inspect
        [args.thres.to_i].each { |th|
          #[0].each { |th|
        
               
          #operations :sum_weight,:count_col
          hc = Hgt.new :hgt_com
          if do_core
            hc.genes_switch_core() 
          else
            hc.genes_switch_ubiq()          
          end
          hc.phylo_prog = ml
          

          #equivalent to former init_base_transfer(hgt_type, thres, one_dim_op)
          hc.hgt_type = htype
          hc.thres = th
          hc.one_dim_op = :sum_weight

        
    
          if do_calc_transfers
            
            hc.timing_needed = false
            #equivalent to hp.treat_values()
            hc.treat_fragms()

            #
            hc.elim_trivial_intra()
            #specific join
            hc.prepare_hgt_com_trsf_taxons()
         
            #common
            hc.prepare_hgt_trsf_prkgrs()
            
            
            hc.prepare_gene_groups_vals()
          
           
          end
          
          
          if do_calc_normal_graphs
            #hc.transfer_groups()
          
            #load arrays in memory for fast access to
            #@arGeneGroupsVal
            #@arGeneGroupCnt
            hc.calc_transf_stats()
            [:family,:habitat].each {|crit|
              #[:family].each {|crit|

              hc.crit=(crit)
              #take ids and len for crit
              hc.calc_mat_stats()
              hc.calc_exp_relative_values_for_crit()
            }
          end
          
          #procaryotes general hgt rate
          #hc.calc_global_hgt_rate()
          
          if do_export_normal_graphs
            [:family,:habitat].each {|crit|
              #[:family].each {|crit|
              hc.crit=(crit)
              #take ids and len for crit
              hc.calc_mat_stats()
              
              hc.load_tr_mtx_for_crit()
              


              #[:abs,:rel].each {|ct|
              [:rel].each {|ct|


                hc.calc_type = ct

                # calculate values to export
                hc.calc_exp_transf_gr_mat_data
                
                #new two times normalized weighted mean
                hc.calc_transf_gr_mat_sums

                hc.gn_mt_min_th = 0
                hc.calc_transf_gr_total_one_dim

                hc.calc_mat_local_stats() #to review


                #export files
                #hc.export_transfer_groups_matrix_tex
                hc.export_transfer_groups_matrix_xls
             


                #hc.exp_transf_gr_heatmap_gp_pdf
                hc.exp_transf_gr_heatmap_gp_svg
                #hc.exp_transf_gr_heatmap_gp_png_emf
                #only one of
                #alternative using table data
                #hc.export_transfer_groups_totals_csv
               
                # alternative unsing only one dimension
                hc.exp_transf_gr_total_one_dim_csv if ct == :rel

              }



            }
          end #end do_export_normal_graphs
      
          if do_export_timing_graphs 
            #timing
            [:timing].each {|crit|
    
              hc.crit=(crit)

              hc.exp_age_transfers_csv
              #hc.exp_age_transfers_bp
              #hc.exp_age_transfers_kn
              #groups for histograms
              [200,250,300,350,400,450,500].each {|st|
                hc.hg_step = st
               
                hc.exp_age_trsf_gr_csv
                hc.exp_age_transfers_hg
               
              }
              #hc.exp_age_transfers_qq




              
            }
          end
              


           

        
        }
  
      }

    }

    puts "ok.default"
   
   
  end
  
  
  desc "correct old data"
  task :correct_data => :environment do
   
    md = ManageData.new
    md.reload_gene_group_cnts()
    
    puts "reloaded gene_group_cnts()..."
    sleep 10
    
    

  end
  
  
  desc "test"
  task :test => :environment do
    
    sql = "select count(distinct ht.source_id) as nb
             from HGT_COM_INT_TRANSFERS ht
              join HGT_COM_INT_FRAGMS hcf on hcf.ID = ht.HGT_COM_INT_FRAGM_ID
              join NCBI_SEQS ns_src on ns_src.id = ht.SOURCE_ID
              join TAXON_GROUPS tg_src on tg_src.TAXON_ID = ns_src.TAXON_ID
              join NCBI_SEQS ns_dest on ns_dest.id = ht.DEST_ID
              join TAXON_GROUPS tg_dest on tg_dest.TAXON_ID = ns_dest.TAXON_ID
             where hcf.GENE_ID = 111 and
                   tg_src.PROK_GROUP_ID = 8"
    puts "sql: #{sql}"
    
    
    
    hc=HgtCom.new(:all, "raxml", 50)
    hc.test
     
    #sql2 = HgtComIntTransfer.join(:hgt_com_int_fragms)
    
    
    
    #
    
    
    
  end
  
  desc "hgt_all"
  task :hgt_all => :environment do
    
    thres_a = [90,75,50]
            
    3.times { |idx|  
      
      #com
      Rake::Task["hgt_com:default"].invoke(thres_a[idx])
      Rake::Task["hgt_com:default"].reenable
      #par
      Rake::Task["hgt_par:default"].invoke(thres_a[idx])
      Rake::Task["hgt_par:default"].reenable
    
      
    }
             
    
  end

  
  
  

  desc "qfunc_stat"
  task :qfunc_stat => :environment do
    
    #thres_a = [90,75,50]
    thres_a = [90]
    rows_limit_a = [100,200,300]
        
    1.times { |idx|  
      
      #com
      Rake::Task["hgt_com:default"].invoke(thres_a[idx])
      Rake::Task["hgt_com:default"].reenable
      #par
      Rake::Task["hgt_par:default"].invoke(thres_a[idx])
      Rake::Task["hgt_par:default"].reenable
    
      #
         
      q_func_a = [7,8,9,11]
    
      q_func_a.each {|qf|
        Rake::Task["hgt_com:qfunc_stat_one"].invoke(qf,rows_limit_a[idx])
        Rake::Task["hgt_com:qfunc_stat_one"].reenable
        #
        #raise "stop"
      }
      
    #generate plot data
    hc=Hgt.new :hgt_com
    hc.sim_thres = thres_a[idx]
    hc.gen_proj3_stat_plot_data()
    #hc.gen_proj3_stat_plot()
    
      #raise "stop"
      
    }
    
          
    
  end

  desc "qfunc_stat_one"
  task :qfunc_stat_one, [:q_func, :rows_limit] => :environment do |task, args|
    
    #operations :sum_weight,:count_col
    hc=Hgt.new :hgt_com
          
    #hc.phylo_prog = ml
    #
    #     hc.hgt_type = htype
    #     hc.thres = th
    #     hc.one_dim_op = :sum_weight
     
    hc.qfunc_f_opt_max =args.q_func
    hc.sim_max_pval = 0.05  #1.0
    
    hc.sim_order_by = :vals #:pvals #:pvals # :vals
    hc.sim_rows_limit = args.rows_limit
    
    hc.calc_hgt_q_func_genes()
    hc.stat_hgt_q_func_genes()
    
    
    
  end
  
  desc "qfunc_stat_graphs"
  task :qfunc_stat_graphs => :environment do
    
    #operations :sum_weight,:count_col
     #generate plot data
    hc=Hgt.new :hgt_com
    hc.gen_proj3_stat_plot()
    
  end
  
  
  desc "qfunc_simul"
  task :qfunc_simul => :environment do |task, args|
    

   #rake seeder:seed[2,0]
   
   #nb_seqs_a = [1,2,4,8,16,32,64,128]
   nb_seqs_a = [128]
    #perc_recomb_a = [0,0.25,0.5]
    perc_recomb_a = [0,0.25,0.50]
 
    nb_seqs_a.each {|ns|
                  
      perc_recomb_a.each {|pr|
        Rake::Task["hgt_com:qfunc_simul_one"].invoke(ns, pr)
        Rake::Task["hgt_com:qfunc_simul_one"].reenable
        
        #Rake.application. invoke_task("hgt_com:qfunc_simul_one[#{ns}, #{pr}]")
      }
    }
    
     
  end
  
  
  
  
  

  desc "qfunc_simul_one"
  task :qfunc_simul_one, [:nb_seqs,:perc_recomb] => :environment do |task, args|

    puts "Args were: #{args}"
    puts ":nb_seqs: #{args.nb_seqs}"
    puts ":perc_recomb: #{args.perc_recomb}"
    
    
    
    sleep 5
    #operations :sum_weight,:count_col
    hc=Hgt.new :hgt_com
    #hc.qfunc_f_opt_max = 2
    hc.sim_max_pval = 0.05 #1.0
    #hc.sim_perc_recomb = 0.50
    hc.sim_perc_recomb = args.perc_recomb.to_f
    hc.sim_align_type = :original #:original/:seqgen
    hc.sim_order_by = :vals #:pvals # :vals
    
    hc.sim_nb_seqs = args.nb_seqs.to_i
    #2 times more rows 
    hc.sim_rows_limit = hc.sim_nb_seqs * 2
    hc.sim_nb_perms = 50
    
    hc.gene = Gene.find(163)
    
    
    HgtSimCond.delete_all
    HgtSimPerm.delete_all
    HgtSimPermStat.delete_all
    #gene and nb of transfers
   
    hsc = hc.create_hgt_sim_cond(163, hc.sim_nb_seqs)
    puts "hsc: #{hsc.inspect}"
    
    
    
    hc.gen_all_perms_for_cond(hsc.id)
    hc.gen_proj3_sim_plots_data
    
    
    
    
     
  end
  
  desc "qfunc_simul_graphs"
  task :qfunc_simul_graphs => :environment do
    
    #operations :sum_weight,:count_col
    hc=Hgt.new :hgt_com
   
    hc.gen_proj3_sim_plots()
    
    
  end
  
  
  desc "qfunc_palmer"
  task :qfunc_palmer => :environment do
    
    #operations :sum_weight,:count_col
    hc=Hgt.new :hgt_com
          
    #hc.phylo_prog = ml
    #
    #     hc.hgt_type = htype
    #     hc.thres = th
    #     hc.one_dim_op = :sum_weight
     
    #hc.qfunc_f_opt_max = 4
    #hc.max_pval = 0.01
    
    #hc.calc_hgt_q_func_genes()
    #hc.stat_hgt_q_func_genes()
    hc.palmer_delete()
    
    hc.palmer_data()
    hc.palmer_q_func_gene()
    hc.palmer_q_func_exec()
    hc.palmer_fix_species_tree()
    
    
    
    
    
  end
  
  desc "qfunc_graph"
  task :qfunc_graph => :environment do
    
        
       
    #hc.calc_hgt_q_func_genes()
    #hc.stat_hgt_q_func_genes()
   
    
    
    #do calculations
    do_calc_transfers = false
    #do calculations for graphs
    do_calc_normal_graphs = false
    #export heatmaps and matrices
    do_export_normal_graphs = false
   

    #operations :sum_weight,:count_col
    hc=Hgt.new :hgt_com
    
    hc.max_pval = 0.001
    #hc.qfunc_f_opt_max = 2
          
    hc.phylo_prog = "raxml"
          

    #equivalent to former init_base_transfer(hgt_type, thres, one_dim_op)
    hc.hgt_type = :regular
    hc.thres = 50
    hc.one_dim_op = :sum_weight

        
    if do_calc_transfers
            
      hc.timing_needed = false
   
      #insert all transfers
      hc.treat_qfunc_transfers()
    
      
      #specific join
      hc.prepare_hgt_com_qfunc_trsf_taxons()
            
      #common
      hc.prepare_qfunc_hgt_trsf_prkgrs()
            
            
      hc.prepare_gene_groups_vals()
    end       
           
    if do_calc_normal_graphs
      #hc.transfer_groups()
          
      #load arrays in memory for fast access to
      #@arGeneGroupsVal
      #@arGeneGroupCnt
      hc.calc_transf_stats()
      
      hc.crit=(:family)
      #take ids and len for crit
      hc.calc_mat_stats()
      hc.calc_exp_relative_values_for_crit()
      
    end
          
    #procaryotes general hgt rate
    #hc.calc_global_hgt_rate()
          
    if do_export_normal_graphs
      hc.crit=(:family)
      #take ids and len for crit
      hc.calc_mat_stats()
              
      hc.load_tr_mtx_for_crit()
              


      hc.calc_type = :rel

      # calculate values to export
      hc.calc_exp_transf_gr_mat_data
                
      #new two times normalized weighted mean
      hc.calc_transf_gr_mat_sums

      hc.gn_mt_min_th = 0
      hc.calc_transf_gr_total_one_dim

      hc.calc_mat_local_stats() #to review


      #export files
      #hc.export_transfer_groups_matrix_tex
      hc.export_transfer_groups_matrix_xls
             


      #hc.exp_transf_gr_heatmap_gp_pdf
      #hc.exp_transf_gr_heatmap_gp_svg
      hc.exp_transf_gr_heatmap_gp_png_emf
      #only one of
      #alternative using table data
      #hc.export_transfer_groups_totals_csv
               
      # alternative unsing only one dimension
      hc.exp_transf_gr_total_one_dim_csv

        



      
    end #end do_export_normal_graphs
          
    
     
    
  end
  
  
end
