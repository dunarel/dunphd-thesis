class GeneMsaRun < ActiveRecord::Base
  belongs_to :gene
  belongs_to :msa_run
end
