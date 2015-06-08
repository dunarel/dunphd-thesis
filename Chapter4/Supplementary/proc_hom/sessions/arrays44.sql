-- convert a particular sequence into a table
SELECT offset,codon
FROM UNNEST((SELECT names FROM t))
     WITH ORDINALITY 
 AS codon_table(codon,offset)
order by offset desc

select *
from table(names) t


SELECT ID, FIRSTNAME, LASTNAME, ARRAY_AGGREGATE(CAST(INVOICE.TOTAL AS VARCHAR(100)))
FROM customer 
 JOIN INVOICE ON ID =CUSTOMERID
GROUP BY ID, FIRSTNAME, LASTNAME

SELECT hpc.ID,
       hpc.GENE_ID,
       ARRAY_AGGREGATE(CAST(hpf.ID AS VARCHAR(100)))
FROM HGT_PAR_CONTINS hpc
 join HGT_PAR_FRAGMS hpf on hpf.HGT_PAR_CONTIN_ID = hpc.id 
GROUP BY hpc.ID,
       hpc.GENE_ID

select rownum(),
       tbl.*
from(
SELECT * 
FROM UNNEST(SEQUENCE_ARRAY(10, 12, 1))
) tbl

alter table HGT_PAR_FRAGMS
add column to_arr INT ARRAY[256] DEFAULT ARRAY[]

alter table HGT_PAR_FRAGMS
drop column to_arr


select *
from hgt_par_fragms
where HGT_PAR_CONTIN_ID is null



alter table genes
add column ncbi_seq_ids INT ARRAY[256] DEFAULT ARRAY[]

alter table genes
drop column NCBI_SEQ_IDS

select *
from unnest((select NCBI_SEQ_IDS 
             from genes 
             where id = 110
             ))



update genes gn
set gn.ncbi_seq_ids = ARRAY(select distinct gbs.NCBI_SEQ_ID 
                            from GENE_BLO_SEQS gbs
                            where gbs.GENE_ID = gn.id
                            order by gbs.NCBI_SEQ_ID)

--where gn.id = 110

select * 
from unnest((
select gn.NCBI_SEQ_IDS
from GENES gn
where gn.id = 110
))


SELECT gn.id,
       gn.NAME,
       cardinality(gn.ncbi_seq_ids)
from genes gn
order by cardinality(gn.ncbi_seq_ids) desc

FROM UNNEST(SEQUENCE_ARRAY(1, 255, 1))

update genes 
set NCBI_SEQ_IDS = SEQUENCE_ARRAY(1, 257, 1)

