set term pngcairo size 1600,1300 font "Arial,32" dashed enhanced 
set output "hgt-com-timing-raxml-75-regular-kn.png"
min=0
max=3500

set xrange [min:max]
set yrange [0:0.002]
set xtics min,(max-min)/10,max rotate by 90 out offset 0,-2.0 nomirror

set ytics out nomirror

set xlabel "Time Distribution (Million years) - kernel density" offset 0,-1.0
set ylabel "Density"

plot "/root/devel/proc_hom/db/exports/hgt-com/timing/csv/hgt-com-timing-raxml-75-regular-treepl-med.csv" u ($1):(1.0/362.0):(0.0) smooth kdensity with lines lw 3 lc rgb"red" t "TreePL" axis x1y1, \
     "/root/devel/proc_hom/db/exports/hgt-com/timing/csv/hgt-com-timing-raxml-75-regular-beast-med.csv" u ($1):(1.0/362.0):(0.0) smooth kdensity with lines lw 3 lc rgb"black" t "B.E.A.S.T" axis x1y1, \
     "/root/devel/proc_hom/db/exports/hgt-com/timing/csv/hgt-com-timing-raxml-75-regular-beast-hpd5.csv" u ($1):(1.0/362.0):(0.0) smooth kdensity with lines lw 3 lc rgb"blue" t "B.E.A.S.T HPD 5%" axis x1y1, \
     "/root/devel/proc_hom/db/exports/hgt-com/timing/csv/hgt-com-timing-raxml-75-regular-beast-hpd95.csv" u ($1):(1.0/362.0):(0.0) smooth kdensity with lines lw 3 lc rgb"violet" t "B.E.A.S.T HPD 95%" axis x1y1
