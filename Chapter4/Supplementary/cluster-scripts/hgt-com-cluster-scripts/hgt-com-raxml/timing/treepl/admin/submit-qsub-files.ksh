#!/bin/ksh

#wdir=$SCRATCH/hgt-com-inp/inp-files
#rm -fr $1
#mkdir $1

#rm -f $wdir/*
#cat values.txt | awk '{print $2}' | xargs -t -I{} sh -c 'rm {}*'

values=`cat job-idx.txt | awk '{print $1}'`

for var in $values ; do
   
   echo "Submitting job $var"
   #submit files
   qsub qsubs/job-qsub-$var.ksh
    


done







