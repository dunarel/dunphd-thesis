class AddDataToNcbiSeqsTaxons < ActiveRecord::Migration
  def up
    execute "insert into NCBI_SEQS_TAXONS
              (taxon_id)
             select distinct taxon_id
             from NCBI_SEQS
             order by taxon_id"
  end
  
  def down
    execute "delete from NCBI_SEQS_TAXONS"
    
  end
end
