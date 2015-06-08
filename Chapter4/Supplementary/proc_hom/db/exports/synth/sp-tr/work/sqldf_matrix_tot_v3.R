library(MASS)
library(reshape2)
library(sqldf)

rm(list=ls(all=TRUE))

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

#tot75-gn
setwd("/root/devel/proc_hom/db/exports/hgt-tot/family/data")
gn_mtx <- as.matrix(read.csv("hgt-tot-family-raxml-75-regular-tr-gn-mtx.csv", sep=",",header=FALSE))
rownames(gn_mtx) <- 1:23
colnames(gn_mtx) <- 1:23
gn_df <- melt(gn_mtx)
colnames(gn_df) <- c("x", "y","val")


bst90_df <- sqldf("
select x,y,
       1 as s90,
       0 as s75,
       0 as s50 
from tot90_df
--where x not in (1,4,13) and
--      y not in (1,4,13)
order by val desc
limit 10
")

bst75_df <- sqldf("
select x,y,
       0 as s90,
       1 as s75,
       0 as s50 
from tot75_df
--where x not in (1,4,13) and
--      y not in (1,4,13)
order by val desc
limit 10
")

bst50_df <- sqldf("
select x,y,
       0 as s90,
       0 as s75,
       1 as s50 
from tot50_df 
--where x not in (1,4,13) and
--      y not in (1,4,13)
order by val desc
limit 10
")


# best from total
bst_df <- sqldf("
select x,y,
       sum(s90) as t90,
       sum(s75) as t75,
       sum(s50) as t50
from 
(
select x,y,s90,s75,s50 
from bst90_df
 union
select x,y,s90,s75,s50 
from bst75_df
    union
select x,y,s90,s75,s50 
from bst50_df
)
group by x,y
")
#print(bst_tot)


#join with com
bst_tot_df = sqldf("
select bst_df.x,
       bst_df.y,
       bst_df.t90,
       bst_df.t75,
       bst_df.t50,
       gn_df.val as nb_genes,
       tot90_df.val as tot90_val,
       tot75_df.val as tot75_val,
       tot50_df.val as tot50_val,
       '[' || round(tot90_df.val,2)|| '; ' || round(tot75_df.val,2)|| '; ' || round(tot50_df.val,2) || ']' as sp_tr
from bst_df
 join gn_df on gn_df.x = bst_df.x and
               gn_df.y = bst_df.y
 join tot90_df on tot90_df.x = bst_df.x and
                  tot90_df.y = bst_df.y
 join tot75_df on tot75_df.x = bst_df.x and
                  tot75_df.y = bst_df.y
 join tot50_df on tot50_df.x = bst_df.x and
                  tot50_df.y = bst_df.y
 where gn_df.val > 6
")
print(bst_tot_df)



setwd("/root/devel/proc_hom/db/exports/synth/sp-tr/data")
write.csv(format(bst_tot_df, scientific=FALSE), file = "B-bst-tot-sp-tr.csv")
