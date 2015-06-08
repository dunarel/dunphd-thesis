#!/bin/ksh

#wdir=$SCRATCH/hgt-com-inp/inp-files
#rm -fr $1
#mkdir $1

#rm -f $wdir/*
#cat values.txt | awk '{print $2}' | xargs -t -I{} sh -c 'rm {}*'

values=`cat values.txt | awk '{print $2}'`

for var in $values ; do
   
   echo "Submitting gene $var"
   #submit files
   qsub raxml_qsub_$var.ksh
 
   


done







