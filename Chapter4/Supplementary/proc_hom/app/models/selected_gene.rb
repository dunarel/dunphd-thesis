class SelectedGene < ActiveRecord::Base
  belongs_to :gene
  belongs_to :gene_seq
  belongs_to :ortho_run  
  
end
