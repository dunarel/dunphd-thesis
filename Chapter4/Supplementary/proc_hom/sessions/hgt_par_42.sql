select gbs.gene_id,
       count(*)
from GENE_BLO_SEQS gbs
group by GENE_ID
order by count(*) desc

select *
from GENE_BLO_SEQS gbs
where gbs.GENE_ID = 148