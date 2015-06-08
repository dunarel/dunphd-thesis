select distinct TAXON_I
D
from NCBI_SEQS_TAXONS
order by taxon_id

select count(*)
from TAXONS

select *
from taxons
order by id

select name
from prok_groups
where GROUP_CRITER_ID = 0
order by name