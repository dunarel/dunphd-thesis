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
 where gn.name = 'secE'

 select gn.id,
        gn.name,
        count(gbs.id)
 from genes gn 
  join GENE_BLO_SEQS gbs on gbs.GENE_ID = gn.id
 group by gn.id,
          gn.name
 order by count(gbs.id) asc


 select *
 from HGT_COM_TRSF_TIMINGS hctim
 where hctim.TIMING_CRITER_ID = 1



select sum(hctt.AGE_MD_WG)/sum(hcit.WEIGHT) as md_wg_per_wg,
       sum(hctt.AGE_HPD5_WG)/sum(hcit.WEIGHT) as md_hpd5_per_wg,
       sum(hctt.AGE_HPD95_WG)/sum(hcit.WEIGHT) as md_hpd95_per_wg
             from HGT_COM_INT_TRANSFERS hcit
              join HGT_COM_TRSF_TIMINGS hctt on hctt.HGT_COM_INT_TRANSFER_ID = hcit.id
             where hctt.TIMING_CRITER_ID = 0
             group by hcit.HGT_COM_INT_FRAGM_ID
             order by sum(hctt.AGE_MD_WG)/sum(hcit.WEIGHT) desc
 

select hcif.gene_id,
       sum(hctt.AGE_MD_WG)/sum(hcit.WEIGHT) as md_wg_per_wg,
       sum(hctt.AGE_HPD5_WG)/sum(hcit.WEIGHT) as md_hpd5_per_wg,
       sum(hctt.AGE_HPD95_WG)/sum(hcit.WEIGHT) as md_hpd95_per_wg
from HGT_COM_INT_TRANSFERS hcit
 join HGT_COM_TRSF_TIMINGS hctt on hctt.HGT_COM_INT_TRANSFER_ID = hcit.id
 join  HGT_COM_INT_FRAGMS hcif on hcif.ID = hcit.HGT_COM_INT_FRAGM_ID
where hctt.TIMING_CRITER_ID = 0 and
      hcif.GENE_ID = 132
group by hcif.GENE_ID,
         hcit.HGT_COM_INT_FRAGM_ID
order by sum(hctt.AGE_MD_WG)/sum(hcit.WEIGHT) desc

select *
from HGT_COM_INT_FRAGMS hcif
where gene_id = 132


 select m.id,
                  m.abrev,
                  m.time_min,
                  m.time_max
           from mrcas m
           where mrca_criter_id = 0
           order by m.time_max asc
