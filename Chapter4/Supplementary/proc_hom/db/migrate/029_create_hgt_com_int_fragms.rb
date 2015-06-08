class CreateHgtComIntFragms < ActiveRecord::Migration
  def change
    create_table :hgt_com_int_fragms do |t|
      t.references :gene
      t.integer :iter_no
      t.integer :hgt_no
      t.string :hgt_type
      t.text :from_subtree
      t.integer :from_cnt
      t.text :to_subtree
      t.integer :to_cnt
      t.float :bs_val
      t.float :weight_direct
      t.float :weight_inverse

      t.timestamps
    end
    add_index :hgt_com_int_fragms, :gene_id
    add_index :hgt_com_int_fragms, :iter_no
    add_index :hgt_com_int_fragms, :hgt_no
    add_index :hgt_com_int_fragms, :hgt_type
  end

  
end
