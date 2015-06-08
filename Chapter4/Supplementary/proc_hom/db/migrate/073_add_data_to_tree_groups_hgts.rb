class AddDataToTreeGroupsHgts < ActiveRecord::Migration
  def up
    self.class.insert_data()
  end
  
  def down
    execute "delete from tree_groups_hgts"
  end
  
  def self.update_data()
    
  end
  
  def self.insert_data()
    
   [[0,8,17,3.9,16.2],
    [1,8,18,8.3,40.2],
    [2,17,15,0,100],
    [3,17,18,7.4,0],
    [4,18,3,0,16.6],
    [5,18,17,0,4.6],
    [6,20,6,1.6,0],
    [7,21,22,1.4,0]
   ].each { |tgh|
      
     execute "insert into tree_groups_hgts
             (id,PROK_GROUP_SOURCE_ID,PROK_GROUP_DEST_ID, val1, val2)
       	     values
      	     (#{tgh[0]},#{tgh[1]},#{tgh[2]},#{tgh[3]},#{tgh[4]})"      
    }
    
  end
end
