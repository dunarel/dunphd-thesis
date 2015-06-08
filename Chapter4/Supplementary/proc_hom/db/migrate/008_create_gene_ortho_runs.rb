class CreateGeneOrthoRuns < ActiveRecord::Migration
  def change
    create_table :gene_ortho_runs do |t|
      t.references :gene
      t.references :ortho_run
      t.integer :oa_first_clust_cnt

      t.timestamps
    end
    add_index :gene_ortho_runs, :gene_id
    add_index :gene_ortho_runs, :ortho_run_id
  end
end
