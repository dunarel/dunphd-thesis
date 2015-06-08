set terminal postscript eps enhanced defaultplex \
   leveldefault color colortext \
   dashed dashlength 3.0 linewidth 1.0 butt \
   palfuncparam 2000,0.003 \
   "Helvetica" 14



set output "q_auto_hpv_e6_high_rand.eps"

set size 1,0.8
set size ratio 0.55
set lmargin 2
set rmargin 0.2
set tmargin 1
set bmargin 2

#
set datafile separator ","
set xrange [0:800] #noreverse nowriteback
set yrange [-0.1:0.2] #noreverse nowriteback

#set y2range [-0.05:0.1]
#set y2tics border

set xtics 100 nomirror out axis
set mxtics 10
set ytics  nomirror out axis
set mytics 10

set style line 1 bgnd
set style line 2 lt rgb "cyan"
set style rect fc lt -1 fs solid 0.15 noborder
#
#set obj rect from 423, -1 to 437,1
#set label at 423-10, 0.5 "L1" front font "Helvetica,12"

#set obj rect from 0,-2 to 800,2 fs solid 0.50

#

#set style line 6 lt 1 lc rgb "dark-blue" lw 3
set style line 6 lt 1 lc rgb "blue" lw 3

set style line 8 lt 3 lc rgb "black" lw 3
#vertical delimiter
set parametric
const=386
set trange [0:1]
#
#plot  "q_auto_E6.csv" using 1:($8>0.6 ? $8 : 1/0) title 'Q1AutoModif' with lines ls 3 \
#         ,"q_auto_E6.csv" using 1:($8<=0.6 ? $8 : 1/0) title 'Q1AutoModif' with lines ls 5

# smooth bezier/csplines/acsplines
#,"q_auto_E6.csv" using 2:12 axes x1y2 title 'gap prop' smooth csplines ls 4 \
# with lines
# ,"q_auto_E6.csv" using 2:13 axes x1y2 title 'rand' smooth csplines ls 4 \
#,"q_auto_E6.csv" using 2:15 axes x1y2 title 'ham' smooth csplines ls 6 \

#plot  "q_auto_E6.csv" using 2:(($4<1 && $6<1) ? $9 : 1/0) title 'Q1Auto' smooth csplines ls 3 \
#      ,"q_auto_E6.csv" using 2:($9*$14) axes x1y2 title 'Q*CorRand' smooth csplines ls 4 \
      #,"q_auto_E6.csv" using 2:14 axes x1y2 title 'cor_rand' smooth csplines ls 5 \
      

#      ,"q_auto_E6.csv" using 2:4 axes x1y2 title 'dXY inv_' with lines ls 4 \
#      ,"q_auto_E6.csv" using 2:6 axes x1y2 title 'vX inv' with lines ls 5 \
#      ,"q_auto_E6.csv" using 2:8 axes x1y2 title 'vY inv' with lines ls 6
#plot  "f_1_2_3_4_w9.csv" using 2:(($7==$8) ? $7 : 1/0) with lines ls 3 axes x1y1 title 'max(Q1\', Q\'2)'  \
#,"f_1_2_3_4_w9.csv" using 2:( abs($8-$6)> 0.01 ? $8 : $8) with filledcu x1 ls 5 axes x1y1 title 'Q3'  \
#

set style line 3 lt 3 lc rgb "black" lw 3
set style line 4 lt 4 lc rgb "gray40" lw 4
set style line 5 lt 1 lc rgb "gray20" lw 3

#set style fill pattern 2
#set style fill solid 1.0 noborder


plot  "f_1_2_3_4_w9_hpv_e6_high_rand.csv" using 2:( abs($7-$6)> 0.01 ? $7 : $7) with lines ls 4 axes x1y1 title "max(Q_1,Q_2)"  \
      ,"f_1_2_3_4_w9_hpv_e6_high_rand.csv" using 2:( abs($8-$6)> 0.01 ? $8 : $7) with lines ls 5 axes x1y1 title "Q_3"  \
      ,"f_1_2_3_4_w9_hpv_e6_high_rand.csv" using 2:($6) with lines ls 3 axes x1y1 title "Q_4"






