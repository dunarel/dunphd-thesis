#!/bin/sh 

 cat jpraxml-*.o* | ruby -ne '@fen_f=$1 if $_ =~ /jobs_f.*job-tasks-(.*)\.yaml/; puts"#{@fen_f} #{$1}" if $_ =~ /Resources.*(walltime.*)/'

