

rm(list=ls(all=TRUE))

library("R.oo")

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

#initialize




pval_func <- function(crit, stage, core, dataset ){
  #--------------------counts --------------------
  
  #genes_taxons_seqs
  if(dbExistsTable(conn,"GENES_TAXONS_SEQS")) {
    #print("table GENES_TAXONS_SEQS exists -------------------")
    if(dbExistsTable(conn,"TXNS")) dbRemoveTable(conn,"TXNS")  
    if(dbExistsTable(conn,"GENES_TAXONS")) dbRemoveTable(conn,"GENES_TAXONS")  
    if(dbExistsTable(conn,"GENES_TAXONS_SEQS")) dbRemoveTable(conn,"GENES_TAXONS_SEQS")  
  }
  
  if (core == "normal") {
    core_sel <- "genes"
  } else if (core == "inter") {
    core_sel <- "genes_core_inter"
  }
  
  sql <-sprintf("select count(*)
                from %s",core_sel)
  genes_cnt <- dbGetQuery(conn, sql)
  
  #print(genes_cnt)
  
  
  
  sql <- sprintf("create view genes_taxons_seqs as 
                 select gbs.GENE_ID,
                 ns.TAXON_ID,
                 gbs.NCBI_SEQ_ID       
                 from %s gn
                 join GENE_BLO_SEQS gbs on gbs.GENE_ID = gn.ID 
                 join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID",core_sel)
  #print(sql)
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
    #print("table PGTN exists -------------------") 
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
    #print("table PGSN exists -------------------") 
    dbRemoveTable(conn,"PGSN")  
  }
  dbWriteTable(conn, "PGSN", pgsn_df, overwrite=TRUE)
  
  
  #-----------------values------------------------------
  
  if(dbExistsTable(conn,"GENE_MTX")) {
    #print("table GENE_MTX exists -------------------")
    if(dbExistsTable(conn,"PG_SRC_VAL")) dbRemoveTable(conn,"PG_SRC_VAL")  
    if(dbExistsTable(conn,"PG_DST_VAL")) dbRemoveTable(conn,"PG_DST_VAL")  
    if(dbExistsTable(conn,"GENE_MTX")) dbRemoveTable(conn,"GENE_MTX")  
  }
  
  if (stage == "hgt_com") {
    stage_sel <- "HGT_COM_GENE_GROUPS_VALS" 
  } else if (stage == "hgt_par") {
    stage_sel <- "HGT_PAR_GENE_GROUPS_VALS" 
  }
  
  if (crit == "family") {
    crit_sel <- "0 and 22" 
  } else if (crit == "habitat") {
    crit_sel <- "86 and 93" 
  }
  
  
  sql <- sprintf("create view gene_mtx as
                 select ggv.GENE_ID,
                 ggv.PROK_GROUP_SOURCE_ID,
                 ggv.PROK_GROUP_DEST_ID,
                 ggv.VAL
                 from %s ggv
                 join %s gn on gn.ID = ggv.GENE_ID
                 where ggv.PROK_GROUP_SOURCE_ID between %s and
                 ggv.PROK_GROUP_DEST_ID between %s",stage_sel,core_sel,crit_sel,crit_sel)
  #print(sql)
  dbSendUpdate(conn,sql)
  
  sql <- "create view pg_src_val as
  select pg.ID as prok_group_id,
  nvl(sum(val),0) as src_val
  from PROK_GROUPS pg 
  left outer join gene_mtx mtx_s on mtx_s.PROK_GROUP_SOURCE_ID = pg.ID
  group by pg.id
  order by pg.id
  "
  dbSendUpdate(conn,sql)
  
  sql <- "create view pg_dst_val as
  select pg.ID as prok_group_id,
  nvl(sum(val),0) as dst_val
  from PROK_GROUPS pg 
  left outer join gene_mtx mtx_d on mtx_d.PROK_GROUP_DEST_ID = pg.ID
  group by pg.id
  order by pg.id
  "
  dbSendUpdate(conn,sql)
  
  if (crit == "family") {
    crit_sel <- "0" 
  } else if (crit == "habitat") {
    crit_sel <- "1" 
  }
  
  #magic
  sql <- sprintf("select pg.id,
                 pgtn.tn,
                 pgsn.sn,
                 psv.SRC_VAL,
                 pdv.DST_VAL,
                 psv.src_val/ pgsn.sn as src_sn,
                 psv.src_val/ pgtn.tn as src_tn,
                 pdv.dst_val/ pgsn.sn as dst_sn,
                 pdv.dst_val/ pgtn.tn as dst_tn
                 from PROK_GROUPS pg
                 join PGTN on pgtn.PROK_GROUP_ID = pg.id
                 join pgsn on pgsn.PROK_GROUP_ID = pg.id
                 join PG_SRC_VAL psv on psv.PROK_GROUP_ID = pg.id
                 join pg_dst_val pdv on pdv.PROK_GROUP_ID = pg.id
                 where pg.GROUP_CRITER_ID = %s
                 ",crit_sel)

magic_df <- dbGetQuery(conn, sql)

  if(dataset == "gene") {
    pgsn_tot <- weighted.mean(magic_df$SRC_SN,magic_df$SN)/genes_cnt * 10000
    pgtn_tot <- weighted.mean(magic_df$SRC_TN,magic_df$TN)/genes_cnt * 100
    
  } else if (dataset == "core") {
    pgsn_tot <- weighted.mean(magic_df$SRC_SN,magic_df$SN) * 100
    pgtn_tot <- weighted.mean(magic_df$SRC_TN,magic_df$TN)
  } 
  
  #else (
   #  try(throw("Unknown dataset.")); 
  #       print("It's ok!");
  #       )



print(sprintf("PGSN: %.2f, PGTN: %.2f",pgsn_tot,pgtn_tot))

magic_df$SN_TN <- magic_df$SN/magic_df$TN

ct_sn <- cor.test(magic_df$SN_TN,magic_df$SRC_SN)
ct_tn <- cor.test(magic_df$SN_TN,magic_df$SRC_TN)

print(sprintf("SN_PVAL: %.2f, TN_PVAL: %.2f",ct_sn$p.value, ct_tn$p.value))

  
  #-----------------------
  
  xvar <- magic_df$SN_TN
  #xvar <- magic_df$TN
  #yvar <- magic_df$SRC_VAL
  yvar <- magic_df$SRC_TN
  
  lm1 <- lm(formula = yvar ~ xvar)
  #print(summary(lm1))
  
  plot(xvar,yvar)
  abline(lm1)
  
  
  
  
  #---------------------------
  
  
  #res <- c(1,2)
  return(magic_df)
}

#print("ok---------")

crit <- "family"
#crit <- "habitat"

stage <- "hgt_com"
#stage <- "hgt_par"

core <- "normal"
#core <- "inter"

print("Complete")
print(pval_func("family","hgt_com","normal","gene"))
print(pval_func("family","hgt_com","inter","gene"))
print(pval_func("family","hgt_com","normal","core"))
print(pval_func("family","hgt_com","inter","core"))

print("Partial--------------------------------------")
for (i in 1:5) {print("")}

print(pval_func("family","hgt_par","normal","gene"))
print(pval_func("family","hgt_par","inter","gene"))
print(pval_func("family","hgt_par","normal","core"))
print(pval_func("family","hgt_par","inter","core"))

magic <- pval_func("family","hgt_par","inter","core")










