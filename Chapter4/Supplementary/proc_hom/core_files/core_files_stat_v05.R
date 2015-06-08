
rm(list=ls(all=TRUE))

# Set JAVA_HOME, set max. memory, and load rJava library
Sys.setenv(JAVA_HOME='/usr/java/latest/bin')
options(java.parameters="-Xmx1g")
library(rJava)
.jinit()
print(.jcall("java/lang/System", "S", "getProperty", "java.version"))
library(RJDBC)
drv <- JDBC("org.hsqldb.jdbcDriver","/root/devel/proc_hom/lib/hsqldb.jar", identifier.quote="\"")
conn <- dbConnect(drv, "jdbc:hsqldb:hsql://localhost:9005/proc_hom", "SA", "")


setwd("/root/devel/proc_hom/core_files")
print(getwd())

#genes_taxons_seqs
if(dbExistsTable(conn,"GENES_TAXONS_SEQS")) {
  print("table GENES_TAXONS_SEQS exists -------------------")
  if(dbExistsTable(conn,"TXNS")) dbRemoveTable(conn,"TXNS")  
  if(dbExistsTable(conn,"GENES_TAXONS")) dbRemoveTable(conn,"GENES_TAXONS")  
  if(dbExistsTable(conn,"GENES_TAXONS_SEQS")) dbRemoveTable(conn,"GENES_TAXONS_SEQS")  
}

sql <- "create view genes_taxons_seqs as 
select gbs.GENE_ID,
       ns.TAXON_ID,
       gbs.NCBI_SEQ_ID       
from genes gn
--from genes_core_inter gn
 join GENE_BLO_SEQS gbs on gbs.GENE_ID = gn.ID 
 join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID"
dbSendUpdate(conn,sql)


sql <- "create view genes_taxons as 
select distinct gene_id,taxon_id
from GENES_TAXONS_SEQS"
dbSendUpdate(conn,sql)


sql <- "create view txns as 
select distinct taxon_id
from GENES_TAXONS_seqs"
dbSendUpdate(conn,sql)

#pgtn
sql <- "select prok_group_id,
       sum(weight_pg) as tn
from TXNS tx
join taxon_groups tg on tg.TAXON_ID = tx.taxon_id
group by prok_group_id
order by PROK_GROUP_ID
"
pgtn_df <- dbGetQuery(conn, sql)
if(dbExistsTable(conn,"PGTN")) {
  print("table PGTN exists -------------------") 
  dbRemoveTable(conn,"PGTN")  
}
dbWriteTable(conn, "PGTN", pgtn_df, overwrite=TRUE)

#pgsn
sql <- "select prok_group_id,
       sum(weight_pg) as sn
from GENES_TAXONS_SEQS gts
 join taxon_groups tg on tg.TAXON_ID = gts.TAXON_ID
group by prok_group_id
order by PROK_GROUP_ID"
pgsn_df <- dbGetQuery(conn, sql)
if(dbExistsTable(conn,"PGSN")) {
  print("table PGSN exists -------------------") 
  dbRemoveTable(conn,"PGSN")  
}
dbWriteTable(conn, "PGSN", pgsn_df, overwrite=TRUE)


#magic
sql <- "
select pg.order_id,
pg_tx_src.prok_group_id,
pg_tx_src.pg_weight,
pgsn.pgsn_cnt,
pgtn.PGTN_CNT,
pg_tx_src.pg_weight /pgsn.pgsn_cnt / 110 as pgsn_magic,
pg_tx_src.pg_weight /pgtn.pgtn_cnt / 110 as pgtn_magic
from 
(
select tg.PROK_GROUP_ID,
  nvl(sum(hctt_src.WEIGHT_TR_TX),0) as pg_weight
  from HGT_COM_TRSF_TAXONS hctt_src
  right outer join TAXON_GROUPS tg on tg.TAXON_ID = hctt_src.TXSRC_ID
  where tg.PROK_GROUP_ID between 0 and 22
  group by tg.PROK_GROUP_ID
  order by tg.PROK_GROUP_ID
) pg_tx_src
join pgsn on pgsn.prok_group_id = pg_tx_src.prok_group_id
join pgtn on pgtn.PROK_GROUP_ID = pg_tx_src.prok_group_id
join PROK_GROUPS pg on pg.id = pg_tx_src.prok_group_id
order by pg.order_id 
"

magic_df <- dbGetQuery(conn, sql)

pgtn_magic_tot <- weighted.mean(magic_df$PGTN_MAGIC,magic_df$PGTN_CNT)
pgsn_magic_tot <- weighted.mean(magic_df$PGSN_MAGIC,magic_df$PGSN_CNT)


#magic_core
sql <- "
select pg.order_id,
       pg_tx_src.prok_group_id,
       pg_tx_src.pg_weight,
       pgsn_core.pgsn_cnt,
       pgtn_core.PGTN_CNT,
       pg_tx_src.pg_weight /pgsn_core.pgsn_cnt / 110 as pgsn_magic,
       pg_tx_src.pg_weight /pgtn_core.pgtn_cnt / 110 as pgtn_magic
from 
(
select tg.PROK_GROUP_ID,
  nvl(sum(hctt_src.WEIGHT_TR_TX),0) as pg_weight
  from HGT_COM_TRSF_TAXONS hctt_src
  join GENES_CORE_INTER gci on gci.ID = hctt_src.GENE_ID
  right outer join TAXON_GROUPS tg on tg.TAXON_ID = hctt_src.TXSRC_ID
  where tg.PROK_GROUP_ID between 0 and 22
  group by tg.PROK_GROUP_ID
  order by tg.PROK_GROUP_ID
) pg_tx_src
join pgsn_core on pgsn_core.prok_group_id = pg_tx_src.prok_group_id
join pgtn_core on pgtn_core.PROK_GROUP_ID = pg_tx_src.prok_group_id
join PROK_GROUPS pg on pg.id = pg_tx_src.prok_group_id
order by pg.order_id 
"

magic_core_df <- dbGetQuery(conn, sql)

pgtn_magic_core_tot <- weighted.mean(magic_core_df$PGTN_MAGIC,magic_core_df$PGTN_CNT)
pgsn_magic_core_tot <- weighted.mean(magic_core_df$PGSN_MAGIC,magic_core_df$PGSN_CNT)



