class HgtParFen < ActiveRecord::Base
  belongs_to :gene
  #attr_accessible :fen_idx_max, :fen_idx_min, :fen_no, :win_size
end
