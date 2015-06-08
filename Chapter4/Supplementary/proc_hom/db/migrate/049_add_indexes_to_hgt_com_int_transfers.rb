class AddIndexesToHgtComIntTransfers < ActiveRecord::Migration
def up
  add_index :hgt_com_int_transfers, :source_id
  add_index :hgt_com_int_transfers, :dest_id
end

def down
 remove_index :hgt_com_int_transfers, :source_id
 remove_index :hgt_com_int_transfers, :dest_id

end

end
