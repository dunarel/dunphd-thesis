class AddAgeToManyTables < ActiveRecord::Migration
  def change

    #com tables
     add_column :hgt_com_int_contins, :from_age, :float
     add_column :hgt_com_int_contins, :to_age, :float
     add_column :hgt_com_int_contins, :age_md, :float
     add_column :hgt_com_int_transfers, :age_md_wg, :float
     add_column :hgt_com_trsf_taxons, :age_md_wg_tr_tx, :float
     add_column :hgt_com_trsf_prkgrs, :age_md_wg_tr_pg, :float
    

    #par tables
     add_column :hgt_par_contins, :from_age, :float
     add_column :hgt_par_contins, :to_age, :float
     add_column :hgt_par_contins, :age_md, :float
     add_column :hgt_par_transfers, :age_md_wg, :float
     add_column :hgt_par_trsf_taxons, :age_md_wg_tr_tx, :float
     add_column :hgt_par_trsf_prkgrs, :age_md_wg_tr_pg, :float



     
  end
end
