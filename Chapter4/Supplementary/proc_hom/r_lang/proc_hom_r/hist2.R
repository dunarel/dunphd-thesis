# TODO: Add comment
# 
# Author: root
###############################################################################

setwd("/root/devel/proc_hom/r_lang/proc_hom_r")

#data = c(10,10,14,12,56,12)
#z = hist(data, plot=FALSE) 
#plot(z)

#duration = faithful$eruptions 
#hist(duration,    # apply the hist function 
# right=FALSE)    # intervals closed on the left 
rm(list=ls(all=TRUE))
load(file="hgt_com_beast.RData")
load(file="hgt_com_treepl.RData")

beast_quantiles = quantile(hgt_com_beast, probs=seq(0,1, by=0.05))
treepl_quantiles = quantile(hgt_com_treepl, probs=seq(0,1, by=0.05))


br = c(0,1,2,4,8,16,32,64,128,256,512,1024,2048,4096)
hst = hist(hgt_com_beast, br,plot=FALSE)
hst_rel_freqs <- hst$counts/sum(hst$counts)
#hst_rel_freqs <- hst$counts
hst_mids <-hst$mids
plot(hst)


#breaks
#br = seq(0, 3000, by=50)
#z = hist(vals_treepl, br,plot=FALSE) 
#plot(z)
