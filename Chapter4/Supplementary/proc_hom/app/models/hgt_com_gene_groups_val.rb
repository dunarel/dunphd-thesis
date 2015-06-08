class HgtComGeneGroupsVal < ActiveRecord::Base
  belongs_to :gene
  belongs_to :source_id
  belongs_to :dest_id
end
