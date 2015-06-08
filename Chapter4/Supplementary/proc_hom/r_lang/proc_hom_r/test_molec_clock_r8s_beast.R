# Testing Molecular Clock R8s Beast

# READ THIS: You have done enough R that I don't have to give you
# every single command this time.  E.g., you now know how to 
# source scripts, install packages, set working directories, etc.
# If I don't give you every single command to get set up,
# figure it out!

# Load necessary libraries; install phangorn if you don't have it
# Also, source the generic and R_tree functions scripts
library(ape)
library(phangorn)

sourcedir = '/_njm/'
source3 = '_genericR_v1.R'
source(paste(sourcedir, source3, sep=""))

source3 = '_R_tree_functions_v1.R'
source(paste(sourcedir, source3, sep=""))

# This is a new script for running r8s
source3 = 'r8s_functions_v1.R'
source(paste(sourcedir, source3, sep=""))

# All the scripts are kept online, here:
# http://ib.berkeley.edu/courses/ib200b/scripts/

# e.g., source the new r8s script:
source("http://ib.berkeley.edu/courses/ib200b/scripts/r8s_functions_v1.R")

# set working directory
# NOTE: MAKE SURE THE WD INCLUDES A LAST "/" CHARACTER!!
wd = "/Users/nick/Desktop/_ib200a/ib200b_sp2011/lab07/"
setwd(wd)

#########################################################
# In this lab, we are going to use some data from Nick's projects
#
# The major point will be (a) BE CAREFUL and (b) THINK when you are dating. (Ha!)
#########################################################

# First, we will look at some phylogenetic results on the complete
# mtDNA sequence of 60-some horse breeds, and an outgroup, the wild ass.

# get Nick's tree file
# I made this tree with MrBayes
trfn = "cons_Ecab_chrM_12May2010.fasta_nn.aln_prc.nexus_reroot.nexus"

horsetr = read.nexus(trfn)
plot(horsetr)

# Question: Why are the horse sequences so clustered?
# Question: Look at the tree.  Does it "look" clocklike?

# Let's make an ultrametric tree to compare.  chronopl is the 
# R function we've been using

# Note: we are scaling all trees to be of height 1 for now
chronotr = chronopl(horsetr, lambda = 0, age.min = 1)
plot(chronotr)
axisPhylo()
add.scale.bar()

# Question: What happened to the tree?  Is this good?

# Go to the website and look at compare_Rchrono_r8s.pdf
# Question: what looks to be the problem with chronopl
# (I mean the problem you can see in the trees, not the 
#  computational cause of it, which I don't know.)

# Basically, chronopl doesn't work right at the moment.  
# A better implementation is in Michael Sanderson's program r8s.

# You need to download r8s and place the executable file (it is a command-line program)
# in your working directory.  Then you have to tell run_r8s_1calib where the
# r8s program is by specifying the r8s_path_tmp variable

# (this is where I have mine)
r8s_path_tmp = "/Applications/r8s"
calibration_node_tip_specifiers = list("ass", "przewalski")
nsites_tmp = 16331
tmpwd1 = wd
r8s_nexus_fn1 = "horsetr_nexus_fn.nex"
r8s_ultra_logfn = run_r8s_1calib(tr=horsetr, calibration_node_tip_specifiers, r8s_method="LF", addl_cmd="", calibration_age=1.0, nsites=nsites_tmp, tmpwd=tmpwd1, r8s_nexus_fn=r8s_nexus_fn1, r8s_path=r8s_path_tmp)

r8s_tr_ultraLF = extract_tree_from_r8slog(logfn=r8s_ultra_logfn, delimiter=" = ")

# Does this look like a reasonable result?
plot(r8s_tr_ultraLF)
axisPhylo()
add.scale.bar()

# This function checks if a tree is it ultrametric?  
is.ultrametric(r8s_tr_ultraLF)

# run_r8s_1calib creates a NEXUS commands file for r8s.  This can be
# run in r8s via the command line without R at all (which is how
# most people who aren't me would do it).

# Take a look at it, just so you have seen a NEXUS commands file.
# PAUP, MrBayes, r8s, and many other standard programs use such files

moref("horsetr_nexus_fn.nex")

# We can also run r8s's NPRS (non-parametric rate scaling):

r8s_path_tmp = "/Applications/r8s"
calibration_node_tip_specifiers = list("ass", "przewalski")
nsites_tmp = 16331
tmpwd1 = wd
r8s_nexus_fn1 = "horsetr_nexus_fn.nex"
r8s_ultra_logfn = run_r8s_1calib(tr=horsetr, calibration_node_tip_specifiers, r8s_method="NPRS", addl_cmd="", calibration_age=1.0, nsites=nsites_tmp, tmpwd=tmpwd1, r8s_nexus_fn=r8s_nexus_fn1, r8s_path
