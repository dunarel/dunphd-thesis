class HgtSimPerm < ActiveRecord::Base
  belongs_to :hgt_sim_cond
  attr_accessible :false_pos, :nb_trsfs, :qfunc, :true_pos
end
