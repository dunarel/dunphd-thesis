class AddArraysToHgtParFragms < ActiveRecord::Migration
  def up
 
    execute "alter table HGT_PAR_FRAGMS
             add column from_arr INT ARRAY[1024] DEFAULT ARRAY[]"
  
    
    execute "alter table HGT_PAR_FRAGMS
             add column to_arr INT ARRAY[1024] DEFAULT ARRAY[]"
    

  end
  
  
  def down

    execute "alter table HGT_PAR_FRAGMS
             drop column from_arr"

    execute "alter table HGT_PAR_FRAGMS
             drop column to_arr"
    
  end
end
