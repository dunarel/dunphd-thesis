class MSeqDnaPos < ActiveRecord::Migration
  def self.up


    create_table :seq_dna_pos do |t|
      t.integer :seq_dna_id
      t.integer :idx
      t.string :symbol
      t.integer :seq_aa_pos_id

    end

  end

  def self.down
   drop_table :seq_dna_pos
  end

end
