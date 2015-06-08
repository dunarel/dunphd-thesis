class CreateMrcaProkGroups < ActiveRecord::Migration
  def change
    create_table :mrca_prok_groups do |t|
      t.references :mrca
      t.references :prok_group

      t.timestamps
    end
    add_index :mrca_prok_groups, :mrca_id
    add_index :mrca_prok_groups, :prok_group_id
  end
end
