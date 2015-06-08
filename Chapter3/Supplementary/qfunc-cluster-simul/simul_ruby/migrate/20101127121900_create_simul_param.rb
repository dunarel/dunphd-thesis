class CreateSimulParam < ActiveRecord::Migration
  def self.up
    create_table :simul_param do |t|
         t.integer :nb_replic
         t.integer :nb_species
         t.integer :f_opt_max
         t.float :scaling_factor0
         t.float :scaling_factor1
         t.float :scaling_factor2
         t.integer :simul_test_id

    end

  end


  def self.down
    drop_table :simul_param
  end
end