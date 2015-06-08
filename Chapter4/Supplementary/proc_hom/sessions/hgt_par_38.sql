

select *
from HGT_PAR_CONTINS hpc
where hpc.ID = 2152019

select *
from HGT_PAR_FRAGMS hpf 
where hpf.HGT_PAR_CONTIN_ID = 2152019


select *
from HGT_PAR_TRANSFERS hpt
where hpt.HGT_PAR_CONTIN_ID = 2152019

select *
from genes

from HGT_PAR_TRANSFERS hpt 
group by HGT_PAR_CONTIN_ID



select HGT_PAR_CONTIN_ID, sum(weight) as somme
from HGT_PAR_TRANSFERS hpt 
group by HGT_PAR_CONTIN_ID

select *
from 
(
select HGT_PAR_CONTIN_ID, sum(weight)  as somme
from HGT_PAR_TRANSFERS hpt 
group by HGT_PAR_CONTIN_ID
) tb
where tb.somme >= 1.1

select count(distinct hpc.ID)
from HGT_PAR_CONTINS hpc
 join HGT_PAR_FRAGMS hpf on hpf.HGT_PAR_CONTIN_ID = hpc.ID
where hpf.BS_VAL >=50

select sum(weight)/2
from HGT_PAR_TRANSFERS


select count(*)
from HGT_PAR_CONTINS
where bs_val>=50

select *
from HGT_PAR_FRAGMS hpf
 join HGT_PAR_CONTINS hpc on hpc.ID = hpf.HGT_PAR_CONTIN_ID
where hpf.BS_VAL >= 50

select count(*)
from HGT_PAR_CONTINS hpc
where hpc.BS_VAL >= 75


select sum(weight)
from HGT_PAR_TRANSFERS
join TAXON_GROUPS tg.
where 



select count(*)
from HGT_PAR_CONTINS

select count(*)
from 
(
select hgt_par_contin_id,sum(hpt.WEIGHT)
from HGT_PAR_TRANSFERS hpt
group by hpt.HGT_PAR_CONTIN_ID
)


select *
from HGT_PAR_CONTINS hpc
where id not in (select hgt_par_contin_id
from HGT_PAR_TRANSFERS hpt
group by hpt.HGT_PAR_CONTIN_ID)

select count(*) 
from HGT_PAR_CONTINS hpc
where hpc.BS_VAL >= 75


select count(*)
from HGT_PAR_FRAGMS



select sum(weight)
from HGT_PAR_TRANSFERS

select count(hpf.ID)
from HGT_PAR_CONTINS hpc
join HGT_PAR_FRAGMS hpf on hpf.HGT_PAR_CONTIN_ID = hpc.ID
where bs_val >= 75

commit;
