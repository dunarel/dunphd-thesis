library(MASS)
library(reshape2)
library(sqldf)

rm(list=ls(all=TRUE))

#par
setwd("/root/devel/proc_hom/db/exports/hgt-par/family/data")
par_mtx <- as.matrix(read.csv("hgt-par-family-raxml-75-regular-tr-rl-mtx.csv", sep=",",header=FALSE))

rownames(par_mtx) <- 1:23
colnames(par_mtx) <- 1:23
par_df <- melt(par_mtx)
colnames(par_df) <- c("x", "y","val")

#com
setwd("/root/devel/proc_hom/db/exports/hgt-com/family/data")
com_mtx <- as.matrix(read.csv("hgt-com-family-raxml-75-regular-tr-rl-mtx.csv", sep=",",header=FALSE))

rownames(com_mtx) <- 1:23
colnames(com_mtx) <- 1:23
com_df <- melt(com_mtx)
colnames(com_df) <- c("x", "y","val")


#tot
setwd("/root/devel/proc_hom/db/exports/hgt-tot/family/data")
tot_mtx <- as.matrix(read.csv("hgt-tot-family-raxml-75-regular-tr-rl-mtx.csv", sep=",",header=FALSE))

rownames(tot_mtx) <- 1:23
colnames(tot_mtx) <- 1:23
tot_df <- melt(tot_mtx)
colnames(tot_df) <- c("x", "y","val")
# best from total
bst_tot <- sqldf("
select x,y 
from tot_df 
order by val desc
limit 20")
#print(bst_tot)


#join with com and par
bst_df = sqldf("
select bst_tot.x,
       bst_tot.y,
       tot_df.val as tot_val,
       par_df.val as par_val,
       com_df.val as com_val
from bst_tot
 join tot_df on tot_df.x = bst_tot.x and
                tot_df.y = bst_tot.y
 join par_df on par_df.x = bst_tot.x and 
                par_df.y = bst_tot.y
 join com_df on com_df.x = bst_tot.x and
                com_df.y = bst_tot.y
")
print(bst_df)

setwd("/root/devel/proc_hom/db/exports/synth/sp-tr/data")
write.csv(format(bst_df, scientific=FALSE), file = "sp-tr21.csv")
