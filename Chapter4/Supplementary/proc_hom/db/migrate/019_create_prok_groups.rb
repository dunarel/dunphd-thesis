class CreateProkGroups < ActiveRecord::Migration
  def up
    create_table :prok_groups do |t|
      t.string :name

      t.timestamps
    end
    add_index :prok_groups, :name , :unique => true
    
    
    execute "insert into prok_groups(name)
             select distinct simple_group
             from lproks
	     where sequence_status='complete'
             order by simple_group"
  end
  
  def down
    drop_table :prok_groups
  end
end
