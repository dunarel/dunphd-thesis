class CreateGeneGroupCnts < ActiveRecord::Migration
 def change
    create_table :gene_group_cnts do |t|
      t.references :gene
      t.references :prok_group
      t.string :name
      t.float :cnt

      t.timestamps
    end
    add_index :gene_group_cnts, :gene_id
    add_index :gene_group_cnts, :prok_group_id
  end
end
