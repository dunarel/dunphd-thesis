
update hgt_par_fens hpf
set hpf.win_sel='ws50'
where hpf.win_size=50



update hgt_par_fens hpf
set hpf.win_sel='echant'


select count(*)
from hgt_par_fens hpf
--where hpf.win_status = 'phylo_err_nocalc'
--where hpf.win_status = 'phylo_err_lowbs'
--where hpf.win_status = 'phylo_result'

select count(*)
from hgt_par_fens hpf
where hpf.win_sel = 'ws50'


where hpf.win_sel is not null


update hgt_par_fens hpf
set hpf.WIN_SEL = 'phylo_result'
where hpf.WIN_STATUS = 'phylo_result'

update hgt_par_fens hpf
set hpf.WIN_SEL = 'phylo_result'
where hpf.WIN_STATUS = 'phylo_result'


update hgt_par_fens hpf
set hpf.WIN_SEL = hpf.WIN_STATUS

update hgt_par_fens hpf
set hpf.WIN_STATUS = 'phylo_design'


select count(*)
from hgt_par_fens hpf





where hpf.WIN_STATUS = 'phylo_design'


where hpf.WIN_STATUS = 'phylo_result'




set hpf.win_status='phylo_design'

delete from HGT_PAR_FEN_STATS hpfs




select distinct hpfs.WIN_STATUS
from HGT_PAR_FEN_STATS hpfs 

select count(*) 
from hgt_par_fens hpf
where hpf.WIN_STATUS='phylo_result'
and hpf.WIN_SIZE = 10


select *

--initialize hgt_par_fen_stats
insert into HGT_PAR_FEN_STATS
 (hgt_par_fen_id,win_status,created_at,updated_at)
select id,'alix_design',current_timestamp,updated_at
from hgt_par_fens hpf

select count(*)
from hgt_par_fens hpf
 join HGT_PAR_FEN_STATS hpfs on hpfs.HGT_PAR_FEN_ID = hpf.id
where hpfs.WIN_STATUS in ('phylo_result') 


--
update HGT_PAR_FEN_STATS hpfs
set hpfs.WIN_STATUS = 'alix_design'
where hpfs.WIN_STATUS = 'phylo_err_lowbs'





and
      hpf.win_size = 10

--update selector(for jobs) based on status 
update HGT_PAR_FENS hpf
set hpf.WIN_SEL = 'hgt_err_nocalc'
where id in (select hpfs.HGT_PAR_FEN_ID
             from HGT_PAR_FEN_STATS hpfs
             where hpfs.WIN_STATUS = 'hgt_err_nocalc')
             


select sum(hctt.AGE_MD_WG)/sum(hcit.WEIGHT) as md_wg_per_wg,
                    sum(hctt.AGE_HPD5_WG)/sum(hcit.WEIGHT) as md_hpd5_per_wg,
                    sum(hctt.AGE_HPD95_WG)/sum(hcit.WEIGHT) as md_hpd95_per_wg,
                    sum(hctt.AGE_ORIG_WG)/sum(hcit.WEIGHT) as md_orig_per_wg
             from HGT_COM_INT_TRANSFERS hcit
              join HGT_COM_TRSF_TIMINGS hctt on hctt.HGT_COM_INT_TRANSFER_ID = hcit.id
             where hctt.TIMING_CRITER_ID = 1
             group by hcit.HGT_COM_INT_FRAGM_ID
             order by sum(hctt.AGE_MD_WG)/sum(hcit.WEIGHT) desc


select * 
from hgt_par_fens hpf
where hpf.WIN_SEL = 'alix_design'

select distinct hpfs.WIN_STATUS
from HGT_PAR_FEN_STATS hpfs

select *
from HGT_PAR_FEN_STATS hpfs
where hpfs.WIN_STATUS = 'hgt_err_nocalc'


select hpf.GENE_ID,
       gn.NAME,
       hpf.WIN_SIZE,
       hpf.FEN_NO,
       hpf.FEN_IDX_MIN,
       hpf.FEN_IDX_MAX
from hgt_par_fens hpf
 join genes gn on gn.id = hpf.gene_id
where hpf.win_sel = 'hgt_err_nocalc'


update HGT_PAR_FENS hpf
set hpf.WIN_SEL = null



where hpfs.WIN_STATUS = 'hgt_err_nocalc'

delete from HGT_PAR_FEN_STATS hpfs
where  hpfs.WIN_STATUS = 'hgt_result' 


and
       hpfs.id in (select id
                  from HGT_PAR_FEN_STATS hpfs
                  where hpfs.WIN_STATUS = 'hgt_result')

select ms.STDEV
from MRCA_STDEVS ms
where ms.MRCA_ID in (0)


select distinct hpf.WIN_SIZE,
       hpf.FEN_NO,
       hpf.FEN_IDX_MIN,
       hpf.FEN_IDX_MAX
from hgt_par_fragms hpf
 join GENES gn on gn.ID = hpf.GENE_ID
where gn.name = 'fabG'

select *
from fen_stages fs
where fs.TIMING_PROG = ''

alter table hgt_par_fen_stats add column  fen_stage_id integer

alter table hgt_par_fen_stats drop column  fen_stage_id



select *
from hgt_par_fen_stats hpfs
where hpfs.win_status = 'alix_design'

select count(*)
from hgt_par_fen_stats hpfs
where hpfs.win_status = 'alix_design'

select hpfs.HGT_PAR_FEN_ID
from hgt_par_fen_stats hpfs
where hpfs.win_status in ('hgt_result')

insert into hgt_par_fen_stats hpfs
(HGT_PAR_FEN_ID,win_status,fen_stage_id,created_at,updated_at)
select hpfs2.HGT_PAR_FEN_ID,'err_nocalc',0,current_timestamp,current_timestamp
from hgt_par_fen_stats hpfs2
where hpfs2.win_status = 'phylo_err_nocalc'

update hgt_par_fen_stats hpfs
set hpfs.FEN_STAGE_ID = 1 
where hpfs.FEN_STAGE_ID = 0

insert into HGT_PAR_FEN_STATS hpfs
(hgt_par_fen_id,fen_stage_id,created_at,updated_at)
select hpf.id,0,current_timestamp,current_timestamp
from HGT_PAR_FENS hpf


update HGT_PAR_FEN_STATS hpfs
set hpfs.win_status = 'result'
where hpfs.FEN_STAGE_ID = 0

select *
from HGT_PAR_FEN_STATS hpfs
 join HGT_PAR_FENS hpf on hpf.id = hpfs.HGT_PAR_FEN_ID
 join genes gn on gn.ID = hpf.GENE_ID
where hpfs.FEN_STAGE_ID = 2 and
      hpfs.WIN_STATUS = 'result'



and
      hpfs.WIN_STATUS = 'result'



select *
from hgt_par_fen_stats hpfs
where hpfs.WIN_STATUS = 'result'


where hpfs.win_status = 'alix_design'



select distinct win_status
from HGT_PAR_FEN_STATS




