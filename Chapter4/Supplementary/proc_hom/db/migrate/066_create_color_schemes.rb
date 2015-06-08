class CreateColorSchemes < ActiveRecord::Migration
  def change
    create_table :color_schemes do |t|
      t.string :name

      t.timestamps
    end
    add_index :color_schemes, :name, :unique => :true
  end
end
