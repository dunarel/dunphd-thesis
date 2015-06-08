class HgtComIntContin < ActiveRecord::Base
  belongs_to :gene
  belongs_to :hgt_com_int_fragm, :class_name => "HgtComIntFragm", :foreign_key => "hgt_com_int_fragm_id"
end
