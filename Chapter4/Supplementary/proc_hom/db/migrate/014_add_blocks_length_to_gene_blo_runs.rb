class AddBlocksLengthToGeneBloRuns < ActiveRecord::Migration
  def change
    add_column :gene_blo_runs, :blocks_length, :integer

  end
end
