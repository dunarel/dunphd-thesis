class AddValRelToTransferGroupTables < ActiveRecord::Migration
def up
    add_column :hgt_com_int_transfer_groups, :val_rel, :float
    add_column :hgt_par_transfer_groups, :val_rel, :float

  end

  def down
    remove_column :hgt_com_int_transfer_groups, :val_rel
    remove_column :hgt_par_transfer_groups, :val_rel

  end
end
