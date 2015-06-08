class CreateGeneMsaRuns < ActiveRecord::Migration
  def change
    create_table :gene_msa_runs do |t|
      t.references :gene
      t.references :msa_run
      t.integer :oa_length

      t.timestamps
    end
    add_index :gene_msa_runs, :gene_id
    add_index :gene_msa_runs, :msa_run_id
  end
end
