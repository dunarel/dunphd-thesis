class CreateHgtComTrsfTaxons < ActiveRecord::Migration
  def change
    create_table :hgt_com_trsf_taxons do |t|
      t.references :gene
      t.references :txsrc
      t.references :txdst
      t.float :weight_tr_tx

      t.timestamps
    end
    add_index :hgt_com_trsf_taxons, :gene_id
    add_index :hgt_com_trsf_taxons, :txsrc_id
    add_index :hgt_com_trsf_taxons, :txdst_id
    
    
  end
end
