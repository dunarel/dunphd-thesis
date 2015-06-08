class MMsaDnaPosSeqDnaPos < ActiveRecord::Migration
  def self.up


    create_table :msa_dna_pos_seq_dna_pos do |t|
      t.integer :msa_dna_pos_id
      t.integer :seq_dna_pos_id
      t.string :align

    end

  end

  def self.down
   drop_table :msa_dna_pos_seq_dna_pos
  end

end
