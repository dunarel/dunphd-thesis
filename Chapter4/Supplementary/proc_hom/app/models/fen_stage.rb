class FenStage < ActiveRecord::Base
  belongs_to :prev_fen_stage
  attr_accessible :calc_section, :phylo_prog, :timing_prog
end
