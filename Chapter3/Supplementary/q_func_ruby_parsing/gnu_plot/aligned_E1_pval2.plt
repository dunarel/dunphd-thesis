set terminal postscript eps noenhanced defaultplex \
   color colortext \
   dashed dashlength 3.0 linewidth 1.0 butt \
   palfuncparam 2000,0.003 \
   "Helvetica" 16
set output "../eps_s/aligned_E1_pval2.eps"

#
#set size 1,0.75
#set size ratio 0.5
set lmargin 10
set bmargin 11
set rmargin 10
set tmargin 10

#
set datafile separator ","
#set xrange [0:2060]
set yrange [0:0.1]
set style line 1 bgnd
set style line 2 lt rgb "cyan"
set style line 3 lt 1 lc rgb "blue" lw 3
set style line 4 lt 1 lc rgb "red" lw 3

set style rect fc lt -1 fs solid 0.25 noborder

#4    with lines lt 1 title "y = 4, -2 <= x <= 2"

plot  "../files/q_func_aligned_E1.csv" using 2:8 title 'p-values sup Q0 = log (1 + D(X,Y) - V(X))' with lines ls 3, \
    0.001 with lines lt 4

