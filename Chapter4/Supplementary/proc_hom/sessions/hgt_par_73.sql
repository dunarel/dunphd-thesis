select ms.mrca_id,
       count(*)
from MRCA_STDEVS ms
group by mrca_id
order by count(*) desc