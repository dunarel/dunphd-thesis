
 checkpoint defrag
 
 backup database to '/root/devel/backup/db_srv/' script blocking
 


  insert into hgt_par_transfer_groups
                                              (source_id,dest_id)
                                              select pg1.ID,pg2.id
                                              from PROK_GROUPS pg1
                                                cross join PROK_GROUPS pg2
                                              order by pg1.id,
                                                       pg2.id


update hgt_par_transfer_groups htg
                                               set htg.cnt =  select sum(ht.weight)
                                               from hgt_par_transfers ht
                                                left join NCBI_SEQS ns_src on ns_src.id = ht.SOURCE_ID
                                                left join TAXON_GROUPS tg_src on tg_src.ID = ns_src.TAXON_ID
                                                left join NCBI_SEQS ns_dest on ns_dest.id = ht.DEST_ID
                                                left join TAXON_GROUPS tg_dest on tg_dest.ID = ns_dest.TAXON_ID
                                               where tg_src.PROK_GROUP_ID = htg.source_id and
                                                     tg_dest.PROK_GROUP_ID = htg.dest_id 
                                               group by tg_src.PROK_GROUP_ID,
                                                        tg_dest.PROK_GROUP_ID

select sum(WEIGHT)
from HGT_PAR_TRANSFERS

select sum(cnt)
from HGT_PAR_TRANSFER_GROUPS

select count(*)
from hgt_par_contins
where BS_VAL >= 50

select count(distinct(gene_id))
from GENE_BLO_SEQS

select hpt.SOURCE_ID
from HGT_PAR_TRANSFERS hpt                                                        
where hpt.SOURCE_ID not in (select gbs.NCBI_SEQ_ID 
                            from GENE_BLO_SEQS gbs)


select *
from GENE_BLO_SEQS gbs
where gbs.NCBI_SEQ_ID not in (select hpt.dest_ID
                              from HGT_PAR_TRANSFERS hpt)
