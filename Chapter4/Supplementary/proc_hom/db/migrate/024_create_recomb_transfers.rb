class CreateRecombTransfers < ActiveRecord::Migration
  def up
    create_table :recomb_transfers do |t|
      t.integer :source_id
      t.integer :dest_id
      t.float :length
      t.float :confidence

      t.timestamps
    end
    add_index :recomb_transfers, :source_id
    add_index :recomb_transfers, :dest_id
  end

  def down
    drop_table :recomb_transfers
  end
end
