class Taxon < ActiveRecord::Base
  belongs_to :parent
  belongs_to :division
  
  has_many :ncbi_seq
  
  
  has_many :taxon_group #, :class_name => "TaxonGroup", :foreign_key => "id" 
  
  has_one :ncbi_seqs_taxon
  
end
