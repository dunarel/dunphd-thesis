class AddTreeOrderToTaxons < ActiveRecord::Migration
  def up
   add_column :taxons, :tree_order, :integer
  end
  
  def down
  remove_column :taxons, :tree_order
  end
  
end
