class GeneGroupCnt < ActiveRecord::Base
  belongs_to :gene
  belongs_to :prok_group
end
