set terminal svg size 1600,1300 font "Arial,14" dashed enhanced 

set output "hgt-par-timing-raxml-75-regular-350-hg.svg"

set xrange [0:3500]
set yrange [-0.01:0.7]

#set logscale x 2
#set logscale y 2

set title "Partial horizontal gene transfer relative frequency - Bins of 350 My"
set datafile missing "-"
set xtics 500 out nomirror #rotate by -90 font ",8" offset -0.8,0
set mxtics 10

set ytics out nomirror
set mytics 5

#set key noenhanced
set datafile sep ','


# First plot using linespoints
#:(1.0) smooth csplines

set style data linespoints
#plot "/root/devel/proc_hom/db/exports/hgt-par/timing/csv/hgt-par-timing-raxml-75-regular-all-med-350.csv" using 1:($2) title 'TreePL', \
 #     "/root/devel/proc_hom/db/exports/hgt-par/timing/csv/hgt-par-timing-raxml-75-regular-all-med-350.csv" using 1:($3) title 'B.E.A.S.T.'

set style line 1 lw 2 lc rgb 'red' 
set style line 2 lc rgb 'red' pt 7 ps 0.7  # circle

set style line 3 lw 2 lc rgb 'blue'  
set style line 4 lc rgb 'blue' pt 9  ps 0.7  # triangle


#plot "<echo '1 2'"   with points ls 1, \
 #    "<echo '2 1'"   with points ls 2, \
  #   "<echo '3 1.5'" with points ls 3
  

#sw(x,S)=1/(x*x*S)
#plot "/root/devel/proc_hom/db/exports/hgt-par/timing/csv/hgt-par-timing-raxml-75-regular-all-med-350.csv" using 1:($2):(sw($2,100)) smooth csplines ls 1 title 'TreePL', \

plot "/root/devel/proc_hom/db/exports/hgt-par/timing/csv/hgt-par-timing-raxml-75-regular-all-med-350.csv" using 1:($2):(1.0) smooth acsplines ls 1 title 'TreePL', \
       "/root/devel/proc_hom/db/exports/hgt-par/timing/csv/hgt-par-timing-raxml-75-regular-all-med-350.csv" using 1:($2) with points ls 2 title "", \
       "/root/devel/proc_hom/db/exports/hgt-par/timing/csv/hgt-par-timing-raxml-75-regular-all-med-350.csv" using 1:($3):(1.0) smooth acsplines ls 3 title 'B.E.A.S.T.', \
       "/root/devel/proc_hom/db/exports/hgt-par/timing/csv/hgt-par-timing-raxml-75-regular-all-med-350.csv" using 1:($3) with points ls 4 title "" \

#set ytics out nomirror

#set xtics min,(max-min)/10,max rotate by 90 out offset 0,-2.0 nomirror



#set xlabel "Destination Branch Time Distribution (Million years) - kernel density" offset 0,-1.0
#set ylabel "Density"
