set terminal svg size 1600,1300 font "Arial,14" dashed enhanced 

set output "hgt-com-timing-raxml-75-regular-hg.svg"

set xrange [0:3600]
set yrange [0:]

#set logscale x 2
#set logscale y 2

set title "Complete horizontal gene transfer relative frequency"
set datafile missing "-"
set xtics 1000 out nomirror #rotate by -90 font ",8" offset -0.8,0
set mxtics 5

set ytics out nomirror
set mytics 5

#set key noenhanced
set datafile sep ','


# First plot using linespoints
#:(1.0) smooth csplines

set style data linespoints
#plot "/root/devel/proc_hom/db/exports/hgt-com/timing/csv/hgt-com-timing-raxml-75-regular-all-med-250.csv" using 1:($2) title 'TreePL', \
 #     "/root/devel/proc_hom/db/exports/hgt-com/timing/csv/hgt-com-timing-raxml-75-regular-all-med-250.csv" using 1:($3) title 'B.E.A.S.T.'

set style line 1 lw 2 lc rgb 'red' 
set style line 2 lc rgb 'red' pt 7 ps .6  # circle

set style line 3 lw 2 lc rgb 'blue'  
set style line 4 lc rgb 'blue' pt 9  ps .6  # triangle


#plot "<echo '1 2'"   with points ls 1, \
 #    "<echo '2 1'"   with points ls 2, \
  #   "<echo '3 1.5'" with points ls 3

plot "/root/devel/proc_hom/db/exports/hgt-com/timing/csv/hgt-com-timing-raxml-75-regular-all-med-250.csv" using 1:($2):(1.0) smooth csplines ls 1 title 'TreePL', \
     "/root/devel/proc_hom/db/exports/hgt-com/timing/csv/hgt-com-timing-raxml-75-regular-all-med-250.csv" using 1:($3):(1.0) smooth csplines ls 3 title 'B.E.A.S.T.', \
     "/root/devel/proc_hom/db/exports/hgt-com/timing/csv/hgt-com-timing-raxml-75-regular-all-med-250.csv" using 1:($2) with points ls 2 title "", \
     "/root/devel/proc_hom/db/exports/hgt-com/timing/csv/hgt-com-timing-raxml-75-regular-all-med-250.csv" using 1:($3) with points ls 4 title "" \

#set ytics out nomirror

#set xtics min,(max-min)/10,max rotate by 90 out offset 0,-2.0 nomirror



#set xlabel "Destination Branch Time Distribution (Million years) - kernel density" offset 0,-1.0
#set ylabel "Density"





