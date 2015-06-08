
 checkpoint defrag
 
 backup database to '/root/devel/backup/db_srv/' blocking

 select hpf.fen_no,
        hpf.fen_idx_min,
        hpf.fen_idx_max
 from hgt_par_fens hpf
 where hpf.win_status = 'designed' and
       hpf.gene_id = 110 and
       hpf.win_size = 10
 order by hpf.fen_no

select *
from 
(
 select ggv_com.gene_id,
        ggv_com.PROK_GROUP_SOURCE_ID,
        ggv_com.PROK_GROUP_DEST_ID,
        ggv_com.val as com_val,
        ggv_par.val as par_val,
        greatest(nvl(ggv_com.val,0),nvl(ggv_par.val,0)) as val
 from HGT_COM_GENE_GROUPS_VALS ggv_com
  full outer join HGT_PAR_GENE_GROUPS_VALS ggv_par on ggv_par.GENE_ID = ggv_com.GENE_ID and
                                           ggv_par.PROK_GROUP_SOURCE_ID = ggv_com.PROK_GROUP_SOURCE_ID and
                                           ggv_par.PROK_GROUP_DEST_ID = ggv_com.PROK_GROUP_DEST_ID
)
where PROK_GROUP_SOURCE_ID = 8 and
      PROK_GROUP_DEST_ID = 17







 select ggv_com.gene_id,
        ggv_com.PROK_GROUP_SOURCE_ID,
        ggv_com.PROK_GROUP_DEST_ID,
        ggv_com.val as com_val,
        ggv_par.val as par_val,
        greatest(nvl(ggv_com.val,0),nvl(ggv_par.val,0)) as val
 from HGT_COM_GENE_GROUPS_VALS ggv_com
  full outer join HGT_PAR_GENE_GROUPS_VALS ggv_par on ggv_par.GENE_ID = ggv_com.GENE_ID and
                                           ggv_par.PROK_GROUP_SOURCE_ID = ggv_com.PROK_GROUP_SOURCE_ID and
                                           ggv_par.PROK_GROUP_DEST_ID = ggv_com.PROK_GROUP_DEST_ID
where PROK_GROUP_SOURCE_ID = 8 and
      PROK_GROUP_DEST_ID = 17


select ggv_com.gene_id,
        ggv_com.PROK_GROUP_SOURCE_ID,
        ggv_com.PROK_GROUP_DEST_ID,
        ggv_com.val as com_val,
        ggv_par.val as par_val,
        greatest(nvl(ggv_com.val,0),nvl(ggv_par.val,0)) as val
 from HGT_COM_GENE_GROUPS_VALS ggv_com
  full outer join HGT_PAR_GENE_GROUPS_VALS ggv_par on ggv_par.GENE_ID = ggv_com.GENE_ID and
                                           ggv_par.PROK_GROUP_SOURCE_ID = ggv_com.PROK_GROUP_SOURCE_ID and
                                           ggv_par.PROK_GROUP_DEST_ID = ggv_com.PROK_GROUP_DEST_ID
where ggv_par.PROK_GROUP_SOURCE_ID = 8 and
      ggv_par.PROK_GROUP_DEST_ID = 17


select un.gene_id,
       un.PROK_GROUP_SOURCE_ID,
       un.PROK_GROUP_DEST_ID,
       max(val)
from
(
select gene_id,
       PROK_GROUP_SOURCE_ID,
       PROK_GROUP_DEST_ID,
       VAL
from HGT_COM_GENE_GROUPS_VALS
 union
select gene_id,
       PROK_GROUP_SOURCE_ID,
       PROK_GROUP_DEST_ID,
       VAL
from HGT_PAR_GENE_GROUPS_VALS
) un
where un.PROK_GROUP_SOURCE_ID  = 8 and
      un.PROK_GROUP_DEST_ID = 17
group by un.gene_id,
         un.PROK_GROUP_SOURCE_ID,
         un.PROK_GROUP_DEST_ID
order by un.gene_id,
         un.PROK_GROUP_SOURCE_ID,
         un.PROK_GROUP_DEST_ID
         
       











                                 
                                           
 select ggv_par.gene_id,
        ggv_par.PROK_GROUP_SOURCE_ID,
        ggv_par.PROK_GROUP_DEST_ID,
        ggv_par.VAL
 from HGT_PAR_GENE_GROUPS_VALS ggv_par


 select sum(ggv_com.VAL)
 from HGT_COM_GENE_GROUPS_VALS ggv_com


 select sum(ggv_par.VAL)
 from HGT_PAR_GENE_GROUPS_VALS ggv_par



select un.gene_id,
       un.PROK_GROUP_SOURCE_ID,
       un.PROK_GROUP_DEST_ID,
       max(val) as val
from
(
select gene_id,
       PROK_GROUP_SOURCE_ID,
       PROK_GROUP_DEST_ID,
       VAL
from HGT_COM_GENE_GROUPS_VALS
 union
select gene_id,
       PROK_GROUP_SOURCE_ID,
       PROK_GROUP_DEST_ID,
       VAL
from HGT_PAR_GENE_GROUPS_VALS
) un
group by un.gene_id,
         un.PROK_GROUP_SOURCE_ID,
         un.PROK_GROUP_DEST_ID
order by un.gene_id,
         un.PROK_GROUP_SOURCE_ID,
         un.PROK_GROUP_DEST_ID
