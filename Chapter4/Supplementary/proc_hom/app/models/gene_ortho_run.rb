class GeneOrthoRun < ActiveRecord::Base
  belongs_to :gene
  belongs_to :ortho_run
  has_many :gene_ortho_run_seqs
end
