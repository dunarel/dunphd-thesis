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

one_str = gsub("\n", " ", "
select cnt_rel 
from hgt_par_transfer_groups
where PROK_GROUP_SOURCE_ID in (86,87) and 
      PROK_GROUP_DEST_ID in (86,87)
")


two_str = gsub("\n", " ", "
select cnt_rel 
from hgt_par_transfer_groups
where PROK_GROUP_SOURCE_ID in (86,87,88,89,90,91,92,93) and
      PROK_GROUP_DEST_ID in (86,87,88,89,90,91,92,93)
")

one <- dbGetQuery(conn, one_str)
two <- dbGetQuery(conn, two_str)

test = wilcox.test(one$CNT_REL,two$CNT_REL, mu=0, alt="g")

test


