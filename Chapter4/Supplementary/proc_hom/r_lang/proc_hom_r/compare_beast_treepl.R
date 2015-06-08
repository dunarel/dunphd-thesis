# TODO: Add comment
# 
# Author: root
###############################################################################
setwd("/root/devel/proc_hom/r_lang/proc_hom_r")

library(quantmod)
library(devEMF)
rm(list=ls(all=TRUE))
#load(file="/root/devel/proc_hom/r_lang/proc_hom_r/hgt_com_beast.RData")
#new_beast = hgt_com_beast

#load(file="/data6/devel/proc_hom/r_lang/proc_hom_r/hgt_com_beast.RData")

#old_beast = hgt_com_beast

#load(file="/root/devel/proc_hom/r_lang/proc_hom_r/hgt_com_treepl.RData")
#new_treepl = hgt_com_treepl

#load(file="/data6/devel/proc_hom/r_lang/proc_hom_r/hgt_com_treepl.RData")
#old_treepl = hgt_com_treepl

load(file="/root/devel/proc_hom/r_lang/hgt_com_beast.RData")
load(file="/root/devel/proc_hom/r_lang/hgt_com_treepl.RData")


#print(hgt_com_beast)
#print(hgt_com_treepl)
#cat(hgt_com_treepl)

#wt = wilcox.test(hgt_com_treepl,hgt_com_beast, paired = TRUE)
wt = wilcox.test(hgt_com_treepl,hgt_com_beast, paired = TRUE, mu = 50, alt = 'less')
print(wt)

#mn <- mean(Delt(hgt_com_treepl,hgt_com_beast))
#print(mn)

#mn1 <- Delt(hgt_com_treepl,hgt_com_beast,k=0)
#print(mn1)


emf("qqplot_diff.emf")

#par()
#qqplot(hgt_com_beast, hgt_com_treepl, pch = 1, col = "darkblue")

qs = qqplot(hgt_com_beast, hgt_com_treepl, pch = 1, col = "darkblue", main = "Complete HGT time Q-Q Plot", xlab="B.E.A.S.T.", ylab="TreePL");

# compute the y=x line
dx = quantile(qs$x,0.75) - quantile(qs$x,0.25)
dy = quantile(qs$y,0.75) - quantile(qs$y,0.25)
#dy = prctile(s, 75) - prctile(s, 25);
b = dy/dx #slope
xc = (quantile(qs$x,0.25) + quantile(qs$x,0.75))/2  # center points
yc = (quantile(qs$y,0.25) + quantile(qs$y,0.75))/2  # ...
ymax = yc + b*(max(qs$x)-xc)
ymin = yc - b*(xc-min(qs$x))

a =  quantile(qs$y,0.75) - b*quantile(qs$x,0.75)


#abline([min(qs$x); max(qs$x)], [ymin; ymax])
abline(a=a, b=b, lty="dotted")







#title(main="main title", sub="sub-title", xlab="x-axis label", ylab="y-axis label")
# Add minor tick marks
library(Hmisc)
minor.tick(nx=5, ny=5, tick.ratio=0.5)


#qqline(hgt_com_beast,col="red")
#qqline(hgt_com_beast, hgt_com_treepl)
abline(0,1)
#abline(a = 0, b =1)
#qqline(a=0.25, b=1)

abline(h=quantile(hgt_com_treepl,c(0.25,0.50,0.75)),col="blue",lty=2)
abline(v=quantile(hgt_com_beast,c(0.25,0.50,0.75)),col="violet",lty=2)

dev.off()
