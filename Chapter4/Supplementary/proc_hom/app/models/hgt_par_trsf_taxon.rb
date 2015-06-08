class HgtParTrsfTaxon < ActiveRecord::Base
  belongs_to :gene
  belongs_to :txsrc
  belongs_to :txdst
end
