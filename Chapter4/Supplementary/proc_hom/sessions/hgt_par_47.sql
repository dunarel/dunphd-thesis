
 checkpoint defrag
 
 backup database to '/root/devel/backup/db_srv/' blocking

 select id, id- 110, 
        gn.NAME
 from genes gn

select *
from HGT_COM_INT_CONTINS hc
where hc.age_md is not null

select *
from HGT_COM_INT_CONTINS hc
where gene_id = 110 

hc.age_md is not null

select hc.gene_id,
       hc.FROM_SUBTREE,
       hc.TO_SUBTREE,
       hc.AGE_MD
from HGT_COM_INT_CONTINS hc
where hc.gene_id = 164

select distinct(gene_id) -110
from HGT_COM_INT_CONTINS hc
where hc.AGE_MD is null



where hc.AGE_MD_WG is not null


select distinct(gene_id)
from HGT_COM_INT_CONTINS

select sum(tr.AGE_MD_WG) /sum(tr.WEIGHT)
from HGT_COM_INT_TRANSFERS tr

select sum(ttx.AGE_MD_WG_TR_TX) / sum(ttx.WEIGHT_TR_TX)
from HGT_COM_TRSF_TAXONS ttx

select ttp.PGSRC_ID,
       ttp.PGDST_ID,
        sum(ttp.AGE_MD_WG_TR_PG) / sum(ttp.WEIGHT_TR_PG)
from HGT_COM_TRSF_PRKGRS ttp
group by ttp.PGSRC_ID,
         ttp.PGDST_ID
order by ttp.PGSRC_ID,
         ttp.PGDST_ID     


select count(*)
from HGT_COM_INT_FRAGMS

select count(*)
from HGT_COM_INT_TRANSFERS ht
group by ht.HGT_COM_INT_FRAGM_ID


select count(*)
from 
(
select ht.HGT_COM_INT_FRAGM_ID,
         sum(WEIGHT) as wg,
         sum(AGE_MD_WG) as md_wg, 
         sum(AGE_MD_WG)/sum(WEIGHT) as md_wg_per_wg
from HGT_COM_INT_TRANSFERS ht
group by HGT_COM_INT_FRAGM_ID
)      



select ht.HGT_COM_INT_FRAGM_ID,
         sum(WEIGHT) as wg,
         sum(AGE_MD_WG) as md_wg, 
         sum(AGE_MD_WG)/sum(WEIGHT) as md_wg_per_wg
from HGT_COM_INT_TRANSFERS ht
group by HGT_COM_INT_FRAGM_ID


select max(md_wg_per_wg)
from 
(
select sum(AGE_MD_WG)/sum(WEIGHT) as md_wg_per_wg
from HGT_COM_INT_TRANSFERS ht
group by HGT_COM_INT_FRAGM_ID
)




having sum(WEIGHT) > 0 and sum(WEIGHT) < 1

select *
from HGT_COM_INT_CONTINS hc
where hc.HGT_COM_INT_FRAGM_ID = 300334



  

select sum(pr.WEIGHT_TR_PG)
from HGT_COM_TRSF_PRKGRS pr
 join PROK_GROUPS pg_src on pg_src.ID = pr.PGSRC_ID
 join PROK_GROUPS pg_dst on pg_dst.ID = pr.PGDST_ID
where pg_src.GROUP_CRITER_ID = 1 and
      pg_dst.GROUP_CRITER_ID = 1


select sum(AGE_MD_WG)/sum(WEIGHT) as md_wg_per_wg
from HGT_COM_INT_TRANSFERS ht
group by HGT_COM_INT_FRAGM_ID


select *
from HGT_COM_INT_TRANSFERS ht

select *
from HGT_COM_INT_CONTINS

                
 