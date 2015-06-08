#!/bin/ksh

rm -fr ./raxml_qsub_*
rm -fr ./raxml_res_*
cat values.txt | awk '{print $2}' | xargs -t -I{} sh -c 'rm -fr {}'


