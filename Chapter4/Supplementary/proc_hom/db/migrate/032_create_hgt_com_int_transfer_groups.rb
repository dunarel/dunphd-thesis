class CreateHgtComIntTransferGroups < ActiveRecord::Migration
  def change
    create_table :hgt_com_int_transfer_groups do |t|
      t.integer :source_id
      t.integer :dest_id
      t.float :regular_cnt
      t.float :trivial_cnt

      t.timestamps
    end
    add_index :hgt_com_int_transfer_groups, :source_id
    add_index :hgt_com_int_transfer_groups, :dest_id
  end
end
