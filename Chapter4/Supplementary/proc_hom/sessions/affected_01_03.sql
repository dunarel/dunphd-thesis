--pgsn
select prok_group_id,
       sum(weight_pg) as pgsn_cnt
from TAXONS txc
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
 


create view genes_taxons as 
select distinct gn.ID as gene_id,
                ns.TAXON_ID
from GENES gn
 join GENE_BLO_SEQS gbs on gbs.GENE_ID = gn.id
 join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID



select tg.PROK_GROUP_ID,
  nvl(sum(hctt_src.WEIGHT_TR_TX),0) as pg_weight
  from HGT_COM_TRSF_TAXONS hctt_src
  right outer join TAXON_GROUPS tg on tg.TAXON_ID = hctt_src.TXSRC_ID
  where tg.PROK_GROUP_ID between 0 and 22
  group by tg.PROK_GROUP_ID
  order by tg.PROK_GROUP_ID       




select tg.PROK_GROUP_ID,
  nvl(sum(hctt_src.WEIGHT_TR_TX),0) as pg_weight
  from HGT_COM_TRSF_TAXONS hctt_src
  join GENES_CORE_INTER gci on gci.ID = hctt_src.GENE_ID
  right outer join TAXON_GROUPS tg on tg.TAXON_ID = hctt_src.TXSRC_ID
  where tg.PROK_GROUP_ID between 0 and 22
  group by tg.PROK_GROUP_ID
  order by tg.PROK_GROUP_ID

select *
from pgtn_core


select tg.PROK_GROUP_ID,
       count(sel_tx.taxon_id) as pgtn_cnt
from 
(
select distinct taxon_id
from GENES_TAXONS gt
 join GENES_CORE_INTER gci on gci.id = gt.GENE_ID
) sel_tx
 join TAXON_GROUPS tg on tg.TAXON_ID = sel_tx.TAXON_ID
where tg.PROK_GROUP_ID between 0 and 22 
group by tg.PROK_GROUP_ID 
order by tg.PROK_GROUP_ID










join GENES_CORE_INTER gci on gci.ID = gn.ID






----------------------------------------------------pgsn
select prok_group_id,
       sum(weight)
from
(
--gene_group_cnts
select gene_id,
       prok_group_id,
       taxon_id,
       vers_access,
       sum(weight_pg) as weight
from 
(
select gbs.GENE_ID,
       tg.PROK_GROUP_ID,
       ns.VERS_ACCESS,
       ns.TAXON_ID,
       tg.weight_pg as weight_pg
from GENE_BLO_SEQS gbs
 join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
 join TAXON_GROUPS tg on tg.TAXON_ID = ns.TAXON_ID
 join PROK_GROUPS pg on pg.ID = tg.PROK_GROUP_ID
order by gbs.GENE_ID,
         tg.PROK_GROUP_ID
)
group by gene_id,
         taxon_id,
         prok_group_id,
         vers_access         
order by gene_id,
         prok_group_id,
         vers_access,
         taxon_id
)
group by prok_group_id
order by prok_group_id

----------------------pgtn
select distinct gn.ID as gene_id,
                ns.TAXON_ID

select gn.id as gene_id,
       
select distinct gene_id,
                NCBI_SEQ_ID
 from GENE_BLO_SEQS gbs 


select distinct ns.TAXON_ID                


select distinct taxon_id
from GENES_TAXONS


select *
from GENES_TAXONS_SEQS

(
--al 
select gbs.GENE_ID,
       ns.TAXON_ID,
       gbs.NCBI_SEQ_ID       
 from genes gn 
 join GENE_BLO_SEQS gbs on gbs.GENE_ID = gn.ID 
 join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
)


select *
from GENE_BLO_SEQS

YP_004893690.1

352683166
352683166 = ncbi_seq_id







---------------------pgtn try
select prok_group_id,
       sum(weight)
from 
(
select gene_id,
       prok_group_id,
       taxon_id,
       sum(weight_pg) as weight
from 
(
select distinct gene_id,prok_group_id,weight_pg,taxon_id
from 
(
select gbs.GENE_ID,
       tg.PROK_GROUP_ID,
       ns.TAXON_ID,
       ns.VERS_ACCESS,
       tg.weight_pg as weight_pg
from GENE_BLO_SEQS gbs
 join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
 join TAXON_GROUPS tg on tg.TAXON_ID = ns.TAXON_ID
 join PROK_GROUPS pg on pg.ID = tg.PROK_GROUP_ID
order by gbs.GENE_ID,
         tg.PROK_GROUP_ID
)
)
group by gene_id,
         prok_group_id,
         taxon_id
order by gene_id,
         prok_group_id,
         taxon_id
)
group by PROK_GROUp_id
order by PROK_GROUp_id



select *
from genes_taxons

--new pgsn
select prok_group_id,
       sum(weight_pg) as pgsn_cnt
from TAXONS tx
 join GENES_TAXONS gts on gts.TAXON_ID = tx.ID
 join taxon_groups tg on tg.TAXON_ID = gts.TAXON_ID
group by prok_group_id
order by PROK_GROUP_ID

--new pgtn
select prok_group_id,
       sum(weight_pg) as pgsn_cnt
from TAXONS tx
 join taxon_groups tg on tg.TAXON_ID = tx.ID
group by prok_group_id
order by PROK_GROUP_ID



----------pgsn
select prok_group_id,
       sum(weight_pg) as pgsn_cnt
from TAXONS tx
 join ncbi_seqs ns on ns.TAXON_ID = tx.id
 join gene_blo_seqs gbs on gbs.NCBI_SEQ_ID = ns.ID
 join taxon_groups tg on tg.TAXON_ID = tx.ID
where tg.PROK_GROUP_ID between 0 and 22
group by prok_group_id
order by tg.PROK_GROUP_ID




---pgtn
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


