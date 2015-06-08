class CreateHgtQfuncConds < ActiveRecord::Migration
  def change
    create_table :hgt_qfunc_conds do |t|
      t.string :func
      t.float :pval_max
      t.float :pval_repls
      t.float :bs_min

      #t.timestamps
    end
  end
end
