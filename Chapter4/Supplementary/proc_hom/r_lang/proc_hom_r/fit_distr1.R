# TODO: Add comment
# 
# Author: root
###############################################################################

library(MASS);

## avoid spurious accuracy
op <- options(digits = 3);set.seed(123)
x <- rgamma(10, shape = 5, rate = 0.1)
fitdistr(x, 'gamma')
## now do this directly with more control.
fdr <- fitdistr(x, dgamma, list(shape = 1, rate = 0.1), lower = 0.001)
estim <- fdr$estimate
a<- estim[1][1]
print(a[1])



#d <-getwd() # print the current working directory - cwd
#print(d)
