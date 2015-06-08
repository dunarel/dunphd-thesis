--pgsn
select prok_group_id,
       sum(weight_pg) as pgsn_cnt
from TAXONS tx
join ncbi_seqs ns on ns.TAXON_ID = tx.id
join gene_blo_seqs gbs on gbs.NCBI_SEQ_ID = ns.ID
join taxon_groups tg on tg.TAXON_ID = tx.ID
--join GENES_CORE_INTER gci on gci.ID = gbs.GENE_ID
where tg.PROK_GROUP_ID between 0 and 22
group by prok_group_id
order by tg.PROK_GROUP_ID


--pgtn
select prok_group_id,
           count(*) as cnt
from taxons tx
 join ncbi_seqs_taxons nst on nst.TAXON_ID = tx.id
 join taxon_groups tg on tg.TAXON_ID = tx.id
group by tg.PROK_GROUP_ID
order by tg.PROK_GROUP_ID

 
--pgtn2
select tg.PROK_GROUP_ID,
       count(sel_tx.taxon_id) as pgtn_cnt
from 
(
select distinct TAXON_ID
from GENES_TAXONS gt 
 --join GENES_CORE_INTER gci on gci.id = gt.GENE_ID
) sel_tx
 join TAXON_GROUPS tg on tg.TAXON_ID = sel_tx.TAXON_ID
where tg.PROK_GROUP_ID between 0 and 22 
group by tg.PROK_GROUP_ID 
order by tg.PROK_GROUP_ID

select *
from pgsn


select *
from GENES_TAXONS


--taxons by genes
create view genes_taxons as 

select distinct gn.ID as gene_id,
       ns.TAXON_ID
from GENES gn
 join GENE_BLO_SEQS gbs on gbs.GENE_ID = gn.id
 join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID


select 



select gbs.GENE_ID,
      tg.PROK_GROUP_ID,
      ns.TAXON_ID,
      gbs.NCBI_SEQ_ID
      from gene_blo_seqs gbs
      join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
      join TAXONS tx on tx.ID = ns.TAXON_ID
      join TAXON_GROUPS tg on tg.TAXON_ID = ns.TAXON_ID
      where tg.PROK_GROUP_ID between 0 and 22

--receive by prok-group
select pg.order_id,
       pg_tx_src.prok_group_id,
       pg_tx_src.pg_weight,
       pgsn.pgsn_cnt,
       pgtn.PGTN_CNT,
       pg_tx_src.pg_weight /pgsn.pgsn_cnt * 100 / 1.1 as pgsn_magic,
       pg_tx_src.pg_weight /pgtn.pgtn_cnt * 100 / 1.1 as pgtn_magic
from 
(
 select tg.PROK_GROUP_ID,
        sum(hctt_src.WEIGHT_TR_TX) as pg_weight
 from HGT_COM_TRSF_TAXONS hctt_src
  join TAXON_GROUPS tg on tg.TAXON_ID = hctt_src.TXSRC_ID
 where tg.PROK_GROUP_ID between 0 and 22
 group by tg.PROK_GROUP_ID
 order by tg.PROK_GROUP_ID
) pg_tx_src
 join pgsn on pgsn.prok_group_id = pg_tx_src.prok_group_id
 join pgtn on pgtn.PROK_GROUP_ID = pg_tx_src.prok_group_id
 join PROK_GROUPS pg on pg.id = pg_tx_src.prok_group_id
 order by pg.order_id 





select tg.PROK_GROUP_ID,
       count(sel_tx.taxon_id) as pgtn
      from (select distinct TAXON_ID
            from GENES_TAXONS gt 
             --join GENES_CORE_INTER gci on gci.id = gt.GENE_ID
            ) sel_tx
       join TAXON_GROUPS tg on tg.TAXON_ID = sel_tx.TAXON_ID
where tg.PROK_GROUP_ID between 0 and 22 
group by tg.PROK_GROUP_ID




 

on pgtn.prok_group_id =  pg_tx_src.prok_group_id
 


      
      