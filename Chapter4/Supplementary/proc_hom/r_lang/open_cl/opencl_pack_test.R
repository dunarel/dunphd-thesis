library(OpenCL)
p = oclPlatforms()
d = oclDevices(p[[1]])

code = c("
         __kernel void dnorm(
         __global float* output,
         const unsigned int count,
         __global float* input,
         const float mu, const float sigma)
{
         int i = get_global_id(0);
         if(i < count)
         output[i] = exp(-0.5f * ((input[i] - mu) / sigma) * ((input[i] - mu) / sigma))
         / (sigma * sqrt( 2 * 3.14159265358979323846264338327950288 ) );
};")
k.dnorm <- oclSimpleKernel(d[[1]], "dnorm", code, "single")
f <- function(x, mu=0, sigma=1, ...)
  oclRun(k.dnorm, length(x), x, mu, sigma, ...)

## expect differences since the above uses single-precision but
## it should be close enough
f(1:10/2) - dnorm(1:10/2)

## this is optional - use floats instead of regular numeric vectors
#x <- clFloat(1:1000000000/2)
#print(f(x, native.result=TRUE))

## does the device support double-precision?
if (any(grepl("cl_khr_fp64", oclInfo(d[[1]])$exts))) {
  code = c("#pragma OPENCL EXTENSION cl_khr_fp64 : enable
__kernel void dnorm(
  __global double* output,
 const unsigned int count,
  __global double* input,
 const double mu, const double sigma)
{
  int i = get_global_id(0);
  if(i < count)
      output[i] = exp(-0.5f * ((input[i] - mu) / sigma) * ((input[i] - mu) / sigma))
      / (sigma * sqrt( 2 * 3.14159265358979323846264338327950288 ) );
};")
  k.dnorm <- oclSimpleKernel(d[[1]], "dnorm", code, "double")
  f <- function(x, mu=0, sigma=1)
    oclRun(k.dnorm, length(x), x, mu, sigma)
  
  ## probably not identical, but close...
  #f(1:100000000/2)
  print(f(1:10/2) - dnorm(1:10/2))
} else cat("\nSorry, your device doesn't support double-precision\n")

## Note that in practice you can use precision="best" in the first
## example which will pick "double" on devices that support it and
## "single" elsewhere
