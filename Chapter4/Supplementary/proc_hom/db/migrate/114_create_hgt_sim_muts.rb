class CreateHgtSimMuts < ActiveRecord::Migration
  def change
    create_table :hgt_sim_muts do |t|
      t.references :gene
      t.integer :source_id
      t.integer :dest_id
      t.float :val
      t.float :conf
      t.float :weight
      t.integer :rank   
      t.integer :from_cnt
      t.integer :to_cnt
      t.float :age
      t.text :from_subtree
      t.text :to_subtree

      #t.timestamps
    end
    add_index :hgt_sim_muts, :gene_id
  end
end
