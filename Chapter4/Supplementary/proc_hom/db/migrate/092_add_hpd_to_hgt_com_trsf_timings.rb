class AddHpdToHgtComTrsfTimings < ActiveRecord::Migration
  def change
   add_column :hgt_com_trsf_timings, :age_hpd5_wg , :float
   add_column :hgt_com_trsf_timings, :age_hpd95_wg , :float
   add_column :hgt_com_trsf_timings, :age_orig_wg , :float



  end

 
end
