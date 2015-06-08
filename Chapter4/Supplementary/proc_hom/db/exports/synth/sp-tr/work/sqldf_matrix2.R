library(MASS)
library(reshape2)
library(sqldf)

rm(list=ls(all=TRUE))

#com90
setwd("/root/devel/proc_hom/db/exports/hgt-com/family/data")
com90_mtx <- as.matrix(read.csv("hgt-com-family-raxml-90-regular-tr-rl-mtx.csv", sep=",",header=FALSE))
rownames(com90_mtx) <- 1:23
colnames(com90_mtx) <- 1:23
com90_df <- melt(com90_mtx)
colnames(com90_df) <- c("x", "y","val")


#com75
setwd("/root/devel/proc_hom/db/exports/hgt-com/family/data")
com75_mtx <- as.matrix(read.csv("hgt-com-family-raxml-75-regular-tr-rl-mtx.csv", sep=",",header=FALSE))
rownames(com75_mtx) <- 1:23
colnames(com75_mtx) <- 1:23
com75_df <- melt(com75_mtx)
colnames(com75_df) <- c("x", "y","val")

#com50
setwd("/root/devel/proc_hom/db/exports/hgt-com/family/data")
com50_mtx <- as.matrix(read.csv("hgt-com-family-raxml-50-regular-tr-rl-mtx.csv", sep=",",header=FALSE))
rownames(com50_mtx) <- 1:23
colnames(com50_mtx) <- 1:23
com50_df <- melt(com50_mtx)
colnames(com50_df) <- c("x", "y","val")


#tot90
setwd("/root/devel/proc_hom/db/exports/hgt-tot/family/data")
tot90_mtx <- as.matrix(read.csv("hgt-tot-family-raxml-90-regular-tr-rl-mtx.csv", sep=",",header=FALSE))
rownames(tot90_mtx) <- 1:23
colnames(tot90_mtx) <- 1:23
tot90_df <- melt(tot90_mtx)
colnames(tot90_df) <- c("x", "y","val")

#tot75
setwd("/root/devel/proc_hom/db/exports/hgt-tot/family/data")
tot75_mtx <- as.matrix(read.csv("hgt-tot-family-raxml-75-regular-tr-rl-mtx.csv", sep=",",header=FALSE))
rownames(tot75_mtx) <- 1:23
colnames(tot75_mtx) <- 1:23
tot75_df <- melt(tot75_mtx)
colnames(tot75_df) <- c("x", "y","val")

#tot50
setwd("/root/devel/proc_hom/db/exports/hgt-tot/family/data")
tot50_mtx <- as.matrix(read.csv("hgt-tot-family-raxml-50-regular-tr-rl-mtx.csv", sep=",",header=FALSE))
rownames(tot50_mtx) <- 1:23
colnames(tot50_mtx) <- 1:23
tot50_df <- melt(tot50_mtx)
colnames(tot50_df) <- c("x", "y","val")

#tot90-gn
setwd("/root/devel/proc_hom/db/exports/hgt-tot/family/data")
gn_mtx <- as.matrix(read.csv("hgt-tot-family-raxml-90-regular-tr-gn-mtx.csv", sep=",",header=FALSE))
rownames(gn_mtx) <- 1:23
colnames(gn_mtx) <- 1:23
gn_df <- melt(gn_mtx)
colnames(gn_df) <- c("x", "y","val")

# best from total
bst_tot <- sqldf("
select x,y 
from tot90_df 
order by val desc
limit 20")
#print(bst_tot)


#join with com and par
bst_df = sqldf("
select bst_tot.x,
       bst_tot.y,
       gn_df.val as nb_genes,
       com90_df.val as com90_val,
       com75_df.val as com75_val,
       com50_df.val as com50_val,
       tot90_df.val as tot90_val,
       tot75_df.val as tot75_val,
       tot50_df.val as tot50_val
from bst_tot
 join gn_df on gn_df.x = bst_tot.x and
               gn_df.y = bst_tot.y
 join tot90_df on tot90_df.x = bst_tot.x and
                  tot90_df.y = bst_tot.y
 join tot75_df on tot75_df.x = bst_tot.x and
                  tot75_df.y = bst_tot.y
 join tot50_df on tot50_df.x = bst_tot.x and
                  tot50_df.y = bst_tot.y
 join com90_df on com90_df.x = bst_tot.x and
                  com90_df.y = bst_tot.y
 join com75_df on com75_df.x = bst_tot.x and
                  com75_df.y = bst_tot.y
 join com50_df on com50_df.x = bst_tot.x and
                  com50_df.y = bst_tot.y
")
print(bst_df)

setwd("/root/devel/proc_hom/db/exports/synth/sp-tr/data")
write.csv(format(bst_df, scientific=FALSE), file = "B-tot90-sp-tr.csv")
