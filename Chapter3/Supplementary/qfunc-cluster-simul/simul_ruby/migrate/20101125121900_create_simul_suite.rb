class CreateSimulSuite < ActiveRecord::Migration
  def self.up

    create_table :simul_suite do |t|
         t.string :test_name
    end
    #ensure test_name is unique
    add_index :simul_suite, :test_name, :unique => true

  end


  def self.down
    drop_table :simul_suite
  end
end
