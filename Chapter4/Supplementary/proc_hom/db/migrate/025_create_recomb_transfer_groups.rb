class CreateRecombTransferGroups < ActiveRecord::Migration
  def up
    create_table :recomb_transfer_groups do |t|
      t.integer :source_id
      t.integer :dest_id
      t.float :certif_cnt
      t.float :all_cnt
      t.float :length_avg

      t.timestamps
    end
    add_index :recomb_transfer_groups, :source_id
    add_index :recomb_transfer_groups, :dest_id
  end

  def down
   drop_table :recomb_transfer_groups
  end
end
