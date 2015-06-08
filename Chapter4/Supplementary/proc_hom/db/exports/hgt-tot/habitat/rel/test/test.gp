#set terminal pdfcairo font "Delicious,18" dashed\
#     size 20cm,22cm 
set terminal svg size 1600 1300 font "Arial,12" dashed enhanced 

set output "/root/devel/proc_hom/db/exports/hgt-com/family/rel/test.svg"

set multiplot #title "Demo of placing multiple plots (2D and 3D)\nwith explicit alignment of plot borders"

set style fill solid border -1
set style line 1 lt 3 lc rgb "black" lw 2
set style line 2 lt 1 lc rgb "black" lw 2
set style line 3 lt 1 lc rgb "white" lw 2
set style line 4 lt 1 lc rgb "gray20" lw 1
set style line 5 lt 1 lc rgb "gray80" lw 1


set style arrow 4 nohead lt 1 lc rgb "black" lw 1


#
# First plot  (large)
#
set lmargin at screen 0.25
set rmargin at screen 0.75
set bmargin at screen 0.09
set tmargin at screen 0.68



unset key

#no divisions of scale
set tic scale 0


# Color runs from white to green
set palette rgbformula 33,13,10

set colorbox user vertical origin 0.84,0.10 size .02,0.58
set cbrange [0.01:]
set logscale cb 10 
set format cb '%3.1f'
set cbtics font ",18" offset +0.5,0

set cblabel  "Complete HGTs, 75 \% confidence " offset +7 ,1 font ",18"

#unset cbtics


set xrange [-0.5:22.5]
set x2range [-0.5:22.5]
set yrange [-0.5:22.5] reverse 

set x2tic rotate by 90 font ",16" 
set ytic font ",16"

#
#set grid y

set format x ""
set format x2 ""

set label 5 "a" font "Arial-Bold,22"  at -4,-4 tc ls 1

set view map


set datafile separator "\t"

plot '/root/devel/proc_hom/db/exports/hgt-com/family/rel/hgt-com-family-rel-raxml-75-all-hm.dat' using 3:1:5:x2ticlabel(4):yticlabel(2) with image


unset border



#
############################ right
#
set lmargin at screen 0.76
set rmargin at screen 0.80
set bmargin at screen 0.09
set tmargin at screen 0.68


set xrange [-15:115]
set yrange [-0.5:22.5] reverse

set format y ""
set format x2 ""

unset label 5
set label 5 "b" font "Arial-Bold,22"  at 20,-4 tc ls 1

set label 1 "0%" font "Arial-Bold,14"  at -20,-0.9 tc ls 1
set label 2 "100 %" font "Arial-Bold,14" at 70,-0.9 tc ls 1
set arrow 1 from graph 0, 1  to graph  1 ,1  as 4


set datafile separator "\t"


plot '/root/devel/proc_hom/db/exports/hgt-com/family/rel/hgt-com-family-rel-raxml-75-all-hm.daty' using (0):($1):(100):(0) with vector nohead ls 1 , \
     '/root/devel/proc_hom/db/exports/hgt-com/family/rel/hgt-com-family-rel-raxml-75-all-hm.daty' using (0):($1-.25):(0):(.5) with vector nohead ls 2, \
     '/root/devel/proc_hom/db/exports/hgt-com/family/rel/hgt-com-family-rel-raxml-75-all-hm.daty' using (100):($1-.25):(0):(.5) with vector nohead ls 2

plot '/root/devel/proc_hom/db/exports/hgt-com/family/rel/hgt-com-family-rel-raxml-75-all-hm.daty' using (100*$2/100):($1):(16):(0.21) with boxxyerrorbars ls 4 fs solid

#white
plot '/root/devel/proc_hom/db/exports/hgt-com/family/rel/hgt-com-family-rel-raxml-75-all-hm.daty' using (100*$3/100):($1):(16):(0.21) with boxxyerrorbars ls 5 fs solid


################bottom 
#
# bottom
#

set lmargin at screen 0.25
set rmargin at screen 0.75
set bmargin at screen 0.03
set tmargin at screen 0.08



set yrange [-15:115] reverse
#set x2tics 0,100
set xrange [-0.5:22.5] 

set format x ""
set format y2 ""

unset label 5
set label 5 "c" font "Arial-Bold,22"  at -4,20 tc ls 1


set label 1 "0%" font "Arial-Bold,14"  at -1.8,5 tc ls 1
set label 2 "100 %" font "Arial-Bold,14" at -2.8,105 tc ls 1
set arrow 1 from -0.5,-10  to -0.5,102  as 4

set datafile separator "\t"

# Styling
#set border linewidth 1.5
#set pointsize 1.5
#set style line 4 lc rgb '#0060ad' pt 5   # square

#set style line 2 lc rgb '#0060ad' pt 7   # circle
#set style line 3 lc rgb '#0060ad' pt 9   # triangle


plot '/root/devel/proc_hom/db/exports/hgt-com/family/rel/hgt-com-family-rel-raxml-75-all-hm.datx' using ($1):(0):(0):(100) with vector nohead ls 1 , \
     '/root/devel/proc_hom/db/exports/hgt-com/family/rel/hgt-com-family-rel-raxml-75-all-hm.datx' using ($1-.25):(0):(.5):(0) with vector nohead ls 2, \
     '/root/devel/proc_hom/db/exports/hgt-com/family/rel/hgt-com-family-rel-raxml-75-all-hm.datx' using ($1-.25):(100):(.5):(0) with vector nohead ls 2

#plot '/root/devel/proc_hom/db/exports/hgt-com/family/rel/hgt-com-family-rel-raxml-75-all-hm.datx' using ($1):(100*$2/100):(0.21) with points ls 4 
                 
#fs solid 0.0 border


plot '/root/devel/proc_hom/db/exports/hgt-com/family/rel/hgt-com-family-rel-raxml-75-all-hm.datx' using ($1):(100*$2/100):(0.21):(16) with boxxyerrorbars ls 4 fs solid
#white
plot '/root/devel/proc_hom/db/exports/hgt-com/family/rel/hgt-com-family-rel-raxml-75-all-hm.datx' using ($1):(100*$3/100):(0.21):(16) with boxxyerrorbars ls 5 fs solid




###############arrows and labels on top


set lmargin at screen 0.18
set rmargin at screen 0.75
set bmargin at screen 0.80
set tmargin at screen 0.98

unset label 5

unset arrow 1
unset label 1
unset label 2


set xrange [0:100]
set yrange [0:100] 
set tic scale 0
set format x ""
set format y ""
unset key


set arrow 1 from  12,7 to 26,7 as 4
set arrow 2 from  28,7 to 99,7 as 4

set label 1 "Archaea" font ",16"  at 14, 0 tc ls 1
set label 3 "Bacteria" font ",16"  at 55, 0 tc ls 1

set arrow 3 from  70,30 to 89,30 as 4
set label 4 "Proteobacteria" font ",16"  at 70, 22 tc ls 1




#plot outside range just to show arrows
plot -1 with lines


unset multiplot



