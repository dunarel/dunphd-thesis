
 checkpoint defrag
 
 backup database to '/root/devel/backup/db_srv/' script blocking

 drop table colors


 select *
 from taxons
 where tree_name like 'Thermosipho%'


 select tx.id,
        tx.tree_name,
        tg.PROK_GROUP_ID,
        pg.CIN_NODE_NAME,
        col.RGB_HEX
 from TAXONS tx
  join TAXON_GROUPS tg on tg.TAXON_ID = tx.id
  join PROK_GROUPS pg on pg.ID = tg.PROK_GROUP_ID
  join colors col on col.ID = pg.COLOR_ID
 where pg.GROUP_CRITER_ID = 0
 order by pg.ORDER_ID,
          tx.id

 select tx.tree_name,
        col.RGB_HEX
 from TAXONS tx
  join TAXON_GROUPS tg on tg.TAXON_ID = tx.id
  join PROK_GROUPS pg on pg.ID = tg.PROK_GROUP_ID
  join colors col on col.ID = pg.COLOR_ID
 where pg.GROUP_CRITER_ID = 0
 order by pg.ORDER_ID,
          tx.id
 