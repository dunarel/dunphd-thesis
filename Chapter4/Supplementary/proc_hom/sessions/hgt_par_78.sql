
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

set hpf.win_status='phylo_design'


select distinct hpf.WIN_STATUS
from hgt_par_fens hpf

select count(*) 
from hgt_par_fens hpf
where hpf.WIN_STATUS='phylo_result'
and hpf.WIN_SIZE = 10


select *


