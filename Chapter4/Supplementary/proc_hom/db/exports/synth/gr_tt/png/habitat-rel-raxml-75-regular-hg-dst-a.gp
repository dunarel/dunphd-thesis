set terminal pngcairo size 900,1000 font "Arial,22" dashed enhanced 

set output "habitat-rel-raxml-75-regular-hg-dst-a.png"

set size 1.00, 1.0
set origin 0.015, 0.00 

set bmargin at screen 0.23
set tmargin at screen 0.97

set lmargin at screen 0.17
set rmargin at screen 0.98



set title "" font "Arial,28" 
#set ylabel "HGT source by 100 comparisons and 100 genes" font "Arial,28" 


set style fill solid border -1
set style line 1 lt 3 lc rgb "black" lw 2

#
set style line 2 lt 1 lc rgb "black" lw 0
set style line 3 lt 1 lc rgb "white" lw 2
set style line 4 lt 1 lc rgb "gray20" lw 1
set style line 5 lt 1 lc rgb "gray80" lw 1

set xrange [0.5:8.5]
#set xtics  0 nomirror right rotate by 80 offset 0,-12.5
set xtics out nomirror rotate by 45 right 1

set xtics add ("Human Respiratory" 1) 
set xtics add ("Human Others" 2) 
set xtics add ("Plant" 3) 
set xtics add ("Animal" 4) 
set xtics add ("Soil" 5) 
set xtics add ("Marine" 6) 
set xtics add ("Fresh water" 7) 
set xtics add ("Extreme" 8) 


 set yrange [0:10] 
 set ytics 10 out nomirror
 set mytics 


#set style fill transparent solid 0.3
#set style fill transparency pattern 5
set object 1 rect from (1-0.2),0             to (1+0.2),0.751096 fc rgb "blue" fillstyle solid 1 lw 2 
set object 2 rect from (1-0.2),(0.751096) to (1+0.2),(1.427399) fc rgb "blue" fillstyle solid 0.5 lw 2 
# 
set object 3 rect from (2-0.2),0             to (2+0.2),2.783684 fc rgb "blue" fillstyle solid 1 lw 2 
set object 4 rect from (2-0.2),(2.783684) to (2+0.2),(9.299825) fc rgb "blue" fillstyle solid 0.5 lw 2 
# 
set object 5 rect from (3-0.2),0             to (3+0.2),2.689390 fc rgb "blue" fillstyle solid 1 lw 2 
set object 6 rect from (3-0.2),(2.689390) to (3+0.2),(8.395521) fc rgb "blue" fillstyle solid 0.5 lw 2 
# 
set object 7 rect from (4-0.2),0             to (4+0.2),2.674544 fc rgb "blue" fillstyle solid 1 lw 2 
set object 8 rect from (4-0.2),(2.674544) to (4+0.2),(6.312843) fc rgb "blue" fillstyle solid 0.5 lw 2 
# 
set object 9 rect from (5-0.2),0             to (5+0.2),2.149364 fc rgb "blue" fillstyle solid 1 lw 2 
set object 10 rect from (5-0.2),(2.149364) to (5+0.2),(6.271879) fc rgb "blue" fillstyle solid 0.5 lw 2 
# 
set object 11 rect from (6-0.2),0             to (6+0.2),1.556232 fc rgb "blue" fillstyle solid 1 lw 2 
set object 12 rect from (6-0.2),(1.556232) to (6+0.2),(4.435846) fc rgb "blue" fillstyle solid 0.5 lw 2 
# 
set object 13 rect from (7-0.2),0             to (7+0.2),1.734379 fc rgb "blue" fillstyle solid 1 lw 2 
set object 14 rect from (7-0.2),(1.734379) to (7+0.2),(4.592080) fc rgb "blue" fillstyle solid 0.5 lw 2 
# 
set object 15 rect from (8-0.2),0             to (8+0.2),1.122784 fc rgb "blue" fillstyle solid 1 lw 2 
set object 16 rect from (8-0.2),(1.122784) to (8+0.2),(4.177785) fc rgb "blue" fillstyle solid 0.5 lw 2 
# 


plot 400  with lines ls 2  title ""

