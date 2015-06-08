class HgtParContin < ActiveRecord::Base
    belongs_to :gene
    has_many :hgt_par_fragms
    
end
