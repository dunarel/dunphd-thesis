class AddTaxonIdToTaxonGroups < ActiveRecord::Migration
  def up
   add_column :taxon_groups, :taxon_id, :integer
   add_index  :taxon_groups, :taxon_id 
  end

  def down
   remove_index :taxon_groups, :taxon_id
   remove_column :taxon_groups, :taxon_id
  end

end
