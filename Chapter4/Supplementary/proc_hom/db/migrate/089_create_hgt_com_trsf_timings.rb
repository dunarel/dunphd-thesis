class CreateHgtComTrsfTimings < ActiveRecord::Migration
  def change
    create_table :hgt_com_trsf_timings do |t|
      t.references :timing_criter
      t.references :hgt_com_int_transfer
      t.float :age_md_wg

      t.timestamps
    end
    add_index :hgt_com_trsf_timings, :timing_criter_id
    add_index :hgt_com_trsf_timings, :hgt_com_int_transfer_id
  end
end
