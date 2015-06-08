
 checkpoint defrag
 
 backup database to '/root/devel/backup/db_srv/' blocking script

 select hpf.fen_no,
        hpf.fen_idx_min,
        hpf.fen_idx_max
 from hgt_par_fens hpf
 where hpf.win_status = 'designed' and
       hpf.gene_id = 110 and
       hpf.win_size = 10
 order by hpf.fen_no


 