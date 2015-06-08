#/!bin/ksh

#Script de lancement 

#PBS -N beast_res_$1
#PBS -q qwork@mp2
#PBS -l walltime=24:00:00


gene=$1
wdir=$HOME/hgt-com-110/hgt-com-raxml/timing/beast/$gene

# if [ ! -d $wdir ]; then
#   echo "creating $wdir"
#   mkdir $wdir
# else 
#   echo "Emptiying $wdir"
#   rm -fr $wdir/*
# fi

cd $wdir


#
java -jar ~/local/BEASTv1.7.4/lib/beast.jar -threads 24 -overwrite ./gene_beast.xml
