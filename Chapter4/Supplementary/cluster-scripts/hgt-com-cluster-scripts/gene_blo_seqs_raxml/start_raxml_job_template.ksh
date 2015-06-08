#/!bin/ksh

#Script de lancement 

#PBS -N raxml_res_$1
#PBS -q qwork@mp2
#PBS -l walltime=4:00:00


gene=$1
wdir=$SCRATCH/gene_blo_seqs_raxml/$gene

 if [ ! -d $wdir ]; then
   echo "creating $wdir"
   mkdir $wdir
 else 
   echo "Emptiying $wdir"
   rm -fr $wdir/*
 fi

cd $wdir

#calculate 20 phylogenies 
../raxml -T 24 -m GTRGAMMA -# 20 -s ../msa/$gene.phy -n $gene.tr
#calculate 100 bootstraps
../raxml -T 24 -m GTRGAMMA -b 12345 -# 100 -s ../msa/$gene.phy -n $gene.bs -k
#put replicates on tree
../raxml -T 24 -m GTRGAMMA -f b -t RAxML_bestTree.$gene.tr -z RAxML_bootstrap.$gene.bs -n $gene.re
