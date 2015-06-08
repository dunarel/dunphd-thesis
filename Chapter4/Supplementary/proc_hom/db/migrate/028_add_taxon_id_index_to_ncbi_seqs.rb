class AddTaxonIdIndexToNcbiSeqs < ActiveRecord::Migration
  def change
    add_index :ncbi_seqs, :taxon_id 
  end
end
