class CreateHgtComIntTransfers < ActiveRecord::Migration
  def change
    create_table :hgt_com_int_transfers do |t|
      t.integer :source_id
      t.integer :dest_id
      t.references :hgt_com_int_fragm
      t.float :length
      t.float :confidence
      t.float :weight

      t.timestamps
    end
    add_index :hgt_com_int_transfers, :hgt_com_int_fragm_id
  end
end
