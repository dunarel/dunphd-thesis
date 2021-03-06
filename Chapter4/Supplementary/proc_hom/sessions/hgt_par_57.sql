select  hpf.GENE_ID,
                 gn.NAME as gene_name,
                 hpf.WIN_SIZE,
                 hpf.FEN_NO,
                 hpf.FEN_IDX_MIN,
                 hpf.FEN_IDX_MAX,
                 count(distinct hpf.HGT_PAR_CONTIN_ID) as nb_trsf
         from HGT_PAR_FRAGMS hpf
          join genes gn on gn.id = hpf.gene_id
         where hpf.win_size = 25 and
               hpf.gene_id = 111
         group by hpf.GENE_ID,
                  gn.NAME,
                  hpf.WIN_SIZE,
                  hpf.FEN_NO,
                  hpf.FEN_IDX_MIN,
                  hpf.FEN_IDX_MAX
         order by count(distinct hpf.HGT_PAR_CONTIN_ID) desc


 select gn.id,
        gn.name,
        gbs.BLOCKS_LENGTH as align_len
 from genes gn
  join GENE_BLO_RUNS gbs on gbs.GENE_ID = gn.id
 where gn.name = 'gltX'

 select gn.id,
        gn.name,
        count(gbs.id)
 from genes gn 
  join GENE_BLO_SEQS gbs on gbs.GENE_ID = gn.id
 group by gn.id,
          gn.name
 order by count(gbs.id) asc
 
         