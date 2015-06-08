
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
where hpf.win_status = 'ws50'


where hpf.win_sel is not null