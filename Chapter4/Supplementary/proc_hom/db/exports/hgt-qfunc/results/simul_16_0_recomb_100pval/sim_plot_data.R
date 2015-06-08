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


setwd("/root/devel/proc_hom/db/exports/hgt-qfunc/results/simul_16_0_recomb_100pval")
print(getwd())

#--receive by prok-group
sql <- "
select hps.SENSIT as val,
'SENS' as stat,
case hps.QFUNC
when 7 then 'Q7.1'
when 8 then 'Q8.1'
when 9 then 'Q9'
when 11 then 'Q8.2'
end as func
from HGT_SIM_PERM_STATS hps
 union all 
select hps.ppv as val,
'PPV' as stat,
case hps.QFUNC
when 7 then 'Q7.1'
when 8 then 'Q8.1'
when 9 then 'Q9'
when 11 then 'Q8.2'
end as func
from HGT_SIM_PERM_STATS hps
"

drv <- JDBC("org.hsqldb.jdbcDriver","/root/devel/proc_hom/lib/hsqldb.jar", identifier.quote="\"")
conn <- dbConnect(drv, "jdbc:hsqldb:hsql://localhost:9005/proc_hom", "SA", "")

qfunc_stats_df <- dbGetQuery(conn, sql)
qfunc_stats_df[qfunc_stats_df==-1] <- NA

write.csv(qfunc_stats_df, file = "qfunc_stats_df.csv")
