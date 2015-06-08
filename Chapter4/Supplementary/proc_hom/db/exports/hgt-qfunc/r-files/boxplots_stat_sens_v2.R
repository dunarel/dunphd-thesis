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


setwd("/root/devel/proc_hom/db/exports/hgt-qfunc/results/stat_90bs_100pval")
print(getwd())

#--receive by prok-group
sql <- "
select hqs.SENSIT as val,
'SENS' as stat,
case hqs.HGT_QFUNC_COND_ID
when 7 then 'Q7.1'
when 8 then 'Q8.1'
when 9 then 'Q9'
when 11 then 'Q8.2'
end as func
from HGT_QFUNC_STATS hqs
 union all
select hqs.ppv as val,
'PPV' as stat,
case hqs.HGT_QFUNC_COND_ID
when 7 then 'Q7.1'
when 8 then 'Q8.1'
when 9 then 'Q9'
when 11 then 'Q8.2'
end as func
from HGT_QFUNC_STATS hqs
 union all
select hqs.specif as val,
'SPEC' as stat,
case hqs.HGT_QFUNC_COND_ID
when 7 then 'Q7.1'
when 8 then 'Q8.1'
when 9 then 'Q9'
when 11 then 'Q8.2'
end as func
from HGT_QFUNC_STATS hqs
"

drv <- JDBC("org.hsqldb.jdbcDriver","/root/devel/proc_hom/lib/hsqldb.jar", identifier.quote="\"")
conn <- dbConnect(drv, "jdbc:hsqldb:hsql://localhost:9005/proc_hom", "SA", "")

qfunc_stats_df <- dbGetQuery(conn, sql)
qfunc_stats_df[qfunc_stats_df==-1] <- NA

write.csv(qfunc_stats_df, file = "qfunc_stats_df.csv")



qfunc_stats_df <- read.csv(file="qfunc_stats_df.csv",sep=",",head=TRUE)


boxplot(SENSIT~FUNC*STAT, data=qfunc_stats_df, notch=FALSE,
        col=(c("blue","#E9967A")),
        main="Qfunc HGT", 
        xlab="Sensibility and Specificity of Q7,Q8 and Q9",
        ylim=c(0.0, 1.0),horizontal=TRUE)


