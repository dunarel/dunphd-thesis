class CreateSimulTest < ActiveRecord::Migration
  def self.up
    create_table :simul_test do |t|
         t.string :test_ident
         t.integer :simul_suite_id
  end

  end


  def self.down
    drop_table :simul_test
  end
end