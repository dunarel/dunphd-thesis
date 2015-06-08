library(OpenCL)
x <- clFloat(1:20000000/2)
print(x)
length(x)
as.double(x)
as.character(x)
as.integer(x)
is.clFloat(x)
identical(x, as.clFloat(as.numeric(x)))
x[1:5]
x[1] <- 0
## clFloat is the return type of oclRun(..., native.result=TRUE)
## for single-precision kernels. It can also be used instead of
## numeric vectors in such kernels to avoid conversions.
## See oclRun() examples.
