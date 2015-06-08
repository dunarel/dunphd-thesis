#!/bin/ksh

#wdir=$SCRATCH/hgt-com-inp/inp-files
#rm -fr $1
#mkdir $1

#rm -f $wdir/*
values=`cat values.txt | sed 's/\s/,/'`
failed=0
for var in $values ; do
   col1=`echo $var | awk -F ',' '{print $1}'`
   col2=`echo $var | awk -F ',' '{print $2}'`
   res_file="hgt-com-raxml_gene${col2}_id${col1}.BQ"
   
   progress=`cat $res_file/output.dat | ./count1res.ksh `

   res_lines=`cat $res_file/results.txt | wc --l`
   echo "$col2,$res_lines,$progress"

   if [[ $progress == 1 ]];then
      let failed+=1
   fi 

   
   
   #out=$wdir/$col2-inputfile

   #cat ~/gene_blo_seqs_sp/${col2}_sp.new | sed -r 's/:([0-9]+\.[0-9]+)/:0.1/g' > $out
   
   #raxm files
   #cat $SCRATCH/gene_blo_seqs_raxml/${col2}/RAxML_bipartitions.${col2}.re | sed 's/0\.0/0\.1/g' >> $out
   #cat $SCRATCH/gene_blo_seqs_raxml/${col2}/RAxML_bipartitions.${col2}.re | sed -r 's/:([0-9]+\.[0-9]+)/:0.1/g' >> $out
   #cat $SCRATCH/gene_blo_seqs_raxml/${col2}/RAxML_bootstrap.${col2}.bs | sed -r 's/:([0-9]+\.[0-9]+)/:0.1/g' >> $out
   


done



echo "Total failed jobs: $failed"


