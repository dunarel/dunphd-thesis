class HgtParFragm < ActiveRecord::Base
  belongs_to :gene
  belongs_to :hgt_par_contin
end
