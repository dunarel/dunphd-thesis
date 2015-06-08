class RestructureCriterProkGroups < ActiveRecord::Migration
  def up
    add_column :prok_groups, :group_criter_id, :integer
    add_index :prok_groups, :group_criter_id
    self.class.insert_data()
    
    #
    add_index :prok_groups, :order_id
  end
  
  def down
    remove_index :prok_groups, :group_criter_id
    remove_column :prok_groups, :group_criter_id
    #
    remove_index :prok_groups, :order_id
   
  end
  
  def self.insert_data()
    execute "update prok_groups
             set group_criter_id = 0"
  end
end
