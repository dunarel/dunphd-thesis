class MSeqAaPos < ActiveRecord::Migration
  def self.up


    create_table :seq_aa_pos do |t|
      t.integer :seq_aa_id
      t.integer :idx
      t.string :symbol
    
    end

  end

  def self.down
   drop_table :seq_aa_pos
  end

end
