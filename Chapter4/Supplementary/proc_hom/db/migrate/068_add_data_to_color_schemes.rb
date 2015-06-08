class AddDataToColorSchemes < ActiveRecord::Migration
  def up
    self.class.insert_data()
  end
  
  def down
    execute "delete from color_schemes"
  end
  
  def self.insert_data()
    
   # http://graphicdesign.stackexchange.com/questions/3682/large-color-set-for-coloring-of-many-datasets-on-a-plot
   [[0,'colour_alphabet_26'],
    [1,'kelly_22']
   ].each { |sch|
      
     execute "insert into color_schemes
             (id,name)
       	     values
      	     (#{sch[0]},'#{sch[1]}')"      
    }
    
  end
end
