#!/bin/ksh

wdir=inp-files
#rm -fr $1
#mkdir $1

rm -f $wdir/*
values=`cat values.txt | sed 's/\s/,/'`

for var in $values ; do
   #col1=`echo $var | awk -F ',' '{print $1}'`
   col2=`echo $var | awk -F ',' '{print $2}'`
   echo "Generate inputfile for gene $col2"

   out=$wdir/$col2-inputfile

   cat ~/$1/gene_blo_seqs_sp/${col2}_sp.new > $out
   
   #raxm files
   #all distances to 0.1 : sed -r 's/:([0-9]+\.[0-9]+)/:0.1/g'
   #cat $SCRATCH/gene_blo_seqs_raxml/${col2}/RAxML_bipartitions.${col2}.re | sed 's/0\.0/0\.1/g' >> $out
   #only small distances to 0.1: 's/0\.0000/0\.1/g'
   cat ~/$1/gene_blo_seqs_raxml/results/${col2}/RAxML_bipartitions.${col2}.re |  sed 's/0\.0000/0\.1/g' >> $out 
   cat ~/$1/gene_blo_seqs_raxml/results/${col2}/RAxML_bootstrap.${col2}.bs | sed 's/0\.0000/0\.1/g' >> $out
   


done






