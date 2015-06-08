class AddDataToColors < ActiveRecord::Migration
  def up
    self.class.insert_data()
  end
  
  def down
    self.class.delete_data()
  end
  
  def self.update_data()
    self.delete_data()
    self.insert_data()
  end
  
  def self.delete_data()
    execute "delete from colors"
  end
  
  def self.insert_data()
    
   # http://tx4.us/nbs-iscc.htm
   #insert color_alphabet_26 colors 
   [[0,'#f0a3ff'],
    [1,'#00750c'],
    [2,'#993f00'],
    [3,'#4c005c'],
    [4,'#191919'],
    [5,'#005c31'],
    [6,'#2bce48'],
    [7,'#ffcc99'],
    [8,'#808080'],
    [9,'#8f7c00'],
    [10,'#9dcc00'],
    [11,'#c20088'],
    [12,'#003380'],
    [13,'#ffa405'],
    [14,'#ffa8bb'],
    [15,'#426600'],
    [16,'#ff0010'],
    [17,'#5ef1f2'],
    [18,'#00998f'],
    [19,'#e0ff66'],
    [20,'#740aff'],
    [21,'#990000'],
    [22,'#fffc03'],
    [23,'#ffff00'],
    [24,'#ff5005'] 
   ].each { |col|
      
     execute "insert into colors
             (id,rgb_hex,color_scheme_id)
       	     values
      	     (#{col[0]},'#{col[1]}',0)"      
    }
    
    #insert kelly_22 colors 
   [[25,'#F2F3F4','white'],
    [26,'#222222','black'],
    [27,'#F3C300','yellow'],
    [28,'#875692','purple'],
    [29,'#F38400','orange'],
    [30,'#A1CAF1','light_blue'],
    [31,'#BE0032','red'],
    [32,'#C2B280','buff'],
    [33,'#848482','gray'],
    [34,'#008856','green'],
    [35,'#E68FAC','purplish_pink'],
    [36,'#0067A5','blue'],
    [37,'#F99379','yellowish_pink'],
    [38,'#604E97','violet'],
    [39,'#F6A600','orange_yellow'],
    [40,'#B3446C','purplish_red'],
    [41,'#DCD300','greenish_yellow'],
    [42,'#882D17','reddish_brown'],
    [43,'#8DB600','yellow_green'],
    [44,'#654522','yellowish_brown'],
    [45,'#E25822','reddish_orange'],
    [46,'#2B3D26','olive_green'] 
   ].each { |col|
      
     execute "insert into colors
             (id,rgb_hex,name,color_scheme_id)
       	     values
      	     (#{col[0]},'#{col[1]}','#{col[2]}',1)"      
    }
    
  end
end

=begin

=end