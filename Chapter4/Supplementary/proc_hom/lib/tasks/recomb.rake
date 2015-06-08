
require 'recomb'

namespace :recomb  do
   

  desc "recomb default"
  task :default => :environment do
   puts "in recomb:default.."
   
   
 
   #wr.sequences
   #rec.scan_gene_blo_seqs
   
   
    #[:regular,:all].each { |htype|
    [:regular, :all].each { |htype|
      #["phyml","raxml"].each { |ml| 
      ["geneconv"].each { |ml| 
        #[75,50].each { |th|
        [0].each { |th|
        
          #specific 
          rec = Recomb.new(htype, ml, th)
          rec.recomb_run
          rec.prepare_recomb_gene_groups_vals()
          
          #rec.transfer_groups()
          
          rec.calc_transf_stats()
         
      
          #[:family,:habitat].each {|crit|
          [:habitat, :family].each {|crit|
    
            rec.crit=(crit)
            #take ids and len for crit
            rec.calc_mat_stats()
            
            rec.calc_relative_values_for_crit()
             
            [:abs,:rel].each {|ct|
            #[:rel].each {|ct|
            
              rec.calc_type = ct
              # calculate values to export
              rec.calc_exp_transf_gr_mat_data
              rec.calc_transf_gr_mat_sums
              
              rec.calc_mat_local_stats() #to review
                
              #export files
              rec.export_transfer_groups_matrix_tex
              rec.exp_transf_gr_heatmap_gp
         
            }
   
       
          }
        }
      }
  
    }
    puts "ok.default"
   
    
  end
    
end
