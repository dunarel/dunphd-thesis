set terminal postscript eps noenhanced defaultplex \
   leveldefault color colortext \
   dashed dashlength 3.0 linewidth 1.0 butt \
   palfuncparam 2000,0.003 \
   "Helvetica" 16
set output "q_auto_E6.eps"

#
set size 1,0.75
set size ratio 0.5
set lmargin 3
set bmargin 3
set rmargin 3
set tmargin 3

#
set datafile separator ","
set xrange [0:800]
#set yrange [-1:1]
set y2range [-0.2:0.2]
set y2tics border

set xtics 100 nomirror
set mxtics 5



set style line 1 bgnd
set style line 2 lt rgb "cyan"
set style rect fc lt -1 fs solid 0.25 noborder

set style line 3 lt 1 lc rgb "black" lw 3
set style line 4 lt 1 lc rgb "red" lw 3
set style line 5 lt 1 lc rgb "green" lw 3
#set style line 6 lt 1 lc rgb "dark-blue" lw 3
set style line 6 lt 1 lc rgb "blue" lw 3

set style line 8 lt 3 lc rgb "black" lw 3
#vertical delimiter
set parametric
const=386
set trange [0:1]


plot "q_auto_E6.csv" using 2:($30) axes x1y1 with lines ls 3 lc rgb "blue" title "Q_4\'" 

