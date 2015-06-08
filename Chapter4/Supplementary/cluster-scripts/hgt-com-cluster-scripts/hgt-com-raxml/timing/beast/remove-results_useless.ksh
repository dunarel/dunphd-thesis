#!/bin/ksh

#remove submit files
#rm -fr ./beast_qsub_*
#remove log files
#rm -fr ./beast_res_*
#remove result files
# cat values.txt | awk '{print $2}' | xargs -t -I{} sh -c 'rm -fr work/{} results/'


 cat values.txt | awk '{print $2}' | xargs -t -I{} sh -c 'rm -fr results/{}/align_beast.fasta'
 cat values.txt | awk '{print $2}' | xargs -t -I{} sh -c 'rm -fr results/{}/gene_beast.log'
 cat values.txt | awk '{print $2}' | xargs -t -I{} sh -c 'rm -fr results/{}/gene_beast.ops'
 cat values.txt | awk '{print $2}' | xargs -t -I{} sh -c 'rm -fr results/{}/gene_beast.trees'
 cat values.txt | awk '{print $2}' | xargs -t -I{} sh -c 'rm -fr results/{}/gene_beast.xml'
 cat values.txt | awk '{print $2}' | xargs -t -I{} sh -c 'rm -fr results/{}/gene_res.tr'
 cat values.txt | awk '{print $2}' | xargs -t -I{} sh -c 'rm -fr results/{}/starting_tree.nwk'


