class CreateSimulParamResult < ActiveRecord::Migration
  def self.up
    create_table :simul_param_result do |t|
         t.integer :simul_param_id
         t.float :pval_sup_q0
         t.float :pval_sup_q25
         t.float :pval_sup_q50
         t.float :pval_sup_q75
         t.float :pval_sup_q100
         t.float :pval_inf_q0
         t.float :pval_inf_q25
         t.float :pval_inf_q50
         t.float :pval_inf_q75
         t.float :pval_inf_q100
         t.float :pred_val_ppv01
         t.float :pred_val_ppv05

    end

  end


  def self.down
    drop_table :simul_param_result
  end
end
