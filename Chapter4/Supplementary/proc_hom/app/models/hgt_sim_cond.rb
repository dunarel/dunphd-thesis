class HgtSimCond < ActiveRecord::Base
  belongs_to :gene
  attr_accessible :max_trsfs
end
