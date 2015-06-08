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

select sum(hcit.WEIGHT)
from HGT_COM_INT_TRANSFERS hcit

select sum(hpt.WEIGHT)
from HGT_PAR_TRANSFERS hpt

select count(*)
from HGT_PAR_FRAGMS
