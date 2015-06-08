class CreateHgtParTrsfTimings < ActiveRecord::Migration
def change
    create_table :hgt_par_trsf_timings do |t|
      t.references :timing_criter
      t.references :hgt_par_transfer
      t.float :age_md_wg
      t.float :age_hpd5_wg
      t.float :age_hpd95_wg
      t.float :age_orig_wg

      t.timestamps
    end
    add_index :hgt_par_trsf_timings, :timing_criter_id
    add_index :hgt_par_trsf_timings, :hgt_par_transfer_id
  end
end
