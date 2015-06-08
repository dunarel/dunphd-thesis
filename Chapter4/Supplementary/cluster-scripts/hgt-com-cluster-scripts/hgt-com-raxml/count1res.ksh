#!/bin/ksh

 max=0
 arr=`cat $1 | grep Computation | awk '{print $2}'`
for i in $arr 
do
 if [[ $i -gt $max ]];then
   max=$i   
 fi

done

echo $max
