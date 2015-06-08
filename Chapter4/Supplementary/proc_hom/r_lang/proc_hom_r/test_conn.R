library(RJDBC)
drv <- JDBC("org.hsqldb.jdbcDriver","/root/devel/proc_hom/lib/hsqldb.jar", identifier.quote="\"")
conn <- dbConnect(drv, "jdbc:hsqldb:hsql://localhost:9005/proc_hom", "SA", "")

#dbListTables(conn)
#data(iris)
#dbWriteTable(conn, "iris", iris, overwrite=TRUE)

#dbGetQuery(conn, "select count(*) from iris")
#d <- dbReadTable(conn, "iris") 
#d

#y <- dbGetQuery(conn, "select * from gene_blo_runs")
#min(y[4])
#max(y[4])



