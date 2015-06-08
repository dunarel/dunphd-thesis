class AddNamesNodesColorToProkGroups < ActiveRecord::Migration
def up
   add_column :prok_groups, :legacy_name, :string
   add_column :prok_groups, :cin_node_name, :string
   add_column :prok_groups, :ext_node_name, :string
   add_column :prok_groups, :color_id, :integer
   add_index  :prok_groups, :color_id
  end
  
  def down
  remove_column :prok_groups, :legacy_name
  remove_column :prok_groups, :cin_node_name
  remove_column :prok_groups, :ext_node_name
  remove_index :prok_groups, :color_id
  remove_column :prok_groups, :color_id
  end
end
