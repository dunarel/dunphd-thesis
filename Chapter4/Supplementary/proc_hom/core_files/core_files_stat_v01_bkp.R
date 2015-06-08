
rm(list=ls(all=TRUE))

# Set JAVA_HOME, set max. memory, and load rJava library
Sys.setenv(JAVA_HOME='/usr/java/latest/bin')
options(java.parameters="-Xmx1g")
library(rJava)
.jinit()
print(.jcall("java/lang/System", "S", "getProperty", "java.version"))
library(RJDBC)


setwd("/root/devel/proc_hom/core_files")
print(getwd())


#--receive by prok-group
sql <- "select pg.order_id,
       pg_tx_src.prok_group_id,
       pg_tx_src.pg_weight,
pgsn.pgsn,
round(pg_tx_src.pg_weight /pgsn.pgsn,3) as magic
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
join (select prok_group_id,
sum(weight_pg) as pgsn
from TAXONS tx
join ncbi_seqs ns on ns.TAXON_ID = tx.id
join gene_blo_seqs gbs on gbs.NCBI_SEQ_ID = ns.ID
join taxon_groups tg on tg.TAXON_ID = tx.ID
--join GENES_CORE_INTER gci on gci.ID = gbs.GENE_ID
where tg.PROK_GROUP_ID between 0 and 22
group by prok_group_id
order by tg.PROK_GROUP_ID) pgsn on pgsn.prok_group_id = pg_tx_src.prok_group_id
join PROK_GROUPS pg on pg.id = pg_tx_src.prok_group_id
order by pg.order_id"

drv <- JDBC("org.hsqldb.jdbcDriver","/root/devel/proc_hom/lib/hsqldb.jar", identifier.quote="\"")
conn <- dbConnect(drv, "jdbc:hsqldb:hsql://localhost:9005/proc_hom", "SA", "")

pgsn_df <- dbGetQuery(conn, sql)


