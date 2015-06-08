
require 'rubygems'
require 'bio' 
require 'msa_tools'
require 'faster_csv'
require 'erb'
require 'matrix'
require 'base_transfer'
require 'manage_data'
require 'time_estim'


module HgtTot


  def init

    puts "in HgtTot init"
    #active record object initialization
    self.arGeneGroupCnt = GeneGroupCnt
    self.arGeneGroupsVal = HgtComGeneGroupsVal

    super

  end

  def initialize()

    puts "in HgtTot initialize"
    
    #initialize included modules
    #super

  end


  
  def transfer_groups
  
    #recreate recomb_transfer_groups   
    arTransferGroup.delete_all
    sleep 10

 
    #insert all prokaryotes groups
    @conn.execute "insert into hgt_com_int_transfer_groups
                    (prok_group_source_id,prok_group_dest_id)
                    select pg1.ID,pg2.id
                    from PROK_GROUPS pg1
                     cross join PROK_GROUPS pg2 
                    order by pg1.id,
                             pg2.id"
    # transfers are already filtered by threshold  
    #where ht.confidence >= #{@thres} and
    #by Regular / Trivial
    #denormalize regular transfers as regular_cnt
    @conn.execute "update hgt_com_int_transfer_groups htg
                   set htg.cnt =  select sum(ht.weight)
                   from hgt_com_int_transfers ht
                    left join HGT_COM_INT_FRAGMS hf on hf.ID = ht.HGT_COM_INT_FRAGM_ID
                    left join NCBI_SEQS ns_src on ns_src.id = ht.SOURCE_ID
                    left join TAXON_GROUPS tg_src on tg_src.TAXON_ID = ns_src.TAXON_ID  
                    left join NCBI_SEQS ns_dest on ns_dest.id = ht.DEST_ID
                    left join TAXON_GROUPS tg_dest on tg_dest.TAXON_ID = ns_dest.TAXON_ID
                   where tg_src.PROK_GROUP_ID = htg.prok_group_source_id and
                         tg_dest.PROK_GROUP_ID = htg.prok_group_dest_id
                   group by tg_src.PROK_GROUP_ID,
                           tg_dest.PROK_GROUP_ID"
     
    
      
    @conn.execute "update hgt_com_int_transfer_groups
                    set cnt=nvl(cnt,0)"

  end
  

  #load all group combinations
  #from all criteria
  def calc_transf_stats()
    
    #take the greatest of complete and partial transfers
    sql=<<-END
select un.gene_id,
       un.PROK_GROUP_SOURCE_ID,
       un.PROK_GROUP_DEST_ID,
       max(val) as val
from
(
select gene_id,
       PROK_GROUP_SOURCE_ID,
       PROK_GROUP_DEST_ID,
       VAL
from HGT_COM_GENE_GROUPS_VALS
 union
select gene_id,
       PROK_GROUP_SOURCE_ID,
       PROK_GROUP_DEST_ID,
       VAL
from HGT_PAR_GENE_GROUPS_VALS
) un
group by un.gene_id,
         un.PROK_GROUP_SOURCE_ID,
         un.PROK_GROUP_DEST_ID
order by un.gene_id,
         un.PROK_GROUP_SOURCE_ID,
         un.PROK_GROUP_DEST_ID
    END
    @hpggv_hsh = @conn.select_rows(sql) \
      .each_with_object({ }){ |c, hsh| hsh[[c[0].to_i,c[1].to_i,c[2].to_i]] = c[3].to_f }
    
    #puts "@hpggv_hsh: #{@hpggv_hsh.inspect}"
    #sleep 20
                                        
    @sg_hsh = arGeneGroupCnt.find(:all) \
      .each_with_object({ }){ |c, hsh| hsh[[c.gene_id,
          c.prok_group_id]
      ] = c.cnt }
  
     
    
  end

  #works only combined with base_transfer
  def calc_custom_config()
    
    @custom_configs = {}
    
    case @crit  
    when :family
      @custom_configs[[:all,"raxml",50, :abs]] = [410 - 5 + 5 ,140] #
      @custom_configs[[:all,"raxml",50, :rel]] = [410 + 30 ,140] #
    
      @custom_configs[[:all,"raxml",75, :abs]] = [410 - 25 + 5 ,140] #
      @custom_configs[[:all,"raxml",75, :rel]] = [410 + 10 ,140] #
    
      @custom_configs[[:all,"phyml",50, :abs]] = [410 - 5 + 5,140]
      @custom_configs[[:all,"phyml",50, :rel]] = [410 + 30 ,140]
    
      @custom_configs[[:all,"phyml",75, :abs]] = [410 - 25 + 5,140]
      @custom_configs[[:all,"phyml",75, :rel]] = [410 + 10 ,140]
    
      @custom_configs[[:regular,"raxml",50, :abs]] = [410 - 20 + 5,140] #
      @custom_configs[[:regular,"raxml",50, :rel]] = [410 + 20 ,140] #
      
      #most restrictive
      @custom_configs[[:regular,"raxml",75, :abs]] = [410 - 30 + 5,140] #370
      
      @custom_configs[[:regular,"raxml",75, :rel]] = [425 , 130, 100 ] #10 max
    
      @custom_configs[[:regular,"phyml",50, :abs]] = [410 - 20 + 5,140]
      @custom_configs[[:regular,"phyml",50, :rel]] = [410 + 20 ,140]
      @custom_configs[[:regular,"phyml",75, :abs]] = [410 - 30 + 5,140] 
      @custom_configs[[:regular,"phyml",75, :rel]] = [410 + 10 ,140]  
    when :habitat
      @custom_configs[[:all,"raxml",50, :abs]] = [250 ,100] 
      @custom_configs[[:all,"raxml",50, :rel]] = [250 ,100] 
    
      @custom_configs[[:all,"raxml",75, :abs]] = [250 ,100] 
      @custom_configs[[:all,"raxml",75, :rel]] = [210 ,70] 
    
      @custom_configs[[:all,"phyml",50, :abs]] = [250 ,100] 
      @custom_configs[[:all,"phyml",50, :rel]] = [250 ,100] 
    
      @custom_configs[[:all,"phyml",75, :abs]] = [250 ,100] 
      @custom_configs[[:all,"phyml",75, :rel]] = [250 ,100] 
    
      @custom_configs[[:regular,"raxml",50, :abs]] = [250 ,100] 
      @custom_configs[[:regular,"raxml",50, :rel]] = [250 ,100] 
      
      #most restrictive
      @custom_configs[[:regular,"raxml",75, :abs]] = [220 ,80, 550] #120
      
      @custom_configs[[:regular,"raxml",75, :rel]] = [215 , 70 , 2] #0.315
    
      @custom_configs[[:regular,"phyml",50, :abs]] = [250 ,100] 
      @custom_configs[[:regular,"phyml",50, :rel]] = [250 ,100] 
      @custom_configs[[:regular,"phyml",75, :abs]] = [250 ,100] 
      @custom_configs[[:regular,"phyml",75, :rel]] = [250 ,100] 
    end
    
    querry_arr = [@hgt_type, @phylo_prog, @thres, @calc_type] 
    #puts "qer_arr: #{querry_arr.inspect}"
    #puts "@custom_configs: #{@custom_configs.inspect}"
    @config = @custom_configs[querry_arr]

    
  end
  
  
  def leaf_transf_cnt()
    
    return HgtParTransfer.count
    
  end 
  
end
