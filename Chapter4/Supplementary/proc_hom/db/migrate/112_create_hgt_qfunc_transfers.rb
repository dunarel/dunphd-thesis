class CreateHgtQfuncTransfers < ActiveRecord::Migration
  def change
    create_table :hgt_qfunc_transfers do |t|

      t.integer :gene_id
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
      
    end
  end
end
