#!/bin/ksh

#remove index file
rm -fr ./job-idx.txt

#remove submit files
rm -fr ../qsubs/*

#remove log files
rm -fr ./jphgt-*.e*
rm -fr ./jphgt-*.o*

#useless backup files
rm -fr ./*~




