class MQFunctionGen < ActiveRecord::Migration
  def self.up
    create_table :q_function_gen do |t|
      t.integer :idx
      t.integer :win_length
      t.float :q_val, :null => true
      t.float :d_xy
      t.float :v_x
      t.string :obs
      t.text :data

    end


  end

  def self.down
    drop_table :q_function_gen
  end
end