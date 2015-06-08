class MSeqDna < ActiveRecord::Migration
  def self.up
    create_table :seq_dna do |t|
      t.integer :length
      t.text :seq
    end


  end

  def self.down
    drop_table :seq_dna

  end

end