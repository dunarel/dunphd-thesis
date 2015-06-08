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


where hcif.BS_VAL >= 100

--COM genes 
select distinct gene_id 
from HGT_COM_INT_FRAGMS hcif
where hcif.BS_VAL >= 100


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
                                                where hpf.BS_VAL >= 75
                                                group by hpc.ID)
 group by hpf2.HGT_PAR_CONTIN_ID
)
)              


select hpc.id,
       max(hpf.BS_VAL) as max_bs
from HGT_PAR_CONTINS hpc 
 join HGT_PAR_FRAGMS hpf on hpf.HGT_PAR_CONTIN_ID = hpc.ID
where hpf.BS_VAL >=80
group by hpc.ID
                                                

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


delete from HGT_PAR_CONTINS hpc
where hpc.BS_VAL < 100

delete from HGT_PAR_FRAGMS hpf
where hpf.BS_VAL < 100

select count(*)
from hgt_par_contins hpc

where hpc.BS_VAL >= 100

select count(*)
from HGT_PAR_FRAGMS hpf


where hpf.BS_VAL >= 100


--select hgt-com windows (genes)
--COM genes 
select distinct hcif.GENE_ID,
                gn.name,
                gbr.BLOCKS_LENGTH  as align_len
from HGT_COM_INT_FRAGMS hcif
  join GENES gn on hcif.GENE_ID = gn.ID
  join GENE_BLO_RUNS gbr on gbr.GENE_ID = hcif.GENE_ID

select *
from HGT_COM_INT_FRAGMS hcif
 
 join GENES gn on hcif.GENE_ID = gn.id
 j


         from 

--select hgt-par windows
select  hpf.GENE_ID,
                 gn.NAME as gene_name,
                 hpf.WIN_SIZE,
                 hpf.FEN_NO,
                 hpf.FEN_IDX_MIN,
                 hpf.FEN_IDX_MAX,
                 ((hpf.FEN_IDX_MAX - hpf.FEN_IDX_MIN) + 1) as align_len,
                 count(distinct hpf.HGT_PAR_CONTIN_ID) as nb_trsf
         from HGT_PAR_FRAGMS hpf
          join genes gn on gn.id = hpf.gene_id
         --where hpf.win_size = 50 
         group by hpf.GENE_ID,
                  gn.NAME,
                  hpf.WIN_SIZE,
                  hpf.FEN_NO,
                  hpf.FEN_IDX_MIN,
                  hpf.FEN_IDX_MAX
         order by count(distinct hpf.HGT_PAR_CONTIN_ID) desc


--

select hpt.HGT_PAR_CONTIN_ID,
       hpt.HGT_PAR_FRAGM_ID,
       count(*)
from HGT_PAR_TRANSFERS hpt
group by hpt.HGT_PAR_CONTIN_ID,
         hpt.HGT_PAR_FRAGM_ID





select hpf.id,
       hpf.gene_id,
       hpf.HGT_PAR_CONTIN_ID,
       hpf.BS_VAL
from HGT_PAR_FRAGMS hpf
order by hpf.HGT_PAR_CONTIN_ID

delete from HGT_PAR_CONTINS

select *
from HGT_PAR_CONTINS

select hpc.GENE_ID,
       hpc.BS_VAL,
       hpf.BS_VAL
from HGT_PAR_CONTINS hpc
 join HGT_PAR_FRAGMS hpf on hpf.HGT_PAR_CONTIN_ID = hpc.ID

select hpf.id,
       hpf.GENE_ID,
       hpf.FROM_SUBTREE,
       hpf.TO_SUBTREE,
       hpf.WIN_SIZE,
       hpf.FEN_NO,
       hpf.FEN_IDX_MIN,
       hpf.FEN_IDX_MAX
from HGT_PAR_FRAGMS hpf

truncate table hgt_par_trsf_timings


select t.cnt,
       t.cnt*2
from 
(
select count(*) as cnt
from HGT_PAR_TRANSFERS hpt
union
select count(*) as cnt
from HGT_PAR_TRSF_TIMINGS hptt
) as t


select *
from HGT_PAR_TRSF_TIMINGS hptt
where hptt.AGE_MD_WG = -1 or
      hptt.AGE_HPD5_WG = -1 or
      hptt.AGE_HPD95_WG = -1


select sum(hptt.AGE_MD_WG)/sum(hpt.WEIGHT) as md_wg_per_wg,
       sum(hptt.AGE_HPD5_WG)/sum(hpt.WEIGHT) as md_hpd5_per_wg,
       sum(hptt.AGE_HPD95_WG)/sum(hpt.WEIGHT) as md_hpd95_per_wg,
       sum(hptt.AGE_ORIG_WG)/sum(hpt.WEIGHT) as md_orig_per_wg
from HGT_PAR_TRANSFERS hpt
 join HGT_PAR_TRSF_TIMINGS hptt on hptt.HGT_PAR_TRANSFER_ID = hpt.id
where hptt.TIMING_CRITER_ID = 0
group by hpt.HGT_PAR_FRAGM_ID
order by sum(hptt.AGE_MD_WG)/sum(hpt.WEIGHT) desc


delete from HGT_PAR_TRANSFERS ht
where ht.id in (
 select hpt.id
 from  HGT_PAR_TRANSFERS hpt
  join HGT_PAR_TRSF_TIMINGS hptt on hptt.HGT_PAR_TRANSFER_ID = hpt.id
 where hptt.AGE_MD_WG < 0 or
       hptt.AGE_HPD5_WG < 0 or
       hptt.AGE_HPD95_WG < 0 or
       hptt.AGE_ORIG_WG < 0 or 
       hptt.AGE_MD_WG != hptt.AGE_ORIG_WG
 )

select *
from HGT_PAR_TRANSFERS hpt
 join HGT_PAR_TRSF_TIMINGS hptt on hptt.HGT_PAR_TRANSFER_ID = hpt.id
where hptt.TIMING_CRITER_ID = 0
order by hptt.AGE_MD_WG



select *
from HGT_PAR_FRAGMS hpf
 join HGT_PAR_TRANSFERS hpt on hpt.HGT_PAR_FRAGM_ID = hpf.id
 join HGT_PAR_TRSF_TIMINGS hptt on hptt.HGT_PAR_TRANSFER_ID = hpt.id
where hptt.AGE_MD_WG = -1 or 
      hptt.AGE_HPD5_WG = -1 or
      hptt.AGE_HPD95_WG = -1 or
      hptt.AGE_ORIG_WG = -1


delete from HGT_PAR_TRANSFERS ht
       where ht.id in (
select hpt.id
from  HGT_PAR_TRANSFERS hpt
 join HGT_PAR_TRSF_TIMINGS hptt on hptt.HGT_PAR_TRANSFER_ID = hpt.id
where hptt.AGE_MD_WG < 0 or 
      hptt.AGE_HPD5_WG < 0 or
      hptt.AGE_HPD95_WG < 0 or
      hptt.AGE_ORIG_WG < 0
)

select hptt.*
from HGT_PAR_TRSF_TIMINGS hptt
where hptt.TIMING_CRITER_ID = 0



