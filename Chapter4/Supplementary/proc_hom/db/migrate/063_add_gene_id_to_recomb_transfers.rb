class AddGeneIdToRecombTransfers < ActiveRecord::Migration
  def up
   add_column :recomb_transfers, :gene_id, :integer
   add_index  :recomb_transfers, :gene_id
  end
  
  def down
    remove_index :recomb_transfers, :gene_id
    remove_column :recomb_transfers, :gene_id
  end
  
end
