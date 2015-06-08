require 'taxon_meta'

class AddDataToAbrevProkGroups < ActiveRecord::Migration
  
 
def up
  
  tm = TaxonMeta.new("Habitat")
  
  (0..(tm.habitats.length-1)).each {|idx|
    
    execute "insert into PROK_GROUPS
              (name,order_id,group_criter_id,abrev)
             values
              ('#{tm.habitats[idx][1]}',#{idx},1,'#{tm.habitats[idx][0]}')"
  } 
   
    
  
    
  end
  
  def down
    execute "delete from PROK_GROUPS
             where group_criter_id = 1"
    
  end
  
  
  
end
