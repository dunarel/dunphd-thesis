#!/bin/ksh

#remove result files
cat values.txt | awk '{print $2}' | xargs -t -I{} sh -c 'rm -fr work/{}/*/*/*.nwk'
cat values.txt | awk '{print $2}' | xargs -t -I{} sh -c 'rm -fr work/{}/*/*/*.r8s'
cat values.txt | awk '{print $2}' | xargs -t -I{} sh -c 'rm -fr work/{}/*/*/*.cfg'




