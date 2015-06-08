class CreateMrcaCriters < ActiveRecord::Migration
  def up
    create_table :mrca_criters do |t|
      t.string :name

      t.timestamps
    end
    add_index :mrca_criters, :name, :unique => true

  end

  def down

    remove_index :mrca_criters, :name
    drop_table :mrca_criters

  end
end
