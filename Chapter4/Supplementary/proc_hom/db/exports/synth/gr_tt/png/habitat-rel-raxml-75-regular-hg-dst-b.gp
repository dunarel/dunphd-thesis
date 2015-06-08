set terminal pngcairo size 320,1000 font "Arial,22" dashed enhanced 

set output "habitat-rel-raxml-75-regular-hg-dst-b.png"

set size 1.00, 1.0
set origin 0.015, 0.00 

set bmargin at screen 0.23
set tmargin at screen 0.97

set lmargin at screen 0.45
set rmargin at screen 0.85



set title "" font "Arial,28" 
#set ylabel "HGT source by 100 comparisons and 100 genes" font "Arial,28" 


set style fill solid border -1
set style line 1 lt 3 lc rgb "black" lw 2

#
set style line 2 lt 1 lc rgb "black" lw 0
set style line 3 lt 1 lc rgb "white" lw 2
set style line 4 lt 1 lc rgb "gray20" lw 1
set style line 5 lt 1 lc rgb "gray80" lw 1

set xrange [0.5:0.5]
#set xtics  0 nomirror right rotate by 80 offset 0,-12.5
set xtics out nomirror rotate by 45 right 1




  set yrange [0:10] 
  set ytics 10 out nomirror
  set mytics 5
  #unset ytics

  #set y2range [0:10] 
  #set y2tics 10 out nomirror
  #set my2tics 5


#set style fill transparent solid 0.3
#set style fill transparency pattern 5


plot 400  with lines ls 2  title ""

