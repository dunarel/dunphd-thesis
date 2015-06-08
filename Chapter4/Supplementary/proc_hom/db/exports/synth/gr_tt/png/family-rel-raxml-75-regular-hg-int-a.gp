set terminal pngcairo size 1600,1000 font "Arial,22" dashed enhanced 

set output "family-rel-raxml-75-regular-hg-int-a.png"

set size 1.00, 1.0
set origin 0.015, 0.00 

set bmargin at screen 0.32
set tmargin at screen 0.92

set lmargin at screen 0.07
set rmargin at screen 0.99



set title "(a)" font "Arial,28" 
#set ylabel "HGT source by 100 comparisons and 100 genes" font "Arial,28" 


set style fill solid border -1
set style line 1 lt 3 lc rgb "black" lw 2

#
set style line 2 lt 1 lc rgb "black" lw 0
set style line 3 lt 1 lc rgb "white" lw 2
set style line 4 lt 1 lc rgb "gray20" lw 1
set style line 5 lt 1 lc rgb "gray80" lw 1

set xrange [0.5:21.5]
#set xtics  0 nomirror right rotate by 80 offset 0,-12.5
set xtics out nomirror rotate by 45 right 1

set xtics add ("Euryarchaeota" 1) 
set xtics add ("Crenarchaeota" 2) 
set xtics add ("Spirochaetes" 3) 
set xtics add ("Planctomycetes" 4) 
set xtics add ("Actinobacteria" 5) 
set xtics add ("Thermotogae" 6) 
set xtics add ("Chloroflexi" 7) 
set xtics add ("Aquificae" 8) 
set xtics add ("Bacteroidetes/Chlorobi" 9) 
set xtics add ("Chlamydiae/Verrucomicrobia" 10) 
set xtics add ("Fusobacteria" 11) 
set xtics add ("Deinococcus-Thermus" 12) 
set xtics add ("Firmicutes" 13) 
set xtics add ("Epsilonproteobacteria" 14) 
set xtics add ("Deltaproteobacteria" 15) 
set xtics add ("Betaproteobacteria" 16) 
set xtics add ("Alphaproteobacteria" 17) 
set xtics add ("Gammaproteobacteria" 18) 
set xtics add ("Cyanobacteria" 19) 
set xtics add ("Acidobacteria" 20) 
set xtics add ("Other Bacteria" 21) 


 set yrange [0:22] 
 set ytics 10 out nomirror
 set mytics 


#set style fill transparent solid 0.3
#set style fill transparency pattern 5
set object 1 rect from (1-0.3),0             to (1+0.3),1.219512 fc rgb "#ffa405" fillstyle solid 1 lw 2 
set object 2 rect from (1-0.3),(1.219512) to (1+0.3),(3.170732) fc rgb "#ffa405" fillstyle solid 0.5 lw 2 
# 
set object 3 rect from (2-0.3),0             to (2+0.3),0.000000 fc rgb "#808080" fillstyle solid 1 lw 2 
set object 4 rect from (2-0.3),(0.000000) to (2+0.3),(0.000000) fc rgb "#808080" fillstyle solid 0.5 lw 2 
# 
set object 5 rect from (3-0.3),0             to (3+0.3),1.980198 fc rgb "#990000" fillstyle solid 1 lw 2 
set object 6 rect from (3-0.3),(1.980198) to (3+0.3),(2.640264) fc rgb "#990000" fillstyle solid 0.5 lw 2 
# 
set object 7 rect from (4-0.3),0             to (4+0.3),0.000000 fc rgb "#740aff" fillstyle solid 1 lw 2 
set object 8 rect from (4-0.3),(0.000000) to (4+0.3),(0.000000) fc rgb "#740aff" fillstyle solid 0.5 lw 2 
# 
set object 9 rect from (5-0.3),0             to (5+0.3),1.949861 fc rgb "#00750c" fillstyle solid 1 lw 2 
set object 10 rect from (5-0.3),(1.949861) to (5+0.3),(3.806871) fc rgb "#00750c" fillstyle solid 0.5 lw 2 
# 
set object 11 rect from (6-0.3),0             to (6+0.3),0.000000 fc rgb "#fffc03" fillstyle solid 1 lw 2 
set object 12 rect from (6-0.3),(0.000000) to (6+0.3),(0.000000) fc rgb "#fffc03" fillstyle solid 0.5 lw 2 
# 
set object 13 rect from (7-0.3),0             to (7+0.3),0.000000 fc rgb "#ffcc99" fillstyle solid 1 lw 2 
set object 14 rect from (7-0.3),(0.000000) to (7+0.3),(0.000000) fc rgb "#ffcc99" fillstyle solid 0.5 lw 2 
# 
set object 15 rect from (8-0.3),0             to (8+0.3),0.000000 fc rgb "#4c005c" fillstyle solid 1 lw 2 
set object 16 rect from (8-0.3),(0.000000) to (8+0.3),(0.000000) fc rgb "#4c005c" fillstyle solid 0.5 lw 2 
# 
set object 17 rect from (9-0.3),0             to (9+0.3),0.984252 fc rgb "#191919" fillstyle solid 1 lw 2 
set object 18 rect from (9-0.3),(0.984252) to (9+0.3),(3.937008) fc rgb "#191919" fillstyle solid 0.5 lw 2 
# 
set object 19 rect from (10-0.3),0             to (10+0.3),0.000000 fc rgb "#2bce48" fillstyle solid 1 lw 2 
set object 20 rect from (10-0.3),(0.000000) to (10+0.3),(0.000000) fc rgb "#2bce48" fillstyle solid 0.5 lw 2 
# 
set object 21 rect from (11-0.3),0             to (11+0.3),0.000000 fc rgb "#426600" fillstyle solid 1 lw 2 
set object 22 rect from (11-0.3),(0.000000) to (11+0.3),(0.000000) fc rgb "#426600" fillstyle solid 0.5 lw 2 
# 
set object 23 rect from (12-0.3),0             to (12+0.3),0.000000 fc rgb "#9dcc00" fillstyle solid 1 lw 2 
set object 24 rect from (12-0.3),(0.000000) to (12+0.3),(0.000000) fc rgb "#9dcc00" fillstyle solid 0.5 lw 2 
# 
set object 25 rect from (13-0.3),0             to (13+0.3),5.426975 fc rgb "#ffa8bb" fillstyle solid 1 lw 2 
set object 26 rect from (13-0.3),(5.426975) to (13+0.3),(15.043895) fc rgb "#ffa8bb" fillstyle solid 0.5 lw 2 
# 
set object 27 rect from (14-0.3),0             to (14+0.3),0.699301 fc rgb "#003380" fillstyle solid 1 lw 2 
set object 28 rect from (14-0.3),(0.699301) to (14+0.3),(1.048951) fc rgb "#003380" fillstyle solid 0.5 lw 2 
# 
set object 29 rect from (15-0.3),0             to (15+0.3),0.000000 fc rgb "#c20088" fillstyle solid 1 lw 2 
set object 30 rect from (15-0.3),(0.000000) to (15+0.3),(0.000000) fc rgb "#c20088" fillstyle solid 0.5 lw 2 
# 
set object 31 rect from (16-0.3),0             to (16+0.3),1.212620 fc rgb "#875692" fillstyle solid 1 lw 2 
set object 32 rect from (16-0.3),(1.212620) to (16+0.3),(4.454111) fc rgb "#875692" fillstyle solid 0.5 lw 2 
# 
set object 33 rect from (17-0.3),0             to (17+0.3),3.559784 fc rgb "#993f00" fillstyle solid 1 lw 2 
set object 34 rect from (17-0.3),(3.559784) to (17+0.3),(12.744227) fc rgb "#993f00" fillstyle solid 0.5 lw 2 
# 
set object 35 rect from (18-0.3),0             to (18+0.3),0.469263 fc rgb "#ff0010" fillstyle solid 1 lw 2 
set object 36 rect from (18-0.3),(0.469263) to (18+0.3),(0.656969) fc rgb "#ff0010" fillstyle solid 0.5 lw 2 
# 
set object 37 rect from (19-0.3),0             to (19+0.3),2.873563 fc rgb "#8f7c00" fillstyle solid 1 lw 2 
set object 38 rect from (19-0.3),(2.873563) to (19+0.3),(4.885057) fc rgb "#8f7c00" fillstyle solid 0.5 lw 2 
# 
set object 39 rect from (20-0.3),0             to (20+0.3),0.000000 fc rgb "#f0a3ff" fillstyle solid 1 lw 2 
set object 40 rect from (20-0.3),(0.000000) to (20+0.3),(0.000000) fc rgb "#f0a3ff" fillstyle solid 0.5 lw 2 
# 
set object 41 rect from (21-0.3),0             to (21+0.3),0.294985 fc rgb "#e0ff66" fillstyle solid 1 lw 2 
set object 42 rect from (21-0.3),(0.294985) to (21+0.3),(0.294985) fc rgb "#e0ff66" fillstyle solid 0.5 lw 2 
# 


plot 400  with lines ls 2  title ""

