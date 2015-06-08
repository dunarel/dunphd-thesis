#
reset

set datafile separator "," 
set xrange [0:2033]
#set yrange [-0.1:0.2]
set style line 1 bgnd
set style line 2 lt rgb "cyan" 

set style rect fc lt -1 fs solid 0.15 noborder
set obj rect from 423, -1 to 437,1
set obj rect from 516, -1 to 536,1
set obj rect from 645, -1 to 761,1
set obj rect from 864, -1 to 902,1
set obj rect from 645, -1 to 761,1
set obj rect from 1023, -1 to 1172,1
set obj rect from 1260, -1 to 1292,1
set obj rect from 1380, -1 to 1454,1
set obj rect from 1557, -1 to 1586,1
set obj rect from 1707, -1 to 1775,1
set obj rect from 1845, -1 to 1925,1
set obj rect from 2013, -1 to 2033,1


set style line 3 lt rgb "blue" lw 1
plot  "../files/q_func_neisseria_5.csv" using ($2+2):6 title 'Q0 = log (1 + D(X,Y) - V(X))' with lines ls 3

#set terminal postscript
#set output "| ps2pdf - neisseria.pdf"

set term png
set output "neisseria_5.png"
replot
set term x11

set term postscript
#set output "| ps2pdf - neisseria.pdf"
set output "neisseria.ps"
replot
set term x11

