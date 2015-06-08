
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


select distinct hpf.WIN_STATUS
from hgt_par_fens hpf

select count(*) 
from hgt_par_fens hpf
where hpf.WIN_STATUS='phylo_result'
and hpf.WIN_SIZE = 10


select *

insert into HGT_PAR_FEN_STATS
 (hgt_par_fen_id,win_status,created_at,updated_at)
select id,'phylo_design',current_timestamp,updated_at
from hgt_par_fens hpf

select count(*)
from hgt_par_fens hpf
 join HGT_PAR_FEN_STATS hpfs on hpfs.HGT_PAR_FEN_ID = hpf.id
where hpfs.WIN_STATUS in ('phylo_design') 



and
      hpf.win_size = 10






