class RestructRecombTransferGroups < ActiveRecord::Migration
 def up
    
    remove_index :recomb_transfer_groups, :source_id
    remove_index :recomb_transfer_groups, :dest_id
    
    #rename_table :hgt_com_int_transfer_groups, :
    rename_column :recomb_transfer_groups, :source_id, :prok_group_source_id
    rename_column :recomb_transfer_groups, :dest_id, :prok_group_dest_id
    
    
    add_index :recomb_transfer_groups, :prok_group_source_id
    add_index :recomb_transfer_groups, :prok_group_dest_id
    
    rename_column :recomb_transfer_groups, :certif_cnt, :cnt
    rename_column :recomb_transfer_groups, :all_cnt, :cnt_rel
    
        
  end

  def down
    
    remove_index :recomb_transfer_groups, :prok_group_source_id
    remove_index :recomb_transfer_groups, :prok_group_dest_id
    
       
    rename_column :recomb_transfer_groups, :prok_group_source_id, :source_id
    rename_column :recomb_transfer_groups, :prok_group_dest_id, :dest_id
    
    add_index :recomb_transfer_groups, :source_id
    add_index :recomb_transfer_groups, :dest_id
    
    rename_column :recomb_transfer_groups, :cnt, :certif_cnt
    rename_column :recomb_transfer_groups, :cnt_rel, :all_cnt
    
  end
  
end
