
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

#genes_taxons
if(dbExistsTable(conn,"GENES_TAXONS")) {
  print("table GENES_TAXONS exists -------------------") 
  dbRemoveTable(conn,"GENES_TAXONS")  
}

sql <- "create view genes_taxons as 
select distinct gn.ID as gene_id,
                ns.TAXON_ID
from GENES gn
 join GENE_BLO_SEQS gbs on gbs.GENE_ID = gn.id
 join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID"
dbSendUpdate(conn,sql)


#pgtn
sql <- "select tg.PROK_GROUP_ID,
       count(sel_tx.taxon_id) as pgtn_cnt
from 
(
select distinct TAXON_ID
from GENES_TAXONS gt 
 --join GENES_CORE_INTER gci on gci.id = gt.GENE_ID
) sel_tx
 join TAXON_GROUPS tg on tg.TAXON_ID = sel_tx.TAXON_ID
where tg.PROK_GROUP_ID between 0 and 22 
group by tg.PROK_GROUP_ID 
order by tg.PROK_GROUP_ID"
pgtn_df <- dbGetQuery(conn, sql)
if(dbExistsTable(conn,"PGTN")) {
  print("table pgtn exists -------------------") 
  dbRemoveTable(conn,"PGTN")  
}

dbWriteTable(conn, "PGTN", pgtn_df, overwrite=TRUE)

#pgtn_core
sql <- "select tg.PROK_GROUP_ID,
       count(sel_tx.taxon_id) as pgtn_cnt
from 
(
select distinct TAXON_ID
from GENES_TAXONS gt 
 join GENES_CORE_INTER gci on gci.id = gt.GENE_ID
) sel_tx
 join TAXON_GROUPS tg on tg.TAXON_ID = sel_tx.TAXON_ID
where tg.PROK_GROUP_ID between 0 and 22 
group by tg.PROK_GROUP_ID 
order by tg.PROK_GROUP_ID"
pgtn_core_df <- dbGetQuery(conn, sql)
if(dbExistsTable(conn,"PGTN_CORE")) {
  print("table pgtn_core exists -------------------") 
  dbRemoveTable(conn,"PGTN_CORE")  
}

dbWriteTable(conn, "PGTN_CORE", pgtn_core_df, overwrite=TRUE)

#pgsn
sql <- "select prok_group_id,
sum(weight_pg) as pgsn_cnt
from TAXONS tx
join ncbi_seqs ns on ns.TAXON_ID = tx.id
join gene_blo_seqs gbs on gbs.NCBI_SEQ_ID = ns.ID
join taxon_groups tg on tg.TAXON_ID = tx.ID
--join GENES_CORE_INTER gci on gci.ID = gbs.GENE_ID
where tg.PROK_GROUP_ID between 0 and 22
group by prok_group_id
order by tg.PROK_GROUP_ID
"
pgsn_df <- dbGetQuery(conn, sql)
if(dbExistsTable(conn,"PGSN")) {
  print("table PGSN exists -------------------") 
  dbRemoveTable(conn,"PGSN")  
}
dbWriteTable(conn, "PGSN", pgsn_df, overwrite=TRUE)

#pgsn_core
sql <- "select prok_group_id,
sum(weight_pg) as pgsn_cnt
from TAXONS tx
join ncbi_seqs ns on ns.TAXON_ID = tx.id
join gene_blo_seqs gbs on gbs.NCBI_SEQ_ID = ns.ID
join taxon_groups tg on tg.TAXON_ID = tx.ID
 join GENES_CORE_INTER gci on gci.ID = gbs.GENE_ID
where tg.PROK_GROUP_ID between 0 and 22
group by prok_group_id
order by tg.PROK_GROUP_ID
"
pgsn_core_df <- dbGetQuery(conn, sql)
if(dbExistsTable(conn,"PGSN_CORE")) {
  print("table PGSN_CORE exists -------------------") 
  dbRemoveTable(conn,"PGSN_CORE")  
}
dbWriteTable(conn, "PGSN_CORE", pgsn_core_df, overwrite=TRUE)

#--receive by prok-group
sql <- "
select pg.order_id,
pg_tx_src.prok_group_id,
pg_tx_src.pg_weight,
pgsn.pgsn_cnt,
pgtn.PGTN_CNT,
pg_tx_src.pg_weight /pgsn.pgsn_cnt * 100 / 1.1 as pgsn_magic,
pg_tx_src.pg_weight /pgtn.pgtn_cnt * 100 / 1.1 as pgtn_magic
from 
(
  select tg.PROK_GROUP_ID,
  sum(hctt_src.WEIGHT_TR_TX) as pg_weight
  from HGT_COM_TRSF_TAXONS hctt_src
  join TAXON_GROUPS tg on tg.TAXON_ID = hctt_src.TXSRC_ID
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




