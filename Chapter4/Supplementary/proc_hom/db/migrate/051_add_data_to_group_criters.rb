class AddDataToGroupCriters < ActiveRecord::Migration
  def up
    self.class.update_data()
  end
  
  def down
    self.class.delete_data()
    
  end
  
  def self.update_data()
    self.delete_data()
    self.insert_data()
  end
  
  def self.insert_data()
   [[0,'family'],
    [1,'habitat'],
    [2,'timing']
   ].each { |crit|
      
     execute "insert into group_criters
             (id,name)
       	     values
      	     (#{crit[0]},'#{crit[1]}')"      
    }
    
  end
  
  def self.delete_data()
    execute "delete from group_criters"  

  end
  
    
  
end
