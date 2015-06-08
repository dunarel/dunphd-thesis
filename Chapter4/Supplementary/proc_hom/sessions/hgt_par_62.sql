select count(*)
from HGT_PAR_FRAGMS hpf

select count(*)
from HGT_PAR_CONTINS hpc

where hpc.BS_VAL > 75

select count(*)
from HGT_PAR_FRAGMS hpf
where hpf.CONTIN_REALIGN_STATUS = 'Reference'

select count(*)
from hgt_com_int_contins hcc

select count(*)
from HGT_COM_TRSF_TIMINGS hctt
where hctt.TIMING_CRITER_ID = 0


select sum(hcit.WEIGHT)
from HGT_COM_INT_TRANSFERS hcit

select count(distinct hcit.HGT_COM_INT_FRAGM_ID)
from HGT_COM_INT_TRANSFERS hcit



select sum(hpt.WEIGHT)
from HGT_PAR_TRANSFERS hpt

select count(*)
from HGT_PAR_CONTINS hpc
where hpc.BS_VAL >= 75

select sum(hpt.WEIGHT)
from HGT_PAR_TRANSFERS hpt
group by hpt.HGT_PAR_CONTIN_ID
having sum(hpt.WEIGHT) = 1


delete from HGT_PAR_TRANSFERS



select sum(hpt.WEIGHT)
from HGT_PAR_TRANSFERS hpt

select count(*)
from 
(
select hpc.id,
       max(hpf.BS_VAL) as max_bs
from HGT_PAR_CONTINS hpc 
 join HGT_PAR_FRAGMS hpf on hpf.HGT_PAR_CONTIN_ID = hpc.ID
where hpc.BS_VAL > 75
group by hpc.ID
)

select count(*)
from
(


--COM fragms
select *
from HGT_COM_INT_FRAGMS hcif
where hcif.BS_VAL >= 95

--COM genes 
select distinct gene_id 
from HGT_COM_INT_FRAGMS hcif
where hcif.BS_VAL >= 95


--PAR delete useless fragments
delete from HGT_PAR_FRAGMS hpf4
where hpf4.id not in 
(
select hpf3.id
from HGT_PAR_FRAGMS hpf3
where (hpf3.HGT_PAR_CONTIN_ID, hpf3.ID) in 
(
select hpf2.HGT_PAR_CONTIN_ID,
       min(hpf2.ID) as min_frag_id
       --max(hpf2.FEN_NO) as max_fen,
       --count(hpf2.ID) as cnt_fen       
 from hgt_par_fragms hpf2
 --inside comment
 where (hpf2.HGT_PAR_CONTIN_ID,hpf2.BS_VAL) in (select hpc.id,
                                                       max(hpf.BS_VAL) as max_bs
                                                from HGT_PAR_CONTINS hpc 
                                                 join HGT_PAR_FRAGMS hpf on hpf.HGT_PAR_CONTIN_ID = hpc.ID
                                                where hpc.BS_VAL >= 95
                                                group by hpc.ID)
 group by hpf2.HGT_PAR_CONTIN_ID
)
)                          

--PAR fragms
select count(*)
from HGT_PAR_FRAGMS hpf


--PAR windows
select distinct hpf.GENE_ID,
                hpf.WIN_SIZE,
                hpf.FEN_NO
from HGT_PAR_FRAGMS hpf





                                             
                                             from HGT_PAR_CONTINS hpc 
                                                 join HGT_PAR_FRAGMS hpf on hpf.HGT_PAR_CONTIN_ID = hpc.ID
                                                where hpc.BS_VAL > 85
                                                group by hpc.ID




select count(*)
from hgt_par_contins hpc
where hpc.BS_VAL > 50

select count(*)
from HGT_PAR_FRAGMS
