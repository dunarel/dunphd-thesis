select id from genes_core_inter
order by id
110,111,112,113,114,115,119,123,136,137,138,139,140,141,149,154,156,157,159,164,168,181,182,183,184,186,193,195,196,199,202,204,206,216


select sum(weight)
from HGT_COM_INT_TRANSFERS

select *
from ncbi_seqs

select *
from gene_blo_seqs

select sum(t.cnt)
from 
(

select prok_group_id, sum(weight_pg) as cnt
from taxons tx
 join NCBI_SEQS ns on ns.TAXON_ID = tx.ID
 join GENE_BLO_SEQS gbs on gbs.NCBI_SEQ_ID = ns.id
 join taxon_groups tg on tg.TAXON_ID = tx.ID
where tg.PROK_GROUP_ID between 0 and 22 and
      gbs.GENE_ID in (110,111,112,113,114,115,119,123,136,137,138,139,140,141,149,154,156,157,159,164,168,181,182,183,184,186,193,195,196,199,202,204,206,216)
group by tg.PROK_GROUP_ID
order by tg.PROK_GROUP_ID

) as t


select *
from GENE_BLO_SEQS 
where gene_id in (110,111,112,113,114,115,119,123,136,137,138,139,140,141,149,154,156,157,159,164,168,181,182,183,184,186,193,195,196,199,202,204,206,216)
 
Taxon.joins(:ncbi_seq => :gene_blo_seq) \
      .joins(:taxon_group) \
      .group("prok_group_id") \
      .select("prok_group_id, sum(weight_pg) as cnt") \
      .each_with_object({ }){ |c, hsh| hsh[c.prok_group_id] = c.cnt.to_f }


select pg.ID as prok_group_id,
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
					where tg.PROK_GROUP_ID between 0 and 22 
					      --and gbs.GENE_ID in (110,111,112,113,114,115,119,123,136,137,138,139,140,141,149,154,156,157,159,164,168,181,182,183,184,186,193,195,196,199,202,204,206,216)
)
group by pg.id
) t2 on t2. id = pg.id 






select prok_group_id, count(*) as cnt
from taxons tx
 join NCBI_SEQS_TAXONS nst on nst.TAXON_ID = tx.id
 join TAXON_GROUPS tg on tg.TAXON_ID = tx.id
where tx.id in ((select distinct tx.ID
                       from taxons tx
					 join NCBI_SEQS ns on ns.TAXON_ID = tx.ID
					 join GENE_BLO_SEQS gbs on gbs.NCBI_SEQ_ID = ns.id
					 join taxon_groups tg on tg.TAXON_ID = tx.ID
					where tg.PROK_GROUP_ID between 0 and 22 
					      and gbs.GENE_ID in (110,111,112,113,114,115,119,123,136,137,138,139,140,141,149,154,156,157,159,164,168,181,182,183,184,186,193,195,196,199,202,204,206,216)
))
group by tg.PROK_GROUP_ID
order by tg.PROK_GROUP_ID

      self.pgtn_hsh = Taxon.joins(:ncbi_seqs_taxon) \
      .joins(:taxon_group) \
      .group("prok_group_id") \
      .select("prok_group_id, count(*) as cnt") \
      .ea




select distinct tx.ID
from taxons tx
 join NCBI_SEQS ns on ns.TAXON_ID = tx.ID
 join GENE_BLO_SEQS gbs on gbs.NCBI_SEQ_ID = ns.id
 join taxon_groups tg on tg.TAXON_ID = tx.ID
where tg.PROK_GROUP_ID between 0 and 22 and
      gbs.GENE_ID in (110,111,112,113,114,115,119,123,136,137,138,139,140,141,149,154,156,157,159,164,168,181,182,183,184,186,193,195,196,199,202,204,206,216)

