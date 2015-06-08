class CreateGroupCriters < ActiveRecord::Migration

  
  
  def up
    create_table :group_criters do |t|
      t.string :name
      t.integer :len
  
      t.timestamps
    end
    add_index :group_criters, :name, :unique => true
    
  end
  
  def down
    remove_index :group_criters, :name
    drop_table :group_criters
  end
  
  
  
end
