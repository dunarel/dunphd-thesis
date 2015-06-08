class AddLevelToMrcas < ActiveRecord::Migration
 def up
    add_column :mrcas, :level, :string

  end
  
  def down
    remove_column :mrcas, :level

  end
end
