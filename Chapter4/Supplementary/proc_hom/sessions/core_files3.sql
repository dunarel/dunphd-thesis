select sum(WEIGHT_TR_TX)/110
from HGT_COM_TRSF_TAXONS

select count(*)
from GENES gn


--genes coverage in nb of taxons
select gn_cov.gene_id,
       gn_cov.cover
from 
(
 select txn.gene_id,
        count(*)/1.11 as cover
 from 
 (
 select gbs.GENE_ID,
        tx.ID,
        tx.TREE_NAME,
        count(*)
 from gene_blo_seqs gbs
  join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
  join TAXONS tx on tx.ID = ns.TAXON_ID
 group by gbs.GENE_ID,
        tx.ID,
        tx.TREE_NAME
 order by gbs.gene_id,
          count(*) desc
 ) txn
 group by txn.gene_id
) gn_cov
where gn_cov.cover >=95



--
select gn_pg.gene_id,
       gn_pg.prok_group_id,
       count(*) as tx_in_pg
from 
(


 select gbs.GENE_ID,
        gbs.NCBI_SEQ_ID,
        ns.VERS_ACCESS,
        tx.ID,
        tx.TREE_NAME,
        tg.PROK_GROUP_ID
 from gene_blo_seqs gbs
  join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
  join TAXONS tx on tx.ID = ns.TAXON_ID
  join TAXON_GROUPS tg on tg.TAXON_ID = ns.TAXON_ID
 where tg.PROK_GROUP_ID between 0 and 22 and
       gene_id = 110
 order by gbs.GENE_ID,
          tx.TREE_NAME

) gn_pg 
group by gn_pg.gene_id,
         gn_pg.prok_group_id
         





select gn.id,
       gn.NAME,
       count(*)
from GENE_BLO_SEQS gbs
 join genes gn on gn.ID = gbs.GENE_ID
group by gn.id
order by count(*) desc


select gbs.GENE_ID,
        gbs.NCBI_SEQ_ID,
        ns.VERS_ACCESS,
        tx.ID,
        tx.TREE_NAME,
        tg.PROK_GROUP_ID
 from gene_blo_seqs gbs
  join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
  join TAXONS tx on tx.ID = ns.TAXON_ID
  join TAXON_GROUPS tg on tg.TAXON_ID = ns.TAXON_ID
 where tg.PROK_GROUP_ID between 0 and 22 and
       gene_id = 110
 order by gbs.GENE_ID,
          tx.TREE_NAME


--
select alg.gene_id,
       alg.prok_group_id,
       alg.taxon_id,
       count(*) as ncbi_seq_id_cnt
from 
(

select gbs.GENE_ID,
        tg.PROK_GROUP_ID,
        ns.TAXON_ID,        
        gbs.NCBI_SEQ_ID
 from gene_blo_seqs gbs
  join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
  join TAXONS tx on tx.ID = ns.TAXON_ID
  join TAXON_GROUPS tg on tg.TAXON_ID = ns.TAXON_ID
 where tg.PROK_GROUP_ID between 0 and 22 
       and gene_id = 152
 order by gbs.GENE_ID,
        tg.PROK_GROUP_ID,
        ns.TAXON_ID,        
        gbs.NCBI_SEQ_ID

) alg
group by alg.gene_id,
         alg.prok_group_id,
         alg.taxon_id

--
select gn.name,
       alg2.gn,
       alg2.pg_cnt,
       alg2.tx_cnt,
       alg2.al_cnt
from
(
with alg(gn,pg,tx,al) as (select gbs.GENE_ID,
        tg.PROK_GROUP_ID,
        ns.TAXON_ID,        
        gbs.NCBI_SEQ_ID
 from gene_blo_seqs gbs
  join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
  join TAXONS tx on tx.ID = ns.TAXON_ID
  join TAXON_GROUPS tg on tg.TAXON_ID = ns.TAXON_ID
 where tg.PROK_GROUP_ID between 0 and 22 
       --and gene_id = 152
 order by gbs.GENE_ID,
        tg.PROK_GROUP_ID,
        ns.TAXON_ID,        
        gbs.NCBI_SEQ_ID) 
select alg.gn,
       count(distinct gn,pg) as pg_cnt,
       count(distinct gn,pg,tx) as tx_cnt,
       count(distinct gn,pg,tx,al) as al_cnt
from alg
group by alg.gn
) alg2
join genes gn on gn.ID = alg2.gn

        
select alg.gn,
       0,
       0,
       count(*) as al_cnt
from alg
group by alg.gn
 union
select alg.gn,
       0,
       0,
       count(*) as al_cnt
from alg
group by alg.gn



select gn.id,
       gci.name       
from GENES_CORE_INTER gci
 join GENES gn on gn.name = gci.name


 select sum(WEIGHT_TR_TX)/36
 from HGT_COM_TRSF_TAXONS hctt
   join GENES_CORE_INTER gci on gci.id = hctt.GENE_ID

 select sum(WEIGHT_TR_TX)/110.0
 from HGT_COM_TRSF_TAXONS hctt
   join GENES gn on gn.id = hctt.GENE_ID


 select gci.id,
        gci.NAME,
        sum(hctt.WEIGHT_TR_TX)
 from HGT_COM_TRSF_TAXONS hctt
   join GENES_CORE_INTER gci on gci.id = hctt.GENE_ID
 group by gci.id,
        gci.NAME









--
select gci.*
from GENES_CORE_INTER gci


 select tx_aff.*
 from
(


 select count(*)
 from HGT_COM_TRSF_TAXONS hctt_src

 
   join HGT_COM_TRSF_TAXONS hctt_dst on hctt_dst.GENE_ID = hctt_src.gene_id
 
 where hctt.GENE_ID = 112
 union
 select hctt.TXDST_ID
 from HGT_COM_TRSF_TAXONS hctt
 where hctt.GENE_ID = 112




) as tx_aff
 

 