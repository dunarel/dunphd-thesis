class AddOrderIdToProkGroups < ActiveRecord::Migration
  def change
     add_column :prok_groups, :order_id, :integer
  end
end
