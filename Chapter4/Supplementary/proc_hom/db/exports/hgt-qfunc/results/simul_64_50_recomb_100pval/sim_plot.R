library(quantmod)
library(Cairo)

rm(list=ls(all=TRUE))


setwd("/root/devel/proc_hom/db/exports/hgt-qfunc/results/simul_64_50_recomb_100pval")
print(getwd())


#qfunc_stats_df[qfunc_stats_df==-1] <- NA

#write.csv(qfunc_stats_df, file = "qfunc_stats_df.csv")

options(stringsAsFactors = FALSE)
qfunc_stats_df <- read.csv(file="qfunc_stats_df.csv",sep=",",head=TRUE)

#filter
qfunc_stats_df <- qfunc_stats_df[qfunc_stats_df$STAT=='SENS',]

#rename function names
qfunc_stats_df$FUNC[qfunc_stats_df$FUNC == 'Q7.1'] <- 'Q7'
qfunc_stats_df$FUNC[qfunc_stats_df$FUNC == 'Q8.1'] <- 'Q8a'
qfunc_stats_df$FUNC[qfunc_stats_df$FUNC == 'Q8.2'] <- 'Q8b'
#percentage
qfunc_stats_df$SENSIT <- qfunc_stats_df$SENSIT * 100

CairoPDF(file = "simul_64_50_recomb_100pval.pdf",
         width = 6, height = 2, onefile = TRUE, family = "Arial",
         title = "R Graphics Output", fonts = NULL, version = "1.1",
         paper = "special", bg = "transparent", fg = "black", pointsize = 14)

par(las = 1) # rotates the y axis values for every plot you make from now on unless otherwise specified

#margins
#bottom,left,top,right
par(mar=c(2, 2.5, 0.5, 0.5)) 

boxplot(SENSIT~FUNC, data=qfunc_stats_df, notch=FALSE, medlwd=4,
        col=(c("#FF9999","#99CCFF","#9999FF","#FF99CC")),
        main="",
        sub="",
        xlab="", 
        ylim=c(1, 100),
        horizontal=TRUE,
        lwd=2
        )
axis(1, 1:20*5, rep('', 20))


dev.off()

