select count(distinct gbs.NCBI_SEQ_ID)
from GENE_BLO_SEQS gbs

select tg.PROK_GROUP_ID,count(*)
from TAXON_GROUPS tg
where tg.PROK_GROUP_ID between 0 and 22
group by tg.PROK_GROUP_ID

select *
from TAXON_GROUPS tg
where tg.PROK_GROUP_ID between 0 and 22 and
      tg.WEIGHT_PG is not null

select count(*)
from 
(
select gbs.NCBI_SEQ_ID,
       ns.TAXON_ID,
       count(*)
from gene_blo_seqs gbs 
 join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
group by gbs.NCBI_SEQ_ID,
       ns.TAXON_ID
)

select *
from GENE_BLO_SEQS gbs
 join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID


select *
from GENE_BLO_SEQS gbs
 join 


--taxons from tree 
select tx.TREE_ORDER,
       tx.ID,
       tx.TREE_NAME,
       tx.SCI_NAME
from taxons tx
order by tx.TREE_ORDER

