
select *
from gene


select gbs.NCBI_SEQ_ID
                from GENE_BLO_SEQS gbs
                where gbs.GENE_ID = 110
                order by gbs.NCBI_SEQ_ID

select hpf.gene_id,count(*)
from HGT_PAR_FRAGMS hpf 
group by hpf.GENE_ID
order by count(*) desc


select hpc.gene_id,count(*)
from HGT_PAR_CONTINS hpc
group by hpc.gene_id
order by count(*) desc


select id,
       fen_idx_min,
       fen_idx_max,
       from_subtree,
       to_subtree
from hgt_par_fragms
where gene_id = 110
order by id                
