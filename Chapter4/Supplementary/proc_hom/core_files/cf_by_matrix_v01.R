
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

tr_d <- "/root/devel/proc_hom/db/exports/hgt-com/family/data"
tr_base_name <- "hgt-com-family-raxml-90-regular-tr"

ab_tr_mtx_f <- sprintf("%s/%s-ab-mtx.csv", tr_d, tr_base_name)
print(ab_tr_mtx_f)

ab_tr_mtx <- as.matrix(read.csv(file = ab_tr_mtx_f, sep=",", header=FALSE))
pgsn_df <- dbGetQuery(conn, "select pg.order_id + 1 as id,
sn.pgsn_cnt
from pgsn sn
 join PROK_GROUPS pg on pg.id = sn.prok_group_id
order by pg.order_id")

pgtn_df <- dbGetQuery(conn, "select pg.order_id + 1 as id,
tn.pgtn_cnt
from pgtn tn
 join PROK_GROUPS pg on pg.id = tn.prok_group_id
order by pg.order_id")


