require 'hgt'

namespace :hgt_tot  do
   
 
 
  desc "default job"
  task :default, [:thres] => :environment do |task, args|
 
    do_core = false
    #do calculations for graphs
    do_calc_normal_graphs = true
    #export heatmaps and matrices
    do_export_normal_graphs = true
    
    #Rails.logger.level = 0
    #["phyml","raxml"].each { |ml|
    ["raxml"].each { |ml|
      #[:regular,:all].each { |htype|
      [:regular].each { |htype|
   
        #[75,50].each { |th|
       [args.thres.to_i].each { |th|
        
               
          #operations :sum_weight,:count_col
          hc=Hgt.new :hgt_tot
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
              
                hc.exp_transf_gr_total_one_dim_csv if ct == :rel
              }



            }
          end #end do_export_normal_graphs
      
                

        
        }
  
      }

    }

    puts "ok"
   
   
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


end
