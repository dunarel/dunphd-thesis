#!/bin/ksh

#remove index file
rm -fr ./job-idx.txt

#remove submit files
rm -fr ./qsubs/*

#remove log files
rm -fr ./job-treepl-*.e*
rm -fr ./job-treepl-*.o*

#useless backup files
rm -fr ./*~




