class CreateColors < ActiveRecord::Migration
  def change
    create_table :colors do |t|
      t.references :color_scheme
      t.string :rgb_hex
      t.string :name

      t.timestamps
    end
    add_index :colors, :color_scheme_id
    add_index :colors, :rgb_hex, :unique => :true
  end
end
