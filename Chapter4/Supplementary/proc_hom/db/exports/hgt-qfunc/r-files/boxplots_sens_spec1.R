# Boxplot of MPG by Car Cylinders
#boxplot(mpg~cyl,data=mtcars, main="Car Milage Data",
#        xlab="Number of Cylinders", ylab="Miles Per Gallon") 

# Notched Boxplot of Tooth Growth Against 2 Crossed Factors
# boxes colored for ease of interpretation
#boxplot(len~dose*supp, data=ToothGrowth, notch=FALSE,
#        col=(c("gold","darkgreen","blue","#E9967A")),
#        main="Tooth Growth", xlab="Suppliment and Dose") 

##################################


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

#--receive by prok-group
sql <- "
select hqs.SENSIT as val,
'SENS' as stat,
case hqs.HGT_QFUNC_COND_ID
when 4 then 'F4'
when 2 then 'F2'
end as func
from HGT_QFUNC_STATS hqs
union all
select hqs.PPV as val,
'PPV' as stat,
case hqs.HGT_QFUNC_COND_ID
when 4 then 'F4'
when 2 then 'F2'
end as func
from HGT_QFUNC_STATS hqs
"

drv <- JDBC("org.hsqldb.jdbcDriver","/root/devel/proc_hom/lib/hsqldb.jar", identifier.quote="\"")
conn <- dbConnect(drv, "jdbc:hsqldb:hsql://localhost:9005/proc_hom", "SA", "")

qfunc_stats_df <- dbGetQuery(conn, sql)
qfunc_stats_df[qfunc_stats_df==-1] <- NA

boxplot(SENSIT~FUNC*STAT, data=qfunc_stats_df, notch=FALSE,
        col=(c("blue","#E9967A")),
        main="Qfunc HGT", xlab="Sensibility and Specificity of Q2 and Q4")


