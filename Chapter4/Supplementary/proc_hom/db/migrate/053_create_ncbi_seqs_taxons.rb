class CreateNcbiSeqsTaxons < ActiveRecord::Migration
  def change
    create_table :ncbi_seqs_taxons do |t|
      t.integer :taxon_id
      t.decimal :img_taxon_oid


      t.timestamps
    end
    add_index :ncbi_seqs_taxons, :taxon_id,  :unique => true
    add_index :ncbi_seqs_taxons, :img_taxon_oid,  :unique => true
  end
end
