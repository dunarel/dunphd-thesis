set term postscript eps color
set output 'x.eps'
set style fill pattern 2
plot sin(x) w filledcu x1
set term x11