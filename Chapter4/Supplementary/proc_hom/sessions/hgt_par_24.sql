
 checkpoint defrag
 
 backup database to '/root/devel/backup/db_srv/' script blocking


 select tree_name
 from taxons

 select tx.tree_order,
 	   tx.TREE_NAME,
        pg.ORDER_ID+1 as group_order,
        pg.ID+0 as group_id,
        pg.NAME||'' as group_name
 from taxons tx 
  join TAXON_GROUPS tg on tg.TAXON_ID = tx.id
  join PROK_GROUPS pg on pg.ID = tg.PROK_GROUP_ID
 where pg.ID between 0 and 32
 order by tx.TREE_ORDER

 select *
 from HGT_PAR_TRANSFERS
 where NCBI_SEQ_DEST_ID = 19


 select tg_src.PROK_GROUP_ID,
        tg_dest.PROK_GROUP_ID,
                            sum(ht.weight)
           from hgt_par_transfers ht
                    left join NCBI_SEQS ns_src on ns_src.id = ht.NCBI_SEQ_SOURCE_ID
                    left join TAXON_GROUPS tg_src on tg_src.TAXON_ID = ns_src.TAXON_ID
                    left join NCBI_SEQS ns_dest on ns_dest.id = ht.NCBI_SEQ_DEST_ID
                    left join TAXON_GROUPS tg_dest on tg_dest.TAXON_ID = ns_dest.TAXON_ID
                             group by tg_src.PROK_GROUP_ID,
                            tg_dest.PROK_GROUP_ID

select *
from genes                            
                            