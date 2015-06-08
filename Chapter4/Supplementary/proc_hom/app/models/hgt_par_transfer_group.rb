class HgtParTransferGroup < ActiveRecord::Base
  
=begin  
          sql2 = "equivalent for partials
  select count(distinct ht.NCBI_SEQ_SOURCE_ID) as nb
               from hgt_par_transfers ht
               join HGT_PAR_FRAGMS hpf on hpf.ID = ht.HGT_PAR_FRAGM_ID
              join HGT_COM_INT_FRAGMS hcf on hcf.ID = ht.HGT_PAR_FRAGM_ID
              join NCBI_SEQS ns_src on ns_src.id = ht.NCBI_SEQ_SOURCE_ID
              join TAXON_GROUPS tg_src on tg_src.TAXON_ID = ns_src.TAXON_ID
              join NCBI_SEQS ns_dest on ns_dest.id = ht.NCBI_SEQ_DEST_ID
              join TAXON_GROUPS tg_dest on tg_dest.TAXON_ID = ns_dest.TAXON_ID
             where hpf.GENE_ID = 111 and
                   tg_src.PROK_GROUP_ID = 18"
=end
  
 #return number of affected ncbi_seqs from tranfer table [source, dest] 
 #limit scope between groups
 def self.ncbi_seqs_nb(gene_id, prok_group_id, prokid_min, prokid_max, op )
   
   res = []
  
   #compare destination with destination
   #source column with source table
   [["ncbi_seq_source_id","tg_src", "tg_dest"],
    ["ncbi_seq_dest_id", "tg_dest", "tg_src"]].each { |col, tbl, tbl_lim|
    #match column to related table
    sql_op = case op
     when :sum_weight then "sum(weight)"
     when :count_col then  "count(distinct ht.#{col})" 
         end
         
     sql = "select  #{sql_op} as nb
               from hgt_par_transfers ht
               join HGT_PAR_FRAGMS hpf on hpf.ID = ht.HGT_PAR_FRAGM_ID
               join NCBI_SEQS ns_src on ns_src.id = ht.NCBI_SEQ_SOURCE_ID
              join TAXON_GROUPS tg_src on tg_src.TAXON_ID = ns_src.TAXON_ID
              join NCBI_SEQS ns_dest on ns_dest.id = ht.NCBI_SEQ_DEST_ID
              join TAXON_GROUPS tg_dest on tg_dest.TAXON_ID = ns_dest.TAXON_ID
             where hpf.GENE_ID = #{gene_id} and
                   #{tbl}.PROK_GROUP_ID = #{prok_group_id} and
                   #{tbl_lim}.prok_group_id between #{prokid_min} and #{prokid_max}"
     
    #puts "sql: #{sql}"
    
      
     res << HgtParTransfer.find_by_sql(sql).first.nb.to_f
  
     
   }
   #puts "res: #{res}"
   return res
   
   
 end 
 
 #return number of ncbi_seqs total 
 def self.ncbi_seqs_cnt(gene_id, prok_group_id)
   
     
  
     sql = "select count(distinct gbs.NCBI_SEQ_ID) as cnt
                 from GENE_BLO_SEQS gbs 
                  join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
                  join TAXON_GROUPS tg on tg.TAXON_ID = ns.TAXON_ID
                 where gbs.GENE_ID = #{gene_id} and 
                       tg.PROK_GROUP_ID = #{prok_group_id}"
     
    #puts "sql: #{sql}"
    
      
     res =  HgtParTransfer.find_by_sql(sql).first.cnt.to_f
  
     
   
   #puts "res: #{res}"
   
   return res
   
   
 end 
 
  
  
end
