select count(*)
from hgt_par_fens hpf
 join HGT_PAR_FEN_STATS hpfs on hpfs.HGT_PAR_FEN_ID = hpf.ID
where hpfs.WIN_STATUS = 'phylo_result'
and hpf.WIN_SIZE = 10


select count(*)
from hgt_par_fens hpf
 join HGT_PAR_FEN_STATS hpfs on hpfs.HGT_PAR_FEN_ID = hpf.ID
where hpfs.WIN_STATUS = 'hgt_err_nocalc'
