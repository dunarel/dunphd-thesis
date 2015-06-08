
 checkpoint defrag
 
 backup database to '/root/devel/backup/db_srv/' blocking


 select gn.NAME,
        hcif.GENE_ID,
        hcif.ID,
        max(hcit.id),
        max(hctt_beast.AGE_HPD5_WG),
        max(hctt_beast.AGE_MD_WG) as beast_med,
        max(hctt_treepl.AGE_MD_WG) as treepl_med,
        max(hctt_beast.AGE_HPD95_WG)
 from genes gn
  join HGT_COM_INT_FRAGMS hcif on hcif.GENE_ID = gn.id
  join HGT_COM_INT_TRANSFERS hcit on hcit.HGT_COM_INT_FRAGM_ID = hcif.id
  join HGT_COM_TRSF_TIMINGS hctt_beast on hctt_beast.HGT_COM_INT_TRANSFER_ID = hcit.ID and
                                          hctt_beast.TIMING_CRITER_ID = 0
  join HGT_COM_TRSF_TIMINGS hctt_treepl on hctt_treepl.HGT_COM_INT_TRANSFER_ID = hcit.ID and
                                          hctt_treepl.TIMING_CRITER_ID = 1
where gn.name = 'map' and                                         
      hctt_beast.AGE_MD_WG < 10
group by gn.NAME,
        hcif.GENE_ID,
        hcif.ID
order by gene_id
        
select *
from HGT_COM_INT_FRAGMS hcif 
where hcif.id in (358882,358883)

 
 from HGT_COM_TRSF_TIMINGS hctt


select gn.name,
       gn.id,
       count(*)
from genes gn
 join GENE_BLO_SEQS gbs on gbs.GENE_ID = gn.id
group by gn.name,
       gn.id
order by count(*)


 select *
 from taxons
 