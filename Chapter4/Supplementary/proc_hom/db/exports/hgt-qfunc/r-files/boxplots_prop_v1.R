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


setwd("/root/devel/proc_hom/db/exports/hgt-qfunc/results/simul_prop")
print(getwd())

#--receive by prok-group
sql <- "
select gbs.GENE_ID,
       count(*) as cnt
from gene_blo_seqs gbs
group by gbs.gene_id
order by count(*)
"

drv <- JDBC("org.hsqldb.jdbcDriver","/root/devel/proc_hom/lib/hsqldb.jar", identifier.quote="\"")
conn <- dbConnect(drv, "jdbc:hsqldb:hsql://localhost:9005/proc_hom", "SA", "")

prop_df <- dbGetQuery(conn, sql)
#qfunc_stats_df[qfunc_stats_df==-1] <- NA

prop_df$PAIRS <- (prop_df$CNT * prop_df$CNT)/2
prop_df$'90%' <- (100 / prop_df$PAIRS) * 100
prop_df$'75%' <- (200 / prop_df$PAIRS) * 100
prop_df$'50%' <- (300 / prop_df$PAIRS) * 100


require(reshape2)
prop_df2 <- subset(prop_df, select=c('GENE_ID','90%','75%','50%'))

df.m <- melt(prop_df2, id.var = "GENE_ID")

write.csv(df.m, file = "df.m.csv")
#qfunc_stats_df <- read.csv(file="qfunc_stats_df.csv",sep=",",head=TRUE)

## Increase bottom margin to make room for rotated labels
#par(mar = c(7, 4, 4, 2) + 0.1)


par(las = 1) # rotates the y axis values for every plot you make from now on unless otherwise specified

boxplot(value~variable, data=df.m, notch=FALSE,horizontal=TRUE,
        col=(c("blue","brown4","darkmagenta")),
        #main="Qfunc HGT", 
        xlab="",
        ylim=c(1, 30))
        
 