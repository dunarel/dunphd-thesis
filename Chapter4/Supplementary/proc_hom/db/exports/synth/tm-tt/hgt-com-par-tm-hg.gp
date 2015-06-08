set term svg size 1600,1300 font "Arial,32" dashed enhanced 

set output "hgt-com-par-tm-hg.svg"

set xrange [0:3500]
set yrange [-0.01:0.6]

set title "Horizontal gene transfer relative frequency"
set datafile missing "-"
set xtics 500 out nomirror #rotate by -90 font ",8" offset -0.8,0
set mxtics 4

set ytics out nomirror
set mytics 5

#set key noenhanced
set datafile sep ','

#TreePL - com
set style line 1 lt 1 lw 3 lc rgb 'red' 
set style line 2 lc rgb 'red' pt 6 ps 0.7  # circle
#BEAST  - com
set style line 3 lt 1 lw 3 lc rgb 'blue'  
set style line 4 lc rgb 'blue' pt 7  ps 0.7  # triangle
#TreePL - par
set style line 5 lt 2 lw 3 lc rgb 'red' 
set style line 6 lc rgb 'red' pt 4 ps 0.7  # circle
#BEAST  -par
set style line 7 lt 2 lw 3 lc rgb 'blue'  
set style line 8 lc rgb 'blue' pt 5  ps 0.7  # triangle


set style arrow 1 filled nohead ls 1
set style arrow 2 filled nohead ls 3
set style arrow 3 filled nohead ls 5
set style arrow 4 filled nohead ls 7

set arrow from 3100,0.572 to 3400,0.572 as 1
set arrow from 3100,0.544 to 3400,0.544 as 2
set arrow from 3100,0.515 to 3400,0.515 as 3
set arrow from 3100,0.486 to 3400,0.486 as 4

#plot "<echo '-1 -1'" lc rgb 'white' with points title '-------', \

plot "/root/devel/proc_hom/db/exports/hgt-com/timing/csv/hgt-com-timing-raxml-75-regular-all-med-250.csv" using 1:($2):(1.0) smooth acsplines ls 1 title '', \
     "/root/devel/proc_hom/db/exports/hgt-com/timing/csv/hgt-com-timing-raxml-75-regular-all-med-250.csv" using 1:($2) with points ls 2 title "TreePL    - Complete", \
     "/root/devel/proc_hom/db/exports/hgt-com/timing/csv/hgt-com-timing-raxml-75-regular-all-med-250.csv" using 1:($3):(1.0) smooth acsplines ls 3 title '', \
     "/root/devel/proc_hom/db/exports/hgt-com/timing/csv/hgt-com-timing-raxml-75-regular-all-med-250.csv" using 1:($3) with points ls 4 title "B.E.A.S.T.- Complete", \
     "/root/devel/proc_hom/db/exports/hgt-par/timing/csv/hgt-par-timing-raxml-75-regular-all-med-250.csv" using 1:($2):(1.0) smooth acsplines ls 5 title '', \
     "/root/devel/proc_hom/db/exports/hgt-par/timing/csv/hgt-par-timing-raxml-75-regular-all-med-250.csv" using 1:($2) with points ls 6 title "TreePL    - Overall", \
     "/root/devel/proc_hom/db/exports/hgt-par/timing/csv/hgt-par-timing-raxml-75-regular-all-med-250.csv" using 1:($3):(1.0) smooth acsplines ls 7 title '', \
     "/root/devel/proc_hom/db/exports/hgt-par/timing/csv/hgt-par-timing-raxml-75-regular-all-med-250.csv" using 1:($3) with points ls 8 title "B.E.A.S.T.- Overall" \
