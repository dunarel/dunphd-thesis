class CreateHgtObjs < ActiveRecord::Migration
  def up
    create_table :hgt_objs do |t|
      t.integer :source_id
      t.integer :dest_id

      t.timestamps
    end
  end
  
  def down
    
    drop_table :hgt_objs
  end
end
