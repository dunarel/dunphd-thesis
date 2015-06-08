
select gbs.GENE_ID,count(*)
from GENE_BLO_SEQS gbs
group by gbs.GENE_ID
order by count(*) desc


select ROWNUM(),t.*
from 
(
 select ag.*
 from ALL_GENES ag
 where SEQS_ORIG_NB is not null
 order by SEQS_ORIG_NB desc
) t