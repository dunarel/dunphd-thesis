class CreateHgtComIntContins < ActiveRecord::Migration
  def change
    create_table :hgt_com_int_contins do |t|
      t.references :gene
      t.integer :iter_no
      t.integer :hgt_no
      t.string :hgt_type
      t.references :hgt_com_int_fragm
      t.text :from_subtree
      t.integer :from_cnt
      t.text :to_subtree
      t.integer :to_cnt
      t.float :bs_val
      t.float :weight
  
      t.timestamps
    end
    add_index :hgt_com_int_contins, :gene_id
    add_index :hgt_com_int_contins, :iter_no
    add_index :hgt_com_int_contins, :hgt_no
    add_index :hgt_com_int_contins, :hgt_type
    add_index :hgt_com_int_contins, :hgt_com_int_fragm_id
    
  end
end
