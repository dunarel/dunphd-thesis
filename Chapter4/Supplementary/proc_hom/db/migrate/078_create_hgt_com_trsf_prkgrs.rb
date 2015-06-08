class CreateHgtComTrsfPrkgrs < ActiveRecord::Migration
  def change
    create_table :hgt_com_trsf_prkgrs do |t|
      t.references :gene
      t.references :trsf_taxon
      t.references :pgsrc
      t.references :pgdst
      t.float :weight_tr_pg

      t.timestamps
    end
    add_index :hgt_com_trsf_prkgrs, :gene_id
    add_index :hgt_com_trsf_prkgrs, :trsf_taxon_id
    add_index :hgt_com_trsf_prkgrs, :pgsrc_id
    add_index :hgt_com_trsf_prkgrs, :pgdst_id
  end
end
