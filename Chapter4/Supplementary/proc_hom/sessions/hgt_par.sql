select  max(length(from_subtree)),
        max(length(to_subtree))
from HGT_COM_INT_FRAGMS t





select count(*)
from HGT_COM_INT_FRAGMS

select count(*)
from HGT_COM_INT_CONTINS

select count(*)
from system_lobs.lob_ids 

SELECT sum(lob_length)/(1024.0*1024.0) FROM system_lobs.lob_ids

checkpoint

drop table HGT_PAR_FRAGMS

select count(*)
from hgt_par_fragms

select *
from RECOMB_TRANSFER_GROUPS
where SOURCE_ID=5 and DEST_ID=0


select sum(weight)
from HGT_
e HGT_COM_INT_FRAGM_ID = 67304

DROP TABLE "PUBLIC"."HGT_PAR_TRANSFERS";

select *
from HGT_PAR_FRAGMS
where HGT_PAR_CONTIN_ID = 1566

select *
from hgt_par_contins
where bs_val >= 50


select *
from hgt_par_fragms
where HGT_PAR_CONTIN_ID is not null


select hpf.HGT_PAR_CONTIN_ID,
       hpt.*,
       hpc.length
from hgt_par_transfers hpt
join HGT_PAR_FRAGMS hpf on hpf.ID = hpt.HGT_PAR_FRAGM_ID
join HGT_PAR_CONTINS hpc on hpc.id = hpf.HGT_PAR_CONTIN_ID
where  hpf.HGT_PAR_CONTIN_ID = 6571
order by hgt_par_contin_id

select *
from HGT_PAR_CONTINS
where id = 6571

select *
from HGT_PAR_FRAGMS
where HGT_PAR_CONTIN_ID=6571

select *
from hgt_par_



checkpoint