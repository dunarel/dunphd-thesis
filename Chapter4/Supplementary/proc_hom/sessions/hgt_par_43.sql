select gbs.gene_id,
       count(*)
from GENE_BLO_SEQS gbs
group by GENE_ID
order by count(*) desc

select gbs.NCBI_SEQ_ID
from GENE_BLO_SEQS gbs
where gbs.GENE_ID = 148
order by gbs.NCBI_SEQ_ID

select hpf.GENE_ID,
count(*)
from HGT_PAR_FRAGMS hpf
group by gene_id
order by count(*) desc

select *
from HGT_PAR_FRAGMS

select *
from GENE_BLO_SEQS gbs
where NCBI_SEQ_ID = 217076622

select gbs.NCBI_SEQ_ID
from GENE_BLO_SEQS gbs
where gbs.GENE_ID = 118
order by gbs.NCBI_SEQ_ID