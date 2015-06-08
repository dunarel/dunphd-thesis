
require 'manage_data'


namespace :data  do

   

  desc "launch default task"
  task :default => :environment do
   
    md = ManageData.new
    #md.update_taxon_groups_weight_pg()
    #md.reload_gene_group_cnts()
    #md.update_all_mrca_tables()
    #md.update_fen_stages_table()
    md.update_group_criters_table()
    
    
  end



end