class AddNbGenesRelToTransferGroups < ActiveRecord::Migration
  def up
    add_column :hgt_com_int_transfer_groups, :nb_genes_rel, :float
    add_column :hgt_par_transfer_groups, :nb_genes_rel, :float
  end
  
  def down
    remove_column :hgt_com_int_transfer_groups, :nb_genes_rel
    remove_column :hgt_par_transfer_groups, :nb_genes_rel
  end
end
