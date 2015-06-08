class CreateTreeGroupsHgts < ActiveRecord::Migration
  def change
    create_table :tree_groups_hgts do |t|
      t.integer :prok_group_source_id
      t.integer :prok_group_dest_id
      t.float :val1
      t.float :val2

      t.timestamps
    end
  end
end
