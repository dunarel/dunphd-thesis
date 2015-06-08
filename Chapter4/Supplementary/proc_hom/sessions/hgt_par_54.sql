
select *
from HGT_COM_TRSF_TIMINGS hctt

select sum(hctt.AGE_MD_WG)/sum(hcit.WEIGHT)
from HGT_COM_INT_TRANSFERS hcit
 join HGT_COM_TRSF_TIMINGS hctt on hctt.HGT_COM_INT_TRANSFER_ID = hcit.id
where hctt.TIMING_CRITER_ID = 0 
group by hcit.HGT_COM_INT_FRAGM_ID

select m.id,
                  m.abrev,
                  m.time_min,
                  m.time_max
           from mrcas m
           where mrca_criter_id = 0
           order by m.time_max asc

select *
from genes
        