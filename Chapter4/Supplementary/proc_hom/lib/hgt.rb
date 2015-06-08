
require 'rubygems'
require 'hgt_com'
require 'hgt_par'
require 'hgt_tot'
require 'hgt_clus'
require 'hgt_clus_par'
require 'base_transfer'
require 'time_estim'

class AssertError < StandardError
end

module HgtConfig

  def init
    puts "in HgtConfig.init"
    super

  end

  #names of timings
  #@stage variable instead of symbol
  def exp_crit_d
   Pathname.new "#{AppConfig.db_exports_dir}/#{@stage}/#{crit}"
  end

  def exp_d(ext = :work)
    Pathname.new "#{exp_crit_d}/#{calc_type}/#{ext.to_s}"
    #puts "exp_d(#{ext}): #{exp_d(ext)}"
  end

  
  
  #set exports fname
  def exp_fname
    "#{@stage}-#{crit}-#{calc_type}-#{phylo_prog}-#{thres}-#{hgt_type.to_s}"
    #puts "exp_fname: #{exp_fname}"
  end

  #base name of heatmaps export files by parameter names
  def hm_base_name
    "#{exp_fname}-hm"
    
  end

  #base name of matrix export files by parameter names
  def mt_base_name
    "#{exp_fname}-mt"
    
  end

  #base name of totals
  def tt_base_name
    "#{exp_fname}-tt"
  end
  
  #graphics data do not depend on calc_type
  def data_d
    Pathname.new "#{exp_crit_d}/data"
   
  end
  
  #base name of totals
  def tr_base_name
      "#{@stage}-#{crit}-#{phylo_prog}-#{thres}-#{hgt_type.to_s}-tr"
  end
  



  #hgts for inkscape transfers list
  def hgts_ink_fname
    "#{exp_fname}-hgts-ink"
  end


  #formating specific to calc_type
  def mat_frm
    @matr_format[[@calc_type]]
  end

  def cell_frm
    @mat_frm[0]
  end

  def cell_lambda
    cell_frm_f(@mat_frm[1])
  end

  #Available database hgt_type fields
  def hgt_type_avail_db
    case hgt_type
    when :regular then
      ["Regular"]
    when :all
      ["Regular","Trivial"]
    else
      #no other options
      raise AssertError.new ""

    end
  end

  #for recombination
  #selection based on confidence field
  #Available database hgt_type fields
  def confidence_avail_db

    case hgt_type
    when :regular then [1]
    when :all then [1,0]
    else raise AssertError.new ""
    end

  end

end


class Hgt

  

  attr_reader :crit, # [:family,:habitat]
              :crit_id
             
  attr_accessor :gene,
  :phylo_prog,  # ["phyml","raxml"]
  :hgt_type, # [:regular, :all]
  :calc_type, # [:abs, :rel]
  :thres, # [75,50]
   :genes,
   :genes_all,
   :genes_core,
    :taxons_cnt,
    :itc_hsh,
    :pgtn_hsh, #
    :pgtn_hsh_all,
    :pgtn_hsh_core,
  :pgsn_hsh, 
  :pgsn_hsh_all, #
  :pgsn_hsh_core, #
  :core_level,
  :one_dim_op,
  :timing_needed,
  :hg_step
  

  #activerecord models
  attr_accessor :arTrsfTaxon,
    :arTrsfPrkgr,
    :arTransferGroup,
    :arTrsfTiming,
    :arGeneGroupCnt, 
    :arGeneGroupsVal 

  def stage=(stage)
   #:stage symbol has "_"
    #@stage        has "-"
    case stage
    when :hgt_com
      @stage = "hgt-com"
    when :hgt_par
      @stage = "hgt-par"
    when :hgt_tot
      @stage = "hgt-tot"
    
    end
    
  end
  
  #:stage symbol has "_"
  #@stage        has "-"
  def stage
    case @stage
    when "hgt-com"
      :hgt_com
    when "hgt-par"
      :hgt_par
    when "hgt-tot"
      :hgt_tot      
    end


  end
  
  
  #stage :hgt_com, :hgt_par
  def initialize(stage = nil)
    self.stage=stage  
  
    #utility objects
    @ud = UqamDoc::Parsers.new
    @rnd_gen = Random.new
    @conn = ActiveRecord::Base.connection
    #connection for direct JDBC
    @jdbc_conn=@conn.jdbc_connection

    #sqltool import-export
    @sqltool_jar_fname = "#{AppConfig.lib_dir}/sqltool.jar"
    @sqltool_rc_fname = "#{AppConfig.lib_dir}/sqltool.rc"
    @sqltool_urlid = "proc_hom_local"

    @db_dataset_dir = "#{AppConfig.db_datasets}/#{@stage}/#{@hgt_type}-#{@phylo_prog}-#{@thres}"


    #first extended called last

    extend TimeEstimCom if stage == :hgt_com
    extend TimeEstimPar if stage == :hgt_par
    extend TimeEstimConfig
    extend TimeEstim

    extend BaseTransfer

    extend HgtCom if stage == :hgt_com
    extend HgtPar if stage == :hgt_par
    extend HgtTot if stage == :hgt_tot

    extend HgtConfig

    extend HgtClusConfig
    extend HgtClus
    extend HgtClusPar if stage == :hgt_par

    

    puts "in Hgt.initialize(stage) @stage: #{@stage}, stage: #{stage}"


    #call with no arguments
    init()
    
  end

  #final initializations
  def init
    puts "in Hgt.init"
    puts "last called after all extensions"
    calc_global_stats
  end

  
 

  def genes_cnt
    genes.length
  end


  #load all groups dependent
  def calc_global_stats()

    #common set of genes
    
    core_genes_ids = [110,111,112,113,114,115,119,123,136,137,138,139,140,141,149,154,156,157,159,164,168,181,182,183,184,186,193,195,196,199,202,204,206,216]
    
    self.genes_core = Gene.find(:all, :conditions => { :id => core_genes_ids })
    self.genes_all = Gene.find(:all)
    #puts "genes: #{genes.inspect}"

    self.taxons_cnt = NcbiSeqsTaxon.count(:distinct => true)
    puts "taxons_cnt: #{taxons_cnt}"


    #img_tot_cnt
    self.itc_hsh = ProkGroup.find(:all) \
      .each_with_object({ }){ |c, hsh| hsh[c.id] = c.img_tot_cnt }


    #prok group taxon number
    #all small n as constant
    #self.pgtn_hsh = Taxon.joins(:ncbi_seqs_taxon) \
    #  .joins(:taxon_group) \
    #  .group("prok_group_id") \
    #  .select("prok_group_id, count(*) as cnt") \
    #  .each_with_object({ }){ |c, hsh| hsh[c.prok_group_id] = c.cnt }

    self.pgtn_hsh_core = Taxon.find_by_sql("select pg.ID as prok_group_id,
       nvl(t2.cnt,0) as cnt
from PROK_GROUPS pg
left outer join 
(
select pg.id, count(*) as cnt
from PROK_GROUPS pg
 join TAXON_GROUPS tg on tg.PROK_GROUP_ID = pg.ID
 join NCBI_SEQS_TAXONS nst on nst.TAXON_ID = tg.TAXON_ID
where nst.TAXON_ID in (select distinct tx.ID
                       from taxons tx
					 join NCBI_SEQS ns on ns.TAXON_ID = tx.ID
					 join GENE_BLO_SEQS gbs on gbs.NCBI_SEQ_ID = ns.id
					 join taxon_groups tg on tg.TAXON_ID = tx.ID
					 where gbs.GENE_ID in (110,111,112,113,114,115,119,123,136,137,138,139,140,141,149,154,156,157,159,164,168,181,182,183,184,186,193,195,196,199,202,204,206,216)
)
group by pg.id
) t2 on t2. id = pg.id 
").each_with_object({ }){ |c, hsh| hsh[c.prok_group_id] = c.cnt.to_f }

self.pgtn_hsh_all = Taxon.find_by_sql("select pg.ID as prok_group_id,
       nvl(t2.cnt,0) as cnt
from PROK_GROUPS pg
left outer join 
(
select pg.id, count(*) as cnt
from PROK_GROUPS pg
 join TAXON_GROUPS tg on tg.PROK_GROUP_ID = pg.ID
 join NCBI_SEQS_TAXONS nst on nst.TAXON_ID = tg.TAXON_ID
where nst.TAXON_ID in (select distinct tx.ID
                       from taxons tx
					 join NCBI_SEQS ns on ns.TAXON_ID = tx.ID
					 join GENE_BLO_SEQS gbs on gbs.NCBI_SEQ_ID = ns.id
					 join taxon_groups tg on tg.TAXON_ID = tx.ID
)
group by pg.id
) t2 on t2. id = pg.id 
").each_with_object({ }){ |c, hsh| hsh[c.prok_group_id] = c.cnt.to_f }

    
    
    
    
    #puts @pgtn_hsh.inspect

    #prok group sequence number
    #find nb of sequences in group
    #debug
    #Rails.logger.level = 0 # at any time
    self.pgsn_hsh_all = Taxon.joins(:ncbi_seq => :gene_blo_seq) \
      .joins(:taxon_group) \
      .group("prok_group_id") \
      .select("prok_group_id, sum(weight_pg) as cnt") \
      .each_with_object({ }){ |c, hsh| hsh[c.prok_group_id] = c.cnt }
    
    self.pgsn_hsh_core = Taxon.joins(:ncbi_seq => :gene_blo_seq) \
      .joins(:taxon_group) \
      .where({ "GENE_BLO_SEQS.gene_id" => core_genes_ids }) \
      .group("prok_group_id") \
      .select("prok_group_id, sum(weight_pg) as cnt") \
      .each_with_object({ }){ |c, hsh| hsh[c.prok_group_id] = c.cnt.to_f }

    
    #puts @pgsn_hsh.inspect
    
    
    #exit(0)
    #debug
    #Rails.logger.level = 2 # at any time


  end
  
  def genes_switch_core()
    self.genes = self.genes_core
    self.pgtn_hsh = self.pgtn_hsh_core
    self.pgsn_hsh = self.pgsn_hsh_core
    self.core_level = "core"
          
  end
 
  
  def genes_switch_ubiq()
    self.genes = self.genes_all
    self.pgtn_hsh = self.pgtn_hsh_all
    self.pgsn_hsh = self.pgsn_hsh_all
    self.core_level = "ubiq"      
  end
 
  def hgt_type=(hgt_type)
    @hgt_type = hgt_type
      
  end

  #correlate to crit_id from 
  def crit=(crit)
    
    
    @crit = crit
    
    puts "crit: #{crit}"
    #
    @crit_id =  GroupCriter.find_by_name(crit).id.to_i
    puts "in crit.. setting also @crit_id: #{@crit_id.inspect}"
  end

end

