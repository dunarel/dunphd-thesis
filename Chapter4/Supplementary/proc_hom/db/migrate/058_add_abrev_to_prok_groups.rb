class AddAbrevToProkGroups < ActiveRecord::Migration
  def change
   add_column :prok_groups, :abrev, :string
   add_index  :prok_groups, :abrev, :unique => true
  end
end

