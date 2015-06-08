

rm(list=ls(all=TRUE))
library(MASS)
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


setwd("/root/devel/proc_hom/formulas2")
print(getwd())

#initialize




drop_la_tables <- function(){
  
  
  if(dbExistsTable(conn,"LA_SPECIES")) {
    print("table LA_SPECIES exists -------------------")
    dbRemoveTable(conn,"LA_SPECIES")  
  }
  if(dbExistsTable(conn,"LA_GENES")) {
    print("table LA_SPECIES exists -------------------")
    dbRemoveTable(conn,"LA_GENES")  
  }
  if(dbExistsTable(conn,"LA_ALLELES")) {
    print("table LA_ALLELES exists -------------------")
    dbRemoveTable(conn,"LA_ALLELES")  
  }
  if(dbExistsTable(conn,"LA_ALLELES_SPECIES")) {
    print("table LA_ALLELES_SPECIES exists -------------------")
    dbRemoveTable(conn,"LA_ALLELES_SPECIES")  
  }
  if(dbExistsTable(conn,"LA_PROK_GROUPS")) {
    print("table LA_PROK_GROUPS exists -------------------")
    dbRemoveTable(conn,"LA_PROK_GROUPS")  
  }
  if(dbExistsTable(conn,"LA_SPECIES_PROK_GROUPS")) {
    print("table LA_SPECIES_PROK_GROUPS exists -------------------")
    dbRemoveTable(conn,"LA_SPECIES_PROK_GROUPS")  
  }
  if(dbExistsTable(conn,"LA_ALLELES_GENES")) {
    print("table LA_ALLELES_GENES exists -------------------")
    dbRemoveTable(conn,"LA_ALLELES_GENES")  
  }
  
  if(dbExistsTable(conn,"LA_TRANSFERS")) {
    print("table LA_TRANSFERS exists -------------------")
    dbRemoveTable(conn,"LA_TRANSFERS")  
  }
  
}


create_la_tables <- function() {
  
  #-------------------------------------------------la_species
  sql <- sprintf("create table la_species as (
    select tx.TREE_ORDER - 1 as sp,
    tx.ID as taxon_id,
    tx.TREE_NAME,
    tx.SCI_NAME
    from taxons tx
    order by tx.TREE_ORDER
  ) WITH DATA")
  
  print(sql)
  dbSendUpdate(conn,sql)
  
  sql <- sprintf("CREATE UNIQUE INDEX la_species_sp ON la_species (sp asc)")
  print(sql)
  dbSendUpdate(conn,sql)
  
  sql <- sprintf("CREATE UNIQUE INDEX la_species_taxon_id ON la_species (taxon_id asc)")
  print(sql)
  dbSendUpdate(conn,sql)
  
  #-------------------------------------genes
  sql <- sprintf("create table la_genes as (
select rownum()-1 gn,
       gn.id as gene_id,
       gn.name
from GENES gn
where gn.name not in ('rbcL')
order by gn.id 
) WITH DATA")
  
  print(sql)
  dbSendUpdate(conn,sql)
  
  sql <- sprintf("CREATE UNIQUE INDEX la_genes_gn ON la_genes (gn asc)")
  print(sql)
  dbSendUpdate(conn,sql)
  
  sql <- sprintf("CREATE UNIQUE INDEX la_genes_gene_id ON la_genes (gene_id asc)")
  print(sql)
  dbSendUpdate(conn,sql)
  
  sql <- sprintf("CREATE UNIQUE INDEX la_genes_name ON la_genes (name asc)")
  print(sql)
  dbSendUpdate(conn,sql)
  
  
  #-------------------------------------alleles
  
  sql <- sprintf("create table la_alleles as (
select rownum() -1 as al,
       gbs.NCBI_SEQ_ID, 
       ns.VERS_ACCESS
from gene_blo_seqs gbs 
 join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
 --only alleles that have an associated taxon in the tree
 join lA_species ls on ls.TAXON_ID = ns.TAXON_ID
 --only alleles that are in regular genes not rcbL
 join LA_GENES lg on lg.GENE_ID = gbs.GENE_ID
order by gbs.NCBI_SEQ_ID
) WITH DATA")
  
  print(sql)
  dbSendUpdate(conn,sql)
  
  sql <- sprintf("CREATE UNIQUE INDEX la_alleles_al ON la_alleles (al asc)")
  print(sql)
  dbSendUpdate(conn,sql)
  
  sql <- sprintf("CREATE UNIQUE INDEX la_alleles_ncbi_seq_id ON la_alleles (ncbi_seq_id asc)")
  print(sql)
  dbSendUpdate(conn,sql)
  #-------------------------------------alleles_species
  
  sql <- sprintf("create table la_alleles_species as (
select la.AL,
       ls.SP,
       gbs.NCBI_SEQ_ID, 
       ns.VERS_ACCESS       
from gene_blo_seqs gbs 
 join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
 join LA_ALLELES la on la.NCBI_SEQ_ID = gbs.NCBI_SEQ_ID
 join lA_species ls on ls.TAXON_ID = ns.TAXON_ID
order by la.AL
) WITH DATA")
  
  print(sql)
  dbSendUpdate(conn,sql)
  
  sql <- sprintf("CREATE UNIQUE INDEX la_alleles_species_al ON la_alleles_species (al asc)")
  print(sql)
  dbSendUpdate(conn,sql)
  
  sql <- sprintf("CREATE INDEX la_alleles_species_sp ON la_alleles_species (sp asc)")
  print(sql)
  dbSendUpdate(conn,sql)
  
  sql <- sprintf("CREATE INDEX la_alleles_species_ncbi_seq_id ON la_alleles_species (ncbi_seq_id asc)")
  print(sql)
  dbSendUpdate(conn,sql)
  
  sql <- sprintf("CREATE INDEX la_alleles_species_vers_access ON la_alleles_species (vers_access asc)")
  print(sql)
  dbSendUpdate(conn,sql)
  
  #-------------------------------------prok-groups
  
  sql <- sprintf("create table la_prok_groups as (
select pg.ORDER_ID as PG,
       pg.id as PROK_GROUP_ID,
       pg.name
from PROK_GROUPS pg
where --pg.ID between 0 and 22
      pg.ID between 23 and 100
order by pg.ORDER_id
) WITH DATA")
  
  print(sql)
  dbSendUpdate(conn,sql)
  
  sql <- sprintf("CREATE UNIQUE INDEX la_prok_groups_pg ON la_prok_groups (pg asc)")
  print(sql)
  dbSendUpdate(conn,sql)
  
  sql <- sprintf("CREATE UNIQUE INDEX la_prok_groups_ncbi_seq_id ON la_prok_groups (PROK_GROUP_ID asc)")
  print(sql)
  dbSendUpdate(conn,sql)
  #-------------------------------------species-prok-groups
  sql <- sprintf("create table la_species_prok_groups as (
select ls.SP,
       lpg.PG,
       tg.PROK_GROUP_ID,
       tg.WEIGHT_PG,
       tg.TAXON_ID
from TAXON_GROUPS tg
 join LA_PROK_GROUPS lpg on lpg.PROK_GROUP_ID = tg.PROK_GROUP_ID
 join LA_SPECIES ls on ls.TAXON_ID = tg.TAXON_ID
where tg.WEIGHT_PG is not null
      --and tg.PROK_GROUP_ID between 0 and 22
      and tg.PROK_GROUP_ID between 23 and 100
order by ls.SP,
       lpg.PG
) WITH DATA")
  
  print(sql)
  dbSendUpdate(conn,sql)
  
  sql <- sprintf("CREATE INDEX la_species_prok_groups_sp ON la_species_prok_groups (sp asc)")
  print(sql)
  dbSendUpdate(conn,sql)
  
  sql <- sprintf("CREATE INDEX la_species_prok_groups_pg ON la_species_prok_groups (pg asc)")
  print(sql)
  dbSendUpdate(conn,sql)
  
  sql <- sprintf("CREATE INDEX la_species_prok_groups_prok_group_id ON la_species_prok_groups (prok_group_id asc)")
  print(sql)
  dbSendUpdate(conn,sql)
  
  sql <- sprintf("CREATE INDEX la_species_prok_groups_taxon_id ON la_species_prok_groups (taxon_id asc)")
  print(sql)
  dbSendUpdate(conn,sql)
  
  #-------------------------------------alleles-genes
  sql <- sprintf("create table la_alleles_genes as (
select la.AL,
       lg.GN,
       gbs.gene_id,
       gbs.NCBI_SEQ_ID
from GENE_BLO_SEQS gbs
 join LA_ALLELES la on la.NCBI_SEQ_ID = gbs.NCBI_SEQ_ID
 join LA_GENES lg on lg.GENE_ID = gbs.GENE_ID
order by gbs.GENE_ID
) WITH DATA")
  
  print(sql)
  dbSendUpdate(conn,sql)
  
  sql <- sprintf("CREATE INDEX la_alleles_genes_al ON la_alleles_genes (al asc)")
  print(sql)
  dbSendUpdate(conn,sql)
  
  sql <- sprintf("CREATE INDEX la_alleles_genes_gn ON la_alleles_genes (gn asc)")
  print(sql)
  dbSendUpdate(conn,sql)
  
  sql <- sprintf("CREATE INDEX la_alleles_genes_gene_id ON la_alleles_genes (gene_id asc)")
  print(sql)
  dbSendUpdate(conn,sql)
  
  sql <- sprintf("CREATE INDEX la_alleles_genes_ncbi_seq_id ON la_alleles_genes (ncbi_seq_id asc)")
  print(sql)
  dbSendUpdate(conn,sql)
  #-------------------------------------transfers
  sql <- sprintf("create table la_transfers as (
select lg.GN,
       la_als.AL as als,
       la_ald.AL as ald,
       hcit.WEIGHT,
       hcif.ID as fragm_id,
       hcif.GENE_ID,
       hcit.SOURCE_ID,
       hcit.DEST_ID       
from HGT_COM_INT_TRANSFERS hcit
 join HGT_COM_INT_FRAGMS hcif on hcif.ID = hcit.HGT_COM_INT_FRAGM_ID
 join LA_ALLELES la_als on la_als.NCBI_SEQ_ID = hcit.SOURCE_ID
 join LA_ALLELES la_ald on la_ald.NCBI_SEQ_ID = hcit.DEST_ID
 join LA_GENES lg on lg.GENE_ID = hcif.GENE_ID
 order by lg.GN,
          hcif.ID 
) WITH DATA")
  
  print(sql)
  dbSendUpdate(conn,sql)
  

}

export_la_tables <- function() {
  
  sql <-sprintf("select * from LA_SPECIES")
  la_species <- dbGetQuery(conn, sql)
  write.matrix(format(la_species, scientific=FALSE), file = "files2/la_species.csv", sep = ",")
  
  sql <-sprintf("select * from LA_GENES")
  la_species <- dbGetQuery(conn, sql)
  write.matrix(format(la_species, scientific=FALSE), file = "files2/la_genes.csv", sep = ",")

  sql <-sprintf("select * from LA_ALLELES")
  la_species <- dbGetQuery(conn, sql)
  write.matrix(format(la_species, scientific=FALSE), file = "files2/la_alleles.csv", sep = ",")
  
  sql <-sprintf("select * from LA_ALLELES_SPECIES")
  la_species <- dbGetQuery(conn, sql)
  write.matrix(format(la_species, scientific=FALSE), file = "files2/la_alleles_species.csv", sep = ",")
  
  sql <-sprintf("select * from LA_PROK_GROUPS")
  la_species <- dbGetQuery(conn, sql)
  write.matrix(format(la_species, scientific=FALSE), file = "files2/la_prok_groups.csv", sep = ",")
  
  sql <-sprintf("select * from LA_SPECIES_PROK_GROUPS")
  la_species <- dbGetQuery(conn, sql)
  write.matrix(format(la_species, scientific=FALSE), file = "files2/la_species_prok_groups.csv", sep = ",")
  
  sql <-sprintf("select * from LA_ALLELES_GENES")
  la_species <- dbGetQuery(conn, sql)
  write.matrix(format(la_species, scientific=FALSE), file = "files2/la_alleles_genes.csv", sep = ",")
  
  sql <-sprintf("select * from LA_TRANSFERS")
  la_species <- dbGetQuery(conn, sql)
  write.matrix(format(la_species, scientific=FALSE), file = "files2/la_transfers.csv", sep = ",")
  
  
}

result <- drop_la_tables()
print(paste("drop_la_tables",result))

result <- create_la_tables()
print(paste("create_la_tables",result))

result <- export_la_tables()
print(paste("export_la_tables",result))


