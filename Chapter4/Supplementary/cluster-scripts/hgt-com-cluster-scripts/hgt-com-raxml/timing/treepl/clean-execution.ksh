#!/bin/ksh

#remove index file
rm -fr ./job-idx.txt

#remove submit files
rm -fr ./qsubs/*

#remove log files
rm -fr ./jtreeplc*.e*
rm -fr ./jtreeplc*.o*

#useless backup files
rm -fr ./*~




