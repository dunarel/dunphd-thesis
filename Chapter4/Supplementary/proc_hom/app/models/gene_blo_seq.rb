class GeneBloSeq < ActiveRecord::Base
 
  belongs_to :gene
  
  belongs_to :ncbi_seq
  
end
