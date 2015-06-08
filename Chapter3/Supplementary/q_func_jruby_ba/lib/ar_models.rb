require 'init.rb'
#require 'list.rb'

ActiveRecord::Base.pluralize_table_names = false

class QFunctionGen < ActiveRecord::Base

end


class MsaDna < ActiveRecord::Base
  #set_table_name "msa_dna"
  has_many :msa_dna_pos, 
    :class_name => "MsaDnaPos",
    #:foreign_key => :msa_dna_id,
    :dependent => :nullify

 # def after_create
    #for idx in 0..self.seq.length-1
    #  my_msa_dna_pos = MsaDnaPos.new
    #  my_msa_dna_pos.idx = idx
    #  my_msa_dna_pos.symbol = self.seq[idx..idx]
    #  my_msa_dna_pos.save!
    #end

  #end

end

class MsaDnaPos < ActiveRecord::Base
  #set_table_name "msa_dna_pos"
  belongs_to :msa_dna
  has_many :msa_dna_pos_seq_dna_pos ,
    :class_name => "MsaDnaPosSeqDnaPos"

end

class SeqDna < ActiveRecord::Base
  has_many :seq_dna_pos,
    :class_name => "SeqDnaPos",
    :dependent => :nullify

end

class SeqDnaPos < ActiveRecord::Base
  belongs_to :seq_dna
  belongs_to :seq_aa_pos,
    :class_name => "SeqAaPos"
  has_many :msa_dna_pos_seq_dna_pos,
    :class_name => "MsaDnaPosSeqDnaPos"
  has_many :msa_dna_pos,
    :through => :msa_dna_pos_seq_dna_pos,
    :class_name => "MsaDnaPos"

end


class SeqAa < ActiveRecord::Base
  has_many :seq_aa_pos,
    :class_name => "SeqAaPos",
    :dependent => :destroy

end

class SeqAaPos < ActiveRecord::Base
  belongs_to :seq_aa
  has_many :seq_dna_pos,
    :class_name => "SeqDnaPos",
    :dependent => :nullify


end

class MsaDnaPosSeqDnaPos < ActiveRecord::Base
  #set_table_name "msa_dna_pos_seq_dna_pos"
  belongs_to :msa_dna_pos
  belongs_to :seq_dna_pos
  
end

class SurfaceLoopsExposed < ActiveRecord::Base
   acts_as_list :column => :position

 
end

class PeriplasmicLoopsExposed < ActiveRecord::Base
   acts_as_list :column => :position


end


