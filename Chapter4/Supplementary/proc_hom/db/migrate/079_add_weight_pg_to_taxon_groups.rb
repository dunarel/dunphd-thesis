class AddWeightPgToTaxonGroups < ActiveRecord::Migration


  #remember to rake data:default
  # md = ManageData.new
  # md.update_taxon_groups_weight_pg()
  #  md.reload_gene_group_cnts()
  
  def up
    add_column :taxon_groups, :weight_pg, :float
    
  end
  
  def down
    remove_column :taxon_groups, :weight_pg
    
  end
  

  
end
