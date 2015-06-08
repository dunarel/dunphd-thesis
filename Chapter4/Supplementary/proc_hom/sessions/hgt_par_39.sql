
select hpc.id,
       hpc.gene_id,
       count(*)
from hgt_par_contins hpc
  join HGT_PAR_FRAGMS hpf on hpf.hgt_par_contin_id = hpc.id
group by hpc.id,
         hpc.gene_id
order by hpc.gene_id,
         hpc.id