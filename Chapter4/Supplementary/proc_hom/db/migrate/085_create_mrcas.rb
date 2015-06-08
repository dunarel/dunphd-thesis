class CreateMrcas < ActiveRecord::Migration
  def change
    create_table :mrcas do |t|
      t.string :abrev
      t.string :name
      t.integer :time_min
      t.integer :time_max
      t.integer :time_med
      t.references :mrca_criter

      t.timestamps
    end
    add_index :mrcas, :mrca_criter_id


  end
end
