select gn.id,gn.id -110, count(*)
from genes gn
 join HGT_PAR_FRAGMS hpf on hpf.GENE_ID = gn.id
group by gn.id
order by count(*) desc