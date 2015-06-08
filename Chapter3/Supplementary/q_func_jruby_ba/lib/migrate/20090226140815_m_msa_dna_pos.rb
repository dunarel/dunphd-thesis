class MMsaDnaPos < ActiveRecord::Migration
  def self.up


    create_table :msa_dna_pos do |t|
      t.integer :msa_dna_id
      t.integer :idx
      t.string :symbol

    end

  end

  def self.down
   drop_table :msa_dna_pos
  end

end
