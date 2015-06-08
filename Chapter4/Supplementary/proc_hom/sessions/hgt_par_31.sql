
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



          select *
                   from hgt_com_int_transfers ht
                    left join HGT_COM_INT_FRAGMS hf on hf.ID = ht.HGT_COM_INT_FRAGM_ID
                    left join NCBI_SEQS ns_src on ns_src.id = ht.SOURCE_ID
                    left join TAXON_GROUPS tg_src on tg_src.TAXON_ID = ns_src.TAXON_ID  
                    left join NCBI_SEQS ns_dest on ns_dest.id = ht.DEST_ID
                    left join TAXON_GROUPS tg_dest on tg_dest.TAXON_ID = ns_dest.TAXON_ID
                   where tg_src.PROK_GROUP_ID = 87 and
                         tg_dest.PROK_GROUP_ID = 87

select *
 from GENE_GROUP_CNTS      


      select  hcf.GENE_ID,
              tg_src.PROK_GROUP_ID,
              tg_dest.PROK_GROUP_ID,
              sum(ht.weight) as weight
      from HGT_COM_INT_TRANSFERS ht
        join HGT_COM_INT_FRAGMS hcf on hcf.ID = ht.HGT_COM_INT_FRAGM_ID
        join NCBI_SEQS ns_src on ns_src.id = ht.SOURCE_ID
        join TAXON_GROUPS tg_src on tg_src.TAXON_ID = ns_src.TAXON_ID
        join NCBI_SEQS ns_dest on ns_dest.id = ht.DEST_ID
        join TAXON_GROUPS tg_dest on tg_dest.TAXON_ID = ns_dest.TAXON_ID
      group by tg_src.PROK_GROUP_ID,
               tg_dest.PROK_GROUP_ID,
               hcf.GENE_ID
      order by tg_src.PROK_GROUP_ID,
               tg_dest.PROK_GROUP_ID,
               hcf.GENE_ID

select gene_id,count(*)
      from HGT_COM_INT_TRANSFERS ht
        join HGT_COM_INT_FRAGMS hcf on hcf.ID = ht.HGT_COM_INT_FRAGM_ID   
   group by gene_id
   order by count(*)

select *
      from HGT_COM_INT_TRANSFERS ht
        join HGT_COM_INT_FRAGMS hcf on hcf.ID = ht.HGT_COM_INT_FRAGM_ID  
         join NCBI_SEQS ns_src on ns_src.id = ht.SOURCE_ID
        join TAXON_GROUPS tg_src on tg_src.TAXON_ID = ns_src.TAXON_ID
        join NCBI_SEQS ns_dest on ns_dest.id = ht.DEST_ID
        join TAXON_GROUPS tg_dest on tg_dest.TAXON_ID = ns_dest.TAXON_ID
where gene_id = 174 and
      tg_src.PROK_GROUP_ID between 86 and 93 and
      tg_dest.PROK_GROUP_ID between 86 and 93
order by source_id,dest_id      

--all transfers for one gene
select *
      from HGT_COM_INT_TRANSFERS ht
        join HGT_COM_INT_FRAGMS hcf on hcf.ID = ht.HGT_COM_INT_FRAGM_ID  
         join NCBI_SEQS ns_src on ns_src.id = ht.SOURCE_ID
        join NCBI_SEQS ns_dest on ns_dest.id = ht.DEST_ID
where gene_id = 174 
order by source_id,dest_id  

select ns_src.TAXON_ID || '' as src_taxon_id,
       ns_dest.taxon_id || '' as dest_taxon_id,
       ht.WEIGHT
      from HGT_COM_INT_TRANSFERS ht
        join HGT_COM_INT_FRAGMS hcf on hcf.ID = ht.HGT_COM_INT_FRAGM_ID  
         join NCBI_SEQS ns_src on ns_src.id = ht.SOURCE_ID
        join NCBI_SEQS ns_dest on ns_dest.id = ht.DEST_ID
where gene_id = 174 


select prok_group_id
from taxon_groups tg
where PROK_GROUP_ID between 86 and 93 and
      taxon_id  = 481448
order by taxon_id



--grops for taxons
select *
from taxon_groups tg
where PROK_GROUP_ID between 86 and 93 and
      taxon_id in (481448, 243090)
order by taxon_id

--all sequences of one gene and one prok_group
select *
      from GENE_BLO_SEQS gbs
       join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
       join TAXON_GROUPS tg on tg.TAXON_ID = ns.TAXON_ID
       join PROK_GROUPS pg on pg.ID = tg.PROK_GROUP_ID
  where gbs.GENE_ID = 174  and
        pg.ID = 92
      order by gbs.GENE_ID,
               gbs.NCBI_SEQ_ID
               
--all sequences of one gene and one prok_group
select gbs.NCBI_SEQ_ID
      from GENE_BLO_SEQS gbs
       join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
       join TAXON_GROUPS tg on tg.TAXON_ID = ns.TAXON_ID
       join PROK_GROUPS pg on pg.ID = tg.PROK_GROUP_ID
  where gbs.GENE_ID = 174  and
        pg.ID = 92
    intersect
select gbs.NCBI_SEQ_ID
      from GENE_BLO_SEQS gbs
       join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
       join TAXON_GROUPS tg on tg.TAXON_ID = ns.TAXON_ID
       join PROK_GROUPS pg on pg.ID = tg.PROK_GROUP_ID
  where gbs.GENE_ID = 174  and
        pg.ID = 93

 select *
 from HGT_PAR_TRANSFERS


--find the weight of 100% transfers
select *
             from HGT_COM_INT_TRANSFERS ht
              join HGT_COM_INT_FRAGMS hcf on hcf.ID = ht.HGT_COM_INT_FRAGM_ID
              join NCBI_SEQS ns_src on ns_src.id = ht.SOURCE_ID
              join TAXON_GROUPS tg_src on tg_src.TAXON_ID = ns_src.TAXON_ID
              join NCBI_SEQS ns_dest on ns_dest.id = ht.DEST_ID
              join TAXON_GROUPS tg_dest on tg_dest.TAXON_ID = ns_dest.TAXON_ID
             where hcf.GENE_ID = 111 and
                   tg_src.PROK_GROUP_ID = 18
                   
  
  --equivalent for partials
  select count(distinct ht.NCBI_SEQ_SOURCE_ID) as nb
               from hgt_par_transfers ht
               join HGT_PAR_FRAGMS hpf on hpf.ID = ht.HGT_PAR_FRAGM_ID
              join HGT_COM_INT_FRAGMS hcf on hcf.ID = ht.HGT_PAR_FRAGM_ID
              join NCBI_SEQS ns_src on ns_src.id = ht.NCBI_SEQ_SOURCE_ID
              join TAXON_GROUPS tg_src on tg_src.TAXON_ID = ns_src.TAXON_ID
              join NCBI_SEQS ns_dest on ns_dest.id = ht.NCBI_SEQ_DEST_ID
              join TAXON_GROUPS tg_dest on tg_dest.TAXON_ID = ns_dest.TAXON_ID
             where hpf.GENE_ID = 111 and
                   tg_src.PROK_GROUP_ID = 18

    select *
    from hgt_par_transfers ht
     join HGT_PAR_FRAGMS hpf on hpf.ID = ht.HGT_PAR_FRAGM_ID
     join ncbi_seqs ns_src on ns_src.ID = ht.NCBI_SEQ_SOURCE_ID 
     join TAXON_GROUPS tg_src on tg_src.TAXON_ID = ns_src.TAXON_ID
     join NCBI_SEQS ns_dest on ns_dest.id = ht.NCBI_SEQ_DEST_ID              
     join TAXON_GROUPS tg_dest on tg_dest.TAXON_ID = ns_dest.TAXON_ID      
    where hpf.GENE_ID = 111 and
          tg_src.PROK_GROUP_ID = 1
              
    select count(ht.NCBI_SEQ_SOURCE_ID)
    from hgt_par_transfers ht
     join HGT_PAR_FRAGMS hpf on hpf.ID = ht.HGT_PAR_FRAGM_ID
     join ncbi_seqs ns_src on ns_src.ID = ht.NCBI_SEQ_SOURCE_ID 
     join TAXON_GROUPS tg_src on tg_src.TAXON_ID = ns_src.TAXON_ID
     join NCBI_SEQS ns_dest on ns_dest.id = ht.NCBI_SEQ_DEST_ID              
     join TAXON_GROUPS tg_dest on tg_dest.TAXON_ID = ns_dest.TAXON_ID      
    where tg_src.PROK_GROUP_ID = 18

select *
from HGT_PAR_TRANSFER_GROUPS
where PROK_GROUP_SOURCE_ID = 17 and
      PROK_GROUP_DEST_ID = 15

select *
from GENE_GROUP_CNTS
where PROK_GROUP_ID = 15

select tg.PROK_GROUP_source_id src_id,
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



select              tg.PROK_GROUP_ID,
             pg.NAME,
             count(*) as CNT
      from GENE_BLO_SEQS gbs
       join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
       join TAXON_GROUPS tg on tg.TAXON_ID = ns.TAXON_ID
       join PROK_GROUPS pg on pg.ID = tg.PROK_GROUP_ID
      group by tg.PROK_GROUP_ID,
               pg.NAME
      order by tg.PROK_GROUP_ID      


select *
from HGT_COM_INT_TRANSFER_GROUPS
where PROK_GROUP_SOURCE_ID = 18 and
      PROK_GROUP_DEST_ID = 8
--where nb_genes_rel =1     

select *
from HGT_PAR_TRANSFER_GROUPS
where nb_genes_rel < 10

select tg.PROK_GROUP_source_id src_id,
             tg.PROK_GROUP_dest_id dst_id,
             pg_src.ORDER_ID+1 as src_order,
             pg_dst.ORDER_ID+1 as dst_order,
             tg.CNT_REL,
             tg.NB_GENES_REL,
             pg_src.NAME as src_name,
             pg_dst.name as dst_name
from HGT_PAR_TRANSFER_GROUPS tg
 join PROK_GROUPS pg_src on pg_src.ID = tg.PROK_GROUP_SOURCE_ID                           
 join PROK_GROUPS pg_dst on pg_dst.ID = tg.PROK_GROUP_DEST_ID                           
where tg.PROK_GROUP_SOURCE_ID between 0 and 22 and
      tg.PROK_GROUP_DEST_ID between 0 and 22
order by tg.CNT_REL desc

