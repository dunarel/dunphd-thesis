class UpdateImgTaxonOidInNcbiSeqsTaxons < ActiveRecord::Migration
  def up
    [[649633055,693745], [650716060,1048245]].each { |tx|

  
   execute "update ncbi_seqs_taxons
            set img_taxon_oid = #{tx[0]}
            where taxon_id = #{tx[1]}"

    }

  end

  def down
  
  end

  
end
