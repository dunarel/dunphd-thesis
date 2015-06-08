class MIdxGraphMsa < ActiveRecord::Migration

#  def init
#    @t = :surface_loops_exposed
#    @ty = :integer
#
 # end

  def self.up
   # init
   @t = :surface_loops_exposed
    @ty = :integer
    #old
    [:idx_begin,:idx_end].each { |c|
      remove_column @t,c
    }
    #new
    [:idx_graph_aa_begin, :idx_graph_aa_end,
     :idx_seq_aa_begin,  :idx_seq_aa_end,
     :idx_msa_dna_begin,  :idx_msa_dna_end
    ].each { |c|
      add_column @t,c,@ty

    }

  end

  def self.down
    @t = :surface_loops_exposed
    @ty = :integer

 
    [:idx_graph_aa_begin, :idx_graph_aa_end,
      :idx_seq_aa_begin, :idx_seq_aa_end,
      :idx_msa_dna_begin, :idx_msa_dna_end
    ].each { |c|
      remove_column @t,c

    }

    [:idx_begin,:idx_end].each { |c|
      add_column @t,c,@ty
    }


  end

end