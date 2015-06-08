class AddStdevToMrcas < ActiveRecord::Migration

 def up
    add_column :mrcas, :stdev, :float

  end
  
  def down
    remove_column :mrcas, :stdev

  end

end
