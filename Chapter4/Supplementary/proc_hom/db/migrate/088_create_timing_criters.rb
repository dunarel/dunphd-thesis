class CreateTimingCriters < ActiveRecord::Migration
  def change
    create_table :timing_criters do |t|
      t.string :name
      t.string :abrev

      t.timestamps
    end
    add_index :timing_criters, :name, :unique => true
    add_index :timing_criters, :abrev, :unique => true
  end
end
