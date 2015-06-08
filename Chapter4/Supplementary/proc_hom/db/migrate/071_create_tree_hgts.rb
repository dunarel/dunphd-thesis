class CreateTreeHgts < ActiveRecord::Migration
  def change
    create_table :tree_hgts do |t|
      t.string :cin_node_name
      t.string :rgb_hex
      t.string :name
      t.string :val1
      t.string :val2

      t.timestamps
    end
  end
end
