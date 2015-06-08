class CreateGeneOrthoRunSeqs < ActiveRecord::Migration
  def change
    create_table :gene_ortho_run_seqs do |t|
      t.references :gene_seq
      t.references :gene_ortho_run
      t.integer :clust_nb

      t.timestamps
    end
    add_index :gene_ortho_run_seqs, :gene_seq_id
    add_index :gene_ortho_run_seqs, :gene_ortho_run_id
  end
end
