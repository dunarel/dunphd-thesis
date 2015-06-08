
select gbs.NCBI_SEQ_ID
                from GENE_BLO_SEQS gbs
                where gbs.GENE_ID = 110
                order by gbs.NCBI_SEQ_ID

select id,
       fen_idx_min,
       fen_idx_max,
       from_subtree,
       to_subtree
from hgt_par_fragms
where gene_id = 110
order by id                
