
 id=$1
 gene=$2
 
 
 wdir=../../inp-files
 cwdir=`pwd`

 echo "current working dir: $cwdir"
 echo "working dir: $wdir" 
 inpfile=${wdir}/${gene}-inputfile
 cmd="perl run_hgt3.4.pl -inputfile=$inpfile -bootstrap=yes -nbhgt=200"
 echo "inputfile: $inpfile"
 echo "command: $cmd"
 eval $cmd



