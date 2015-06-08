#!/bin/ksh

#remove index file
rm -fr ./job-idx.txt

#remove submit files
rm -fr ../qsubs/*

#remove log files
rm -fr ./jptmtrpl-*.e*
rm -fr ./jptmtrpl-*.o*

#useless backup files
rm -fr ./*~




