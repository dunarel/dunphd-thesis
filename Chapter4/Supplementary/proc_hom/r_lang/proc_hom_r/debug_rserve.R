# TODO: Add comment
# 
# Author: root
###############################################################################

library(MASS)

setwd("/root/devel/proc_hom/r_lang")

location_f<-getwd()

print(location_f)
load(".RData") 

fdr<-fitdistr(stbr, 'lognormal')
fdr_estimate_meanlog <- fdr$estimate[1]
fdr_estimate_sdlog <- fdr$estimate[2]

print(fdr_estimate_meanlog)
print(fdr_estimate_sdlog)

fdr_sd_meanlog <- fdr$sd[1]
fdr_sd_sdlog <- fdr$sd[2]

print(fdr_sd_meanlog)
print(fdr_sd_sdlog)




