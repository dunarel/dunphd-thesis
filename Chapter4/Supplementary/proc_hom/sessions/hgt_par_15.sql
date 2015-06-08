select ns.*,
       tg.*
from NCBI_SEQS ns
 join TAXON_GROUPS tg on tg.ID = ns.TAXON_ID
--order by taxon_id

select distinct TAXON_ID
from TAXON_GROUPS

select *
from NCBI_SEQS_TAXONS nst
 join TAXON_GROUPS tg on tg.TAXON_ID = nst.TAXON_ID


select count(*)
from TAXON_GROUPS tg
where id in (select id
             from TAXON_GROUPS tg
             join PROK_GROUPS pg on pg.ID = tg.PROK_GROUP_ID
             join GROUP_CRITERS gc on gc.ID = pg.GROUP_CRITER_ID
             where gc.NAME = 'habitat')



select ht.id
from hgt_com_int_transfers ht
 left join HGT_COM_INT_FRAGMS hf on hf.ID = ht.HGT_COM_INT_FRAGM_ID
 left join NCBI_SEQS ns_src on ns_src.id = ht.SOURCE_ID
 left join TAXON_GROUPS tg_src on tg_src.TAXON_ID = ns_src.TAXON_ID
 left join PROK_GROUPS pg_src on pg_src.ID = tg_src.PROK_GROUP_ID
 left join GROUP_CRITERS gc_src on gc_src.ID = pg_src.GROUP_CRITER_ID
 left join NCBI_SEQS ns_dest on ns_dest.id = ht.DEST_ID
 left join TAXON_GROUPS tg_dest on tg_dest.TAXON_ID = ns_dest.TAXON_ID
 left join PROK_GROUPS pg_dest on pg_dest.ID = tg_dest.PROK_GROUP_ID
 left join GROUP_CRITERS gc_dest on gc_dest.ID = pg_dest.GROUP_CRITER_ID
where tg_src.PROK_GROUP_ID = tg_dest.PROK_GROUP_ID and
       hf.HGT_TYPE = 'Trivial' and
       gc_src.NAME = 'family' and
       gc_dest.NAME = 'family'


select *
from HGT_COM_INT_TRANSFERS

select distinct PROK_GROUP_SOURCE_ID
from HGT_COM_INT_TRANSFER_GROUPS


select count(*)
from GENE_GROUP_CNTS

select distinct(PROK_GROUP_ID)
from GENE_GROUP_CNTS


select distinct PROK_GROUP_DEST_ID
from HGT_COM_GENE_GROUPS_VALS

select sum(cnt)
from GENE_GROUP_CNTS
where PROK_GROUP_ID = 14


SELECT count(distinct TAXON_ID) as cnt 
FROM taxon_groups 
INNER JOIN ncbi_seqs ON ncbi_seqs.taxon_id = taxon_groups.id 
INNER JOIN gene_blo_seqs ON gene_blo_seqs.ncbi_seq_id = ncbi_seqs.id 
WHERE (prok_group_id=14) 
GROUP BY prok_group_id

select prok_group_id, count(taxon_id)
from taxon_groups
where TAXON_ID in (select distinct taxon_id
                   from ncbi_seqs_taxons)
group by PROK_GROUP_ID


SELECT count(distinct ID) as cnt 
FROM taxons 
INNER JOIN ncbi_seqs_taxons ON ncbi_seqs_taxons.taxon_id = taxons.id
INNER JOIN taxon_groups ON taxon_groups.taxon_id = taxons.id 
WHERE (prok_group_id=86) 
GROUP BY prok_group_id

