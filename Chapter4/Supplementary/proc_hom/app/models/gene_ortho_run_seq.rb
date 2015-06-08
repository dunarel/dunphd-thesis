class GeneOrthoRunSeq < ActiveRecord::Base
  belongs_to :gene_seq
  belongs_to :gene_ortho_run
end
