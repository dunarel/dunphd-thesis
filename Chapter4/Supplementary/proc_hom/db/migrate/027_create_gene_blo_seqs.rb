class CreateGeneBloSeqs < ActiveRecord::Migration
  def up
    create_table :gene_blo_seqs do |t|
      t.references :ncbi_seq
      t.references :gene

      t.timestamps
    end
    add_index :gene_blo_seqs, :ncbi_seq_id
    add_index :gene_blo_seqs, :gene_id
  end

  def down
   drop_table :gene_blo_seqs
  end
end
