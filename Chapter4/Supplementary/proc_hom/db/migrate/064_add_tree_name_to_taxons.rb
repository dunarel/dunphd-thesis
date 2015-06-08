class AddTreeNameToTaxons < ActiveRecord::Migration
  def up
   add_column :taxons, :tree_name, :string
  end
  
  def down
  remove_column :taxons, :tree_name
  end
end
