
library(quantmod)
library(devEMF)
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


df.m <- read.csv(file="df.m.csv",sep=",",head=TRUE)

# Add minor tick marks


#emf(file = "prop.emf", width = 5, height = 3,
#    bg = "transparent", fg = "black", pointsize = 10,
#    family = "sans", custom.lty = TRUE)

library(Cairo)
CairoPDF(file = "prop.pdf",
         width = 12, height = 3, onefile = TRUE, family = "Arial",
         title = "R Graphics Output", fonts = NULL, version = "1.1",
         paper = "special", bg = "transparent", fg = "black", pointsize =14)


## Increase bottom margin to make room for rotated labels
#par(mar = c(7, 4, 4, 2) + 0.1)

par(las = 1) # rotates the y axis values for every plot you make from now on unless otherwise specified


#par(cex.lab=2)
#par(cex.main=2)
#par(cex.sub=2)
#par(cex.axis=2)

#margins
#bottom,left,top,right
par(mar=c(2.5, 3, 0.5, 0.5)) 

boxplot(value~variable, data=df.m, notch=FALSE,horizontal=TRUE, medlwd=4,
        col=(c("#FF9999","#99CCFF","#FF99CC")),
        #main="Qfunc HGT", 
        xlab="",
        ylim=c(1, 30))
#axis(1, 0:5+0.5, rep('a', 5))
axis(1, 1:10, rep('', 10))
axis(1, c(2), c('2'),col.axis="#FF9999")
axis(1, c(4), c('4'),col.axis="#99CCFF")
axis(1, c(6), c('6'),col.axis="#FF99CC")


dev.off()
