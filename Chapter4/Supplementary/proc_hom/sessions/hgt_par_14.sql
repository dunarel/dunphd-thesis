insert into NCBI_SEQS_TAXONS
(taxon_id)
select distinct taxon_id
from NCBI_SEQS
order by taxon_id

select count(distinct taxon_id)
from NCBI_SEQS_TAXONS

delete from NCBI_SEQS_TAXONS

UPDATE ncbi_seqs_taxons SET img_taxon_oid = 2511231068, updated_at = '2012-05-28 20:10:40' WHERE ncbi_seqs_taxons.id = 92


select *
from INFORMATION_SCHEMA.SYSTEM_TABLES
where HSQLDB_TYPE='CACHED'


select count(*)
from NCBI_SEQS_TAXONS
where IMG_TAXON_OID is null

update NCBI_SEQS_TAXONS
set IMG_TAXON_OID = NULL 
where IMG_TAXON_OID = 0


select *
from PROK_GROUPS
where GROUP_CRITER_ID = 1
order by id



select *
from NCBI_SEQS_TAXONS

select *
from NCBI_SEQS


select *
from TAXON_GROUPS tg
 join PROK_GROUPS pg on pg.id = tg.PROK_GROUP_ID
where pg.GROUP_CRITER_ID = 1 and 
      tg.TAXON_ID in ( select tg2.taxon_id
                       from TAXON_GROUPS tg2
                       join PROK_GROUPS pg on pg.id = tg2.PROK_GROUP_ID    
                       where pg.id = 14 
     )

