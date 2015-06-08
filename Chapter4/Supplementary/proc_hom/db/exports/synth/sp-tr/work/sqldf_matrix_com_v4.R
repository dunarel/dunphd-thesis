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



#com75-gn
setwd("/root/devel/proc_hom/db/exports/hgt-com/family/data")
gn_mtx <- as.matrix(read.csv("hgt-com-family-raxml-75-regular-tr-gn-mtx.csv", sep=",",header=FALSE))
rownames(gn_mtx) <- 1:23
colnames(gn_mtx) <- 1:23
gn_df <- melt(gn_mtx)
colnames(gn_df) <- c("x", "y","val")


bst90_df <- sqldf("
select com90_df.x,
       com90_df.y,
       1 as s90,
       0 as s75,
       0 as s50,
       gn_df.val as nb_genes,
       com90_df.val
from com90_df
 join gn_df on gn_df.x = com90_df.x and
               gn_df.y = com90_df.y
where gn_df.val > 6
order by com90_df.val desc
limit 10
")

bst75_df <- sqldf("
select com75_df.x,
       com75_df.y,
       0 as s90,
       1 as s75,
       0 as s50,
       gn_df.val as nb_genes,
       com75_df.val
from com75_df
 join gn_df on gn_df.x = com75_df.x and
               gn_df.y = com75_df.y
where gn_df.val > 6
order by com75_df.val desc
limit 10
")

bst50_df <- sqldf("
select com50_df.x,
       com50_df.y,
       0 as s90,
       0 as s75,
       1 as s50,
       gn_df.val as nb_genes,
       com50_df.val
from com50_df
 join gn_df on gn_df.x = com50_df.x and
               gn_df.y = com50_df.y
where gn_df.val > 6
order by com50_df.val desc
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
bst_com_df = sqldf("
select bst_df.x,
       bst_df.y,
       bst_df.t90,
       bst_df.t75,
       bst_df.t50,
       gn_df.val as nb_genes,
       com90_df.val as com90_val,
       com75_df.val as com75_val,
       com50_df.val as com50_val,
       '[' || round(com90_df.val,2)|| '; ' || round(com75_df.val,2)|| '; ' || round(com50_df.val,2) || ']' as sp_tr
from bst_df
 join gn_df on gn_df.x = bst_df.x and
               gn_df.y = bst_df.y
 join com90_df on com90_df.x = bst_df.x and
                  com90_df.y = bst_df.y
 join com75_df on com75_df.x = bst_df.x and
                  com75_df.y = bst_df.y
 join com50_df on com50_df.x = bst_df.x and
                  com50_df.y = bst_df.y
")
print(bst_com_df)



setwd("/root/devel/proc_hom/db/exports/synth/sp-tr/data")
write.csv(format(bst_com_df, scientific=FALSE), file = "A-bst-com-sp-tr.csv")
