set terminal postscript eps enhanced defaultplex \
   leveldefault color colortext \
   dashed dashlength 3.0 linewidth 1.0 butt \
   palfuncparam 2000,0.003 \
   "Helvetica" 14

set output "q_auto_feta_E6_02.eps"
#set key off

set size 1,0.8
set size ratio 0.55
set lmargin 2
set rmargin 0.2
set tmargin 1
set bmargin 2

#
set datafile separator ","
set xrange [0:2060] #noreverse nowriteback
set yrange [0:1] #noreverse nowriteback

#set y2range [-0.2:0.2]
#set y2tics border

set xtics 200 nomirror out axis
set mxtics 5
set ytics  nomirror out axis
set mytics 5

set style line 1 bgnd
set style line 2 lt rgb "cyan"
set style rect fc lt -1 fs solid 0.20 noborder
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

#set style line 6 lt 1 lc rgb "dark-blue" lw 3
set style line 6 lt 1 lc rgb "blue" lw 3

set style line 8 lt 3 lc rgb "black" lw 3
#vertical delimiter
set parametric
const=386
set trange [0:1]

set style line 3 lt 3 lc rgb "black" lw 2
set style line 4 lt 4 lc rgb "gray40" lw 2
set style line 5 lt 1 lc rgb "gray20" lw 3

#set style fill pattern 2
set style fill solid 1.0 noborder


plot  "f_1_2_3_4_w9.csv" using 2:( abs($7-$6)> 0.01 ? $7 : $7) with lines ls 4 axes x1y1 title "max(Q_1\',Q_2\')"  \
      ,"f_1_2_3_4_w9.csv" using 2:( abs($8-$6)> 0.01 ? $8 : $7) with lines ls 5 axes x1y1 title "Q_3\'"  \
      ,"f_1_2_3_4_w9.csv" using 2:($6) with lines ls 3 axes x1y1 title "Q_4\'" \
      ,const,t notitle with lines ls 8

