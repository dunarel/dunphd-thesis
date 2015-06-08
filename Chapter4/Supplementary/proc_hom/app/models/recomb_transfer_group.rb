class RecombTransferGroup < ActiveRecord::Base
  has_one :source, :class_name => "ProkGroup", :foreign_key => "source_id" 
  has_one :dest, :class_name => "ProkGroup", :foreign_key => "dest_id" 
end
