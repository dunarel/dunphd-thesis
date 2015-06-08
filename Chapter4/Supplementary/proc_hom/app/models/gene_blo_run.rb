class GeneBloRun < ActiveRecord::Base
  belongs_to :gene
  belongs_to :blo_run
end
