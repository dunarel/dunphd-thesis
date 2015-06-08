class CreateHgtParTransferGroups < ActiveRecord::Migration
  def change
    create_table :hgt_par_transfer_groups do |t|
      t.integer :prok_group_source_id
      t.integer :prok_group_dest_id
      t.float :cnt
      t.float :cnt_rel
      t.float :length

      t.timestamps
    end
    add_index :hgt_par_transfer_groups, :prok_group_source_id
    add_index :hgt_par_transfer_groups, :prok_group_dest_id
    
  end
end
