#!/bin/ksh

#Script de lancement 

#PBS -N jcbeast-combine
#PBS -q qwork@mp2
#PBS -l walltime=12:00:00

#PBS -joe                                                                                                                                                                                
wdir=/home/badescud/hgt-com-110/hgt-com-raxml/timing/beast/admin

cd $wdir

./combine_logs_trees.rb > ../log/combine_logs_trees.log







