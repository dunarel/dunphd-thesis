class CreateSimulTestElem < ActiveRecord::Migration
  def self.up
    create_table :simul_test_elem do |t|
         t.float :pval_sup
         t.float :pval_inf
         t.integer :simul_param_id


    end

  end


  def self.down
    drop_table :simul_test_elem
  end
end