#
# Boxplot demo
#
set term emf size 1600,1300 font "Arial,32" dashed enhanced 
set output "hgt-par-timing-raxml-75-regular-bp.emf"

#print "*** Boxplot demo ***"

#set style fill solid 0.25 border -1
set style fill solid 0.5 

set style boxplot outliers pointtype 7
set style data boxplot
set boxwidth  0.5
set pointsize 0.5

#unset key
#set border 2
#set xtics ("A" 1, "B" 2) scale 0.0

set ylabel "Time (Million years)"

set xtics ("Time Distribution - boxplot" 1.5) scale 0.0
set xtics nomirror
set ytics nomirror
#set yrange [0:100]

plot "/root/devel/proc_hom/db/exports/hgt-par/timing/csv/hgt-par-timing-raxml-75-regular-treepl-med.csv"  using (1.0):1 title "TreePL"  fillstyle solid 0.5 lw 2 lc rgb "blue", \
     "/root/devel/proc_hom/db/exports/hgt-par/timing/csv/hgt-par-timing-raxml-75-regular-beast-med.csv"  using (2.0):1 title "B.E.A.S.T." fillstyle solid 0.5 lw 2 lc rgb "red"

