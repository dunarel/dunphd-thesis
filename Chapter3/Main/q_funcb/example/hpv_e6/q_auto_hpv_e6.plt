set terminal postscript eps enhanced defaultplex \
   leveldefault color colortext \
   dashed dashlength 3.0 linewidth 1.0 butt \
   palfuncparam 2000,0.003 \
   "Helvetica" 14

set output "q_auto_hpv_e6.eps"

set size 1,0.8
set size ratio 0.55
set lmargin 2
set rmargin 0.2
set tmargin 1
set bmargin 2

#
set datafile separator ","
set xrange [0:800] noreverse nowriteback
set yrange [0:1.01] noreverse nowriteback

set xtics 100 nomirror out axis
set mxtics 10
set ytics  nomirror out axis
set mytics 10

set style line 1 bgnd
set style line 2 lt rgb "cyan"
set style rect fc lt -1 fs solid 0.15 noborder
set style line 6 lt 1 lc rgb "blue" lw 3

set style line 8 lt 3 lc rgb "black" lw 3
#vertical delimiter
set parametric
const=386
set trange [0:1]


set style line 3 lt 3 lc rgb "black" lw 3
set style line 4 lt 4 lc rgb "gray40" lw 4
set style line 5 lt 1 lc rgb "gray20" lw 3

#set style fill pattern 2
#set style fill solid 1.0 noborder


plot  "f_1_2_3_4_w9_hpv_e6.csv" using 2:( abs($7-$6)> 0.01 ? $7 : $7) with lines ls 4 axes x1y1 title "max(Q_1\',Q_2\')"  \
      ,"f_1_2_3_4_w9_hpv_e6.csv" using 2:( abs($8-$6)> 0.01 ? $8 : $7) with lines ls 5 axes x1y1 title "Q_3\'"  \
      ,"f_1_2_3_4_w9_hpv_e6.csv" using 2:($6) with lines ls 3 axes x1y1 title "Q_4\'"  \
      ,const,t notitle with lines ls 8


