

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
library(MASS)

#core genes
sql <-sprintf("select name
                from genes gn 
                  join genes_core_inter gci on gci.id=gn.id
              order by name")
genes_df <- dbGetQuery(conn, sql)

mdat2 <- c(genes_df$NAME,rep("", 9 *4 -36))

mdat <- matrix(mdat2, ncol = 9, byrow = TRUE)
print(mdat)
write.matrix(mdat, file = "core-genes-matrix.csv", sep = ",")
# rest of genes
sql <-sprintf("select name
                from genes gn
               where gn.id not in (select gci.id
                                   from genes_core_inter gci)
              order by name")
genes_df <- dbGetQuery(conn, sql)

mdat2 <- c(genes_df$NAME,rep("", 9*9-74))

mdat <- matrix(mdat2, ncol = 9, byrow = TRUE)
print(mdat)
write.matrix(mdat, file = "rest-genes-matrix.csv", sep = ",")

