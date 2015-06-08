class CreateHgtQfuncStats < ActiveRecord::Migration
  def change
    create_table :hgt_qfunc_stats do |t|
      t.references :hgt_qfunc_cond
      t.references :gene
      t.float :true_pos
      t.float :false_pos
      t.float :true_neg
      t.float :false_neg
      t.float :sensit
      t.float :specif
      t.float :ppv
      t.float :npv
      t.float :lrt_pos
      t.float :lrt_neg
      t.float :rbo

      #t.timestamps
    end
    add_index :hgt_qfunc_stats, :hgt_qfunc_cond_id
  end
end
