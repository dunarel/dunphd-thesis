class CreateHgtComGeneGroupsVals < ActiveRecord::Migration
  def change
    create_table :hgt_com_gene_groups_vals do |t|
      t.references :gene
      t.references :prok_group_source
      t.references :prok_group_dest
      t.float :val

      t.timestamps
    end
    add_index :hgt_com_gene_groups_vals, :gene_id
    add_index :hgt_com_gene_groups_vals, :prok_group_source_id
    add_index :hgt_com_gene_groups_vals, :prok_group_dest_id
  end
end
