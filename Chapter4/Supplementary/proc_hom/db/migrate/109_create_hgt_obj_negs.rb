class CreateHgtObjNegs < ActiveRecord::Migration
  def change
    create_table :hgt_obj_negs do |t|
      t.integer :source_id
      t.integer :dest_id

      t.timestamps
    end
  end
end
