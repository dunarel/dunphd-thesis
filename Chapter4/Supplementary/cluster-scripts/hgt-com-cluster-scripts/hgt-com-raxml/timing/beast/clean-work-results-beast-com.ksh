#!/bin/ksh

#remove result files
cat values.txt | awk '{print $2}' | xargs -t -I{} sh -c 'rm -fr work/{}/dated_tree.annot'
cat values.txt | awk '{print $2}' | xargs -t -I{} sh -c 'rm -fr work/{}/gene_beast.log'
cat values.txt | awk '{print $2}' | xargs -t -I{} sh -c 'rm -fr work/{}/gene_beast.ops'
cat values.txt | awk '{print $2}' | xargs -t -I{} sh -c 'rm -fr work/{}/gene_beast.trees'







