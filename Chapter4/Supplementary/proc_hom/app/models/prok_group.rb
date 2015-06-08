class ProkGroup < ActiveRecord::Base
  
  belongs_to :color
  has_many :taxon_group
  
  #return an array with the prok_group_id identifiers of the selected criterium
  def self.ids_for_crit(crit)
    
    pgs = GroupCriter.find_by_name(crit).prok_group.order('order_id asc').select('id')
    pgs_arr = pgs.collect {|pg| pg.id}
    
    return pgs_arr
    
    
    
    
    
    
  end
  
end
