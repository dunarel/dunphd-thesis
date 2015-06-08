class ModifyHgtComIntTransferGroups < ActiveRecord::Migration
  def up
    
    remove_index :hgt_com_int_transfer_groups, :source_id
    remove_index :hgt_com_int_transfer_groups, :dest_id
    
    #rename_table :hgt_com_int_transfer_groups, :
    rename_column :hgt_com_int_transfer_groups, :source_id, :prok_group_source_id
    rename_column :hgt_com_int_transfer_groups, :dest_id, :prok_group_dest_id
    
    
    add_index :hgt_com_int_transfer_groups, :prok_group_source_id
    add_index :hgt_com_int_transfer_groups, :prok_group_dest_id
    
    rename_column :hgt_com_int_transfer_groups, :regular_cnt, :cnt
    rename_column :hgt_com_int_transfer_groups, :trivial_cnt, :cnt_rel
    
        
  end

  def down
    
    remove_index :hgt_com_int_transfer_groups, :prok_group_source_id
    remove_index :hgt_com_int_transfer_groups, :prok_group_dest_id
    
       
    rename_column :hgt_com_int_transfer_groups, :prok_group_source_id, :source_id
    rename_column :hgt_com_int_transfer_groups, :prok_group_dest_id, :dest_id
    
    add_index :hgt_com_int_transfer_groups, :source_id
    add_index :hgt_com_int_transfer_groups, :dest_id
    
    rename_column :hgt_com_int_transfer_groups, :cnt, :regular_cnt
    rename_column :hgt_com_int_transfer_groups, :cnt_rel, :trivial_cnt
    
  end
end
