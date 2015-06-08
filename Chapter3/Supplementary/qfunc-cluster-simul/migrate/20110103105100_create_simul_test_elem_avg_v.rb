class CreateSimulTestElemAvgV < ActiveRecord::Migration
  def self.up
=begin
    sql = "create view simul_test_elem_avg_v as
           select test_name,
                  test_ident,
                  nb_replic,
                  nb_species,
                  f_opt_max,
                  scaling_factor0,
                  scaling_factor1,
                  scaling_factor2,
                  avg(pval_sup) as avg_pval_sup,
                  avg(pval_inf) as avg_pval_inf
           from simul_test_elem
           group by test_name,
                  test_ident,
                  nb_replic,
                  nb_species,
                  f_opt_max,
                  scaling_factor0,
                  scaling_factor1,
                  scaling_factor2"
    ActiveRecord::Base.connection.execute(sql)
=end
    
  end


  def self.down
=begin
    sql = "drop view simul_test_elem_avg_v"
    ActiveRecord::Base.connection.execute(sql)
=end
  end

end