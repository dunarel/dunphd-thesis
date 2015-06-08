class HgtQfuncStat < ActiveRecord::Base
  belongs_to :hgt_qfunc_cond
  attr_accessible :false_neg, :false_pos, :lrt_neg, :lrt_pos, :npv, :ppv, :rbo, :sensit, :specif, :true_neg, :true_pos
end
