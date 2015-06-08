class CreateQFuncCsv < ActiveRecord::Migration
  def self.up

 #"win_length", "x", "dXY", "dXY_inv", "vX", "vX_inv", "vY", "vY_inv", "Q0", "Q1", "Q2", "Q3", "Q4", "nx", "ny", "gap_prop", "A_dXY", "A_dXY_inv", "A_vX", "A_vX_inv", "A_vY", "A_vY_inv", "A_Q1", "A_nx", "A_ny", "A_rand_idx", "A_adj_rand_idx", "A_ham_idx"
    create_table :q_func_csv do |t|
         t.integer :win_start
         t.float :q_func

    end

  end


  def self.down
    drop_table :q_func_csv
  end
end