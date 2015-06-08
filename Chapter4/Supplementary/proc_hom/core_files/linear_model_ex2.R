#load("/run/media/root/c9bcc7d8-ebde-445f-8d2c-750af288874e/BOOKS/Rlanguage/datasets/Beginning.RData")
#install.packages("ISwR")
rm(list=ls(all=TRUE))
library( package = ISwR )
attach(thuesen)

#lm(short.velocity~blood.glucose)
summary(lm(formula = magic_df$SRC_VAL ~ magic_df$SN_TN))
