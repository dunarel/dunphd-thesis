class TaxonGroup < ActiveRecord::Base
  
  belongs_to :taxon

  belongs_to :prok_group
  
  #has_many :ncbi_seqs, :class_name => "NcbiSeq", :foreign_key => :taxon_id




end
