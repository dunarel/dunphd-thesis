set terminal pngcairo size 250,1000 font "Arial,22" dashed enhanced 

set output "family-rel-raxml-75-regular-hg-dst-b.png"

set size 1.00, 1.0
set origin 0.015, 0.00 

set bmargin at screen 0.32
set tmargin at screen 0.92

set lmargin at screen 0.45
set rmargin at screen 0.98



set title "(b)" font "Arial,28" 
#set ylabel "HGT source by 100 comparisons and 100 genes" font "Arial,28" 


set style fill solid border -1
set style line 1 lt 3 lc rgb "black" lw 2

#
set style line 2 lt 1 lc rgb "black" lw 0
set style line 3 lt 1 lc rgb "white" lw 2
set style line 4 lt 1 lc rgb "gray20" lw 1
set style line 5 lt 1 lc rgb "gray80" lw 1

set xrange [0.5:2.5]
#set xtics  0 nomirror right rotate by 80 offset 0,-12.5
set xtics out nomirror rotate by 45 right 1

set xtics add ("Nanoarchaeota" 1) 
set xtics add ("Other Archaea" 2) 



  set yrange [0:55] 
  set ytics 10 out nomirror
  set mytics 5
  #unset ytics

  #set y2range [0:55] 
  #set y2tics 10 out nomirror
  #set my2tics 5


#set style fill transparent solid 0.3
#set style fill transparency pattern 5
set object 1 rect from (1-0.3),0             to (1+0.3),11.720698 fc rgb "#5ef1f2" fillstyle solid 1 lw 2 
set object 2 rect from (1-0.3),(11.720698) to (1+0.3),(28.387365) fc rgb "#5ef1f2" fillstyle solid 0.5 lw 2 
# 
set object 3 rect from (2-0.3),0             to (2+0.3),31.506318 fc rgb "#00998f" fillstyle solid 1 lw 2 
set object 4 rect from (2-0.3),(31.506318) to (2+0.3),(52.472984) fc rgb "#00998f" fillstyle solid 0.5 lw 2 
# 


plot 400  with lines ls 2  title ""

