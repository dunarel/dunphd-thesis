library(MASS)
library(reshape2)
library(sqldf)


rm(list=ls(all=TRUE))

setwd("/root/devel/proc_hom/db/exports/hgt-par/family/data")
par_mtx <- as.matrix(read.csv("hgt-par-family-raxml-75-regular-tr-rl-mtx.csv", sep=",",header=FALSE))

rownames(par_mtx) <- 1:23
colnames(par_mtx) <- 1:23
par_df <- melt(par_mtx)
colnames(par_df) <- c("x", "y","val")


setwd("/root/devel/proc_hom/db/exports/hgt-com/family/data")
com_mtx <- as.matrix(read.csv("hgt-com-family-raxml-75-regular-tr-rl-mtx.csv", sep=",",header=FALSE))

rownames(com_mtx) <- 1:23
colnames(com_mtx) <- 1:23
com_df <- melt(com_mtx)
colnames(com_df) <- c("x", "y","val")

bst_com <- sqldf("
select * 
from com_df 
order by val desc
limit 20")
print(bst_com)


bst_par <- sqldf("
select * 
from par_df 
order by val desc
limit 20")
print(bst_par)

d1 = sqldf("
select x,y
from com_df
intersect 
select x,y
from par_df
")
print(paste("d1"))
print(d1)

d2 = sqldf("
select d1.x,
      d1.y,
      par_df.val as par,
      com_df.val as com,
      par_df.val || ' (' || com_df.val || ')' as lbl      
from d1 
join com_df on com_df.x = d1.x and 
               com_df.y = d1.y
join par_df on par_df.x = d1.x and
               par_df.y = d1.y
order by par desc
limit 20
")
print(d2)





#colnames(x) <- 1:23 #letters[1:23]