class MPeriplasmicLoopsExposed < ActiveRecord::Migration
  def self.up


    create_table :periplasmic_loops_exposed do |t|

      t.integer :position
      t.integer :idx_graph_aa_begin
      t.integer :idx_graph_aa_end
      t.integer :idx_seq_aa_begin
      t.integer :idx_seq_aa_end
      t.integer :idx_msa_dna_begin
      t.integer :idx_msa_dna_end


    end

  end

  def self.down
   drop_table :periplasmic_loops_exposed
  end

end