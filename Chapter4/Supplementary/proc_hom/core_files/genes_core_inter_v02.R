rm(list=ls(all=TRUE))

# Set JAVA_HOME, set max. memory, and load rJava library
Sys.setenv(JAVA_HOME='/usr/java/latest/bin')
options(java.parameters="-Xmx1g")
library(rJava)

# Output Java version
.jinit()
print(.jcall("java/lang/System", "S", "getProperty", "java.version"))

# Load RJDBC library
library(RJDBC)


setwd("/root/devel/proc_hom/core_files")
print(getwd())

genes_core_tab <-read.csv(file = "core_genes.csv", header = FALSE)
names(genes_core_tab) <- c("name","level")

genes_core_lst <- list()
for (i in 0:2){
  genes_core_lst[[i+1]] <- as.vector(genes_core_tab[which(genes_core_tab$level == i),]$name)
}

genes_core <- unlist(genes_core_lst, recursive = TRUE, use.names = TRUE)



drv <- JDBC("org.hsqldb.jdbcDriver","/root/devel/proc_hom/lib/hsqldb.jar", identifier.quote="\"")
conn <- dbConnect(drv, "jdbc:hsqldb:hsql://localhost:9005/proc_hom", "SA", "")

#dbListTables(conn)
#data(iris)
#dbWriteTable(conn, "iris", iris, overwrite=TRUE)
#dbWriteTable(conn, "core_genes", core_genes, overwrite=TRUE)

#dbGetQuery(conn, "select count(*) from iris")
genes_tab <- dbReadTable(conn, "genes") 
genes <- genes_tab$NAME

#y <- dbGetQuery(conn, "select * from gene_blo_runs")
#min(y[4])
#max(y[4])

genes_core_inter <- intersect(genes_core,genes)
genes_core_inter_df <- data.frame(genes_core_inter)
names(genes_core_inter_df) <- c("name")
dbRemoveTable(conn,"genes_core_inter")
#dbSendQuery(conn, "drop table genes_core_inter;")
dbWriteTable(conn, "genes_core_inter", genes_core_inter_df, overwrite=TRUE)

#join with ids from genes
genes_core_inter_df <- dbGetQuery(conn, "select gn.id,
       gci.name       
from GENES_CORE_INTER gci
 join GENES gn on gn.name = gci.name")

#rewrite
dbRemoveTable(conn,"genes_core_inter")
dbWriteTable(conn, "genes_core_inter", genes_core_inter_df, overwrite=TRUE)
