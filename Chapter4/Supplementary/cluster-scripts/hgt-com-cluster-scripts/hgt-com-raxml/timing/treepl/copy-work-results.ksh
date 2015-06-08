#!/bin/ksh

#remove submit files
#rm -fr ./beast_qsub_*
#remove log files
#rm -fr ./beast_res_*
#remove result files
 #cat values.txt | awk '{print $2}' | xargs -t -I{} sh -c 'cp -r work/{} results/'
 #cat values.txt | awk '{print $2}' | xargs -t -I{} sh -c 'rm -fr results/{}/*.yaml'
 #cat values.txt | awk '{print $2}' | xargs -t -I{} sh -c 'rm -fr results/{}/*/*/*.tr'
 #cat values.txt | awk '{print $2}' | xargs -t -I{} sh -c 'rm -fr results/{}/*/*/*.r8s'
 #cat values.txt | awk '{print $2}' | xargs -t -I{} sh -c 'rm -fr results/{}/*/*/*.cfg'
 cp -r work/* results/




