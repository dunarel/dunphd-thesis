
select prok_group_id, sum(weight_pg) as cnt
from TAXONS tx 
 join NCBI_SEQS ns on ns.TAXON_ID = tx.id
 join GENE_BLO_SEQS gbs on gbs.NCBI_SEQ_ID = ns.ID
 join TAXON_GROUPS tg on tg.TAXON_ID = tx.ID
group by PROK_GROUP_ID


self.pgsn_hsh = Taxon.joins(:ncbi_seq => :gene_blo_seq) \
      .joins(:taxon_group) \
      .group("prok_group_id") \
      .select("prok_group_id, sum(weight_pg) as cnt") \
      .each_with_object({ }){ |c, hsh| hsh[c.prok_group_id] = c.cnt.to_i }



      