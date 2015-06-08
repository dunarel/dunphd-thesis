
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

select bt_par.src_order,
       bt_par.dst_order,
       bt_par.cnt_rel+0 as com_rel,
       com_tg.cnt_rel+0 as par_rel,
       bt_par.src_name,
       bt_par.dst_name
from (select tg.PROK_GROUP_source_id src_id,
             tg.PROK_GROUP_dest_id dst_id,
             pg_src.ORDER_ID+1 as src_order,
             pg_dst.ORDER_ID+1 as dst_order,
             tg.CNT_REL,
             pg_src.NAME as src_name,
             pg_dst.name as dst_name
from HGT_PAR_TRANSFER_GROUPS tg
 join PROK_GROUPS pg_src on pg_src.ID = tg.PROK_GROUP_SOURCE_ID                           
 join PROK_GROUPS pg_dst on pg_dst.ID = tg.PROK_GROUP_DEST_ID                           
where tg.PROK_GROUP_SOURCE_ID between 0 and 22 and
      tg.PROK_GROUP_DEST_ID between 0 and 22
order by tg.CNT_REL desc                         
) bt_par 
 join hgt_com_int_transfer_groups com_tg on com_tg.prok_group_source_id = bt_par.src_id and
                                            com_tg.prok_group_dest_id = bt_par.dst_id
limit 20                                            