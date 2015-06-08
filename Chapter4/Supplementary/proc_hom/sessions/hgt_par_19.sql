select distinct TAXON_ID
from NCBI_SEQS_TAXONS
order by taxon_id

select count(*)
from TAXONS

select name
from prok_groups
where GROUP_CRITER_ID = 0
order by name