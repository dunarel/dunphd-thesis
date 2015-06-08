select id, sci_name, tree_name
from taxons
order by tree_name

select pg_src.CIN_NODE_NAME as SOURCE_NODE_ID,
       pg_dst.CIN_NODE_NAME as DESTINATION_NODE_ID,
       col.RGB_HEX as COLOR,
       tgh.VAL1 as label
from TREE_GROUPS_HGTS tgh
 join PROK_GROUPS pg_src on pg_src.ID = tgh.PROK_GROUP_SOURCE_ID
 join PROK_GROUPS pg_dst on pg_dst.id = tgh.PROK_GROUP_DEST_ID
 join COLORS col on col.ID = pg_src.COLOR_ID

 select pg.CIN_NODE_NAME,
                 col.RGB_HEX,
                 pg.name
          from PROK_GROUPS pg
           join colors col on col.id = pg.COLOR_ID          
          where pg.GROUP_CRITER_ID = 0
          order by pg.ORDER_ID