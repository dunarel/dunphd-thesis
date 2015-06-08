#
set terminal postscript eps noenhanced defaultplex \
   leveldefault color colortext \
   dashed dashlength 3.0 linewidth 1.0 butt \
   palfuncparam 2000,0.003 \
   "Helvetica" 16 
set output 'q_func_feta.eps'
#
set datafile separator ","
set xrange [0:2060]
#set yrange [-0.1:0.2]
set style line 1 bgnd
set style line 2 lt rgb "cyan"
set style rect fc lt -1 fs solid 0.25 noborder

#
set obj rect from 423, -1 to 437,1
set label at 423-10, 0.5 "L1" front font "Helvetica,12"

set obj rect from 516, -1 to 536,1
set label at 516-10, 0.5 "L2" front font "Helvetica,12"

set obj rect from 645, -1 to 761,1
set label at 645+30, 0.5 "L3" front font "Helvetica,12"

set obj rect from 864, -1 to 902,1
set label at 864-5, 0.5 "L4" front font "Helvetica,12"

set obj rect from 1023, -1 to 1172,1
set label at 1023+40, 0.5 "L5" front font "Helvetica,12"

set obj rect from 1260, -1 to 1292,1
set label at 1260-5, 0.5 "L6" front font "Helvetica,12"

set obj rect from 1380, -1 to 1454,1
set label at 1380+15, 0.5 "L7" front font "Helvetica,12"

set obj rect from 1557, -1 to 1586,1
set label at 1557-5, 0.5 "L8" front font "Helvetica,12"

set obj rect from 1707, -1 to 1775,1
set label at 1707+10, 0.5 "L9" front font "Helvetica,12"

set obj rect from 1845, -1 to 1925,1
set label at 1845+5, 0.5 "L10" front font "Helvetica,12"

set obj rect from 2013, -1 to 2033,1
set label at 2013-30, 0.5 "L11" front font "Helvetica,12"

set obj rect from 387,-1 to 389,1 fs solid 0.10
set obj rect from 471,-1 to 479,1 fs solid 0.10
set obj rect from 588,-1 to 599,1 fs solid 0.10
set obj rect from 807,-1 to 818,1 fs solid 0.10
set obj rect from 960,-1 to 974,1 fs solid 0.10
set obj rect from 1215,-1 to 1223,1 fs solid 0.10
set obj rect from 1332,-1 to 1343,1 fs solid 0.10
set obj rect from 1497,-1 to 1502,1 fs solid 0.10
set obj rect from 1659,-1 to 1661,1 fs solid 0.10
set obj rect from 1812,-1 to 1814,1 fs solid 0.10
set obj rect from 1959,-1 to 1976,1 fs solid 0.10
#
set style line 3 lt 1 lc rgb "dark-blue" lw 3
set style line 8 lt 3 lc rgb "black" lw 3
#vertical delimiter
set parametric
const=386
set trange [0:1]
#
plot  "q_func_feta.csv" using ($2+10):9 title 'Q1' with lines ls 3, \
const,t notitle with lines ls 8
#
