class CreateGeneBloRuns < ActiveRecord::Migration
  def change
    create_table :gene_blo_runs do |t|
      t.references :gene
      t.references :blo_run
      t.integer :oa_length

      t.timestamps
    end
    add_index :gene_blo_runs, :gene_id
    add_index :gene_blo_runs, :blo_run_id
  end
end
