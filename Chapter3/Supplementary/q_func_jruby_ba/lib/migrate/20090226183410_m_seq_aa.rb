class MSeqAa < ActiveRecord::Migration
  def self.up
    create_table :seq_aa do |t|
      t.integer :length
      t.text :seq
    end


  end

  def self.down
    drop_table :seq_aa

  end

end