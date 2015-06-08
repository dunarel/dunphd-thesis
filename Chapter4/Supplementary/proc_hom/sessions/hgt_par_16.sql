select *
from HGT_COM_INT_TRANSFER_GROUPS
where PROK_GROUP_SOURCE_ID = 12 and
      PROK_GROUP_DEST_ID = 91


select *
from PROK_GROUPS
where GROUP_CRITER_ID = 0
order by order_id


select *
from NCBI_SEQS ns
 join TAXON_GROUPS tg on tg.ID = ns.TAXON_ID


 SELECT  prok_group_id,count(*) as cnt 
 FROM taxons 
 INNER JOIN ncbi_seqs  ON ncbi_seqs.taxon_id = taxons.id 
 INNER JOIN taxon_groups ON taxon_groups.taxon_id = taxons.id 
 INNER JOIN GENE_BLO_SEQS ON GENE_BLO_SEQS.NCBI_SEQ_ID = ncbi_seqs.id 
 GROUP BY prok_group_id


 select count(id)
 from NCBI_SEQS

 select count(*)
 from GENE_BLO_SEQS
 