set terminal emf size 1600,1300 font "Arial,14" dashed enhanced 

set output "hgt-tot-habitat-rel-raxml-75-regular-hm.emf"

set multiplot #title "Demo of placing multiple plots (2D and 3D)\nwith explicit alignment of plot borders"

set style fill solid border -1
set style line 1 lt 3 lc rgb "black" lw 1
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
set bmargin at screen 0.10
set tmargin at screen 0.68

unset key

#no divisions of scale
set tic scale 0


set palette defined ( 0  "#00008B", 0.01 "blue", 0.1 "#007FFF", 0.3 "#FFF68F", 1 "#FF3030" )

set colorbox user vertical origin 0.84 , 0.12 size .025,0.55


#set cbrange [0.01:2]
set cbrange [0.01:10.0]



set logscale cb 2.71828182846 
set format cb '%3.2f'
set cbtics font ",22" offset +3.2, 0

set cblabel "Partial HGTs, 75 \% confidence " offset +4.5 ,+2.2 font ",24"

set xrange [-0.5:7.5]
set x2range [-0.5:7.5]
set yrange [-0.5:7.5] reverse 


set x2tic rotate by 90 font ",22" 
set ytic font ",22"
set cbtics font ",18" offset -0.5,0


#
#set grid y

set format x ""
set format x2 ""

set label 5 "a" font "Delicious-Bold,28"  at -3,-3 tc ls 1


set view map


set datafile separator "\t"

plot '../dat/hgt-tot-habitat-rel-raxml-75-regular-hm.dat' using 3:1:5:x2ticlabel(4):yticlabel(2) with image


unset border



#
############################ right
#
set lmargin at screen 0.76
set rmargin at screen 0.82
set bmargin at screen 0.09
set tmargin at screen 0.68


set xrange [-15:115]
set yrange [-0.5:7.5] reverse

set format y ""
set format x2 ""

unset label 5
set label 5 "b" font "Delicious-Bold,28"  at 20,-3 tc ls 1

set label 1 "0%" font "Delicious-Bold,18"  at -20,-0.9 tc ls 1
set label 2 "100 %" font "Delicious-Bold,18" at 70,-0.9 tc ls 1
set arrow 1 from graph 0, 1  to graph  1 ,1  as 4


set datafile separator "\t"



plot '../dat/hgt-tot-habitat-rel-raxml-75-regular-hm.daty' using (0):($1):(100):(0) with vector nohead ls 1 , \
     '../dat/hgt-tot-habitat-rel-raxml-75-regular-hm.daty' using (0):($1-.20):(0):(.4) with vector nohead ls 2, \
     '../dat/hgt-tot-habitat-rel-raxml-75-regular-hm.daty' using (100):($1-.20):(0):(.4) with vector nohead ls 2

plot '../dat/hgt-tot-habitat-rel-raxml-75-regular-hm.daty' using (100*$2/100):($1):(15):(0.15) with boxxyerrorbars ls 4 fs solid
#white
plot '../dat/hgt-tot-habitat-rel-raxml-75-regular-hm.daty' using (100*$3/100):($1):(15):(0.15) with boxxyerrorbars ls 5 fs solid


################bottom 
#
# bottom
#


set lmargin at screen 0.25
set rmargin at screen 0.75
set bmargin at screen 0.01
set tmargin at screen 0.09

set yrange [-15:115] reverse
set xrange [-0.5:7.5] 

set format x ""
set format y2 ""

unset label 5
set label 5 "c" font "Delicious-Bold,28"  at -3,20 tc ls 1


set label 1 "0%" font "Delicious-Bold,18"  at -1.2,5 tc ls 1
set label 2 "100 %" font "Delicious-Bold,18" at -1.5,105 tc ls 1
set arrow 1 from -0.5,-10  to -0.5,102  as 4

set datafile separator "\t"



plot '../dat/hgt-tot-habitat-rel-raxml-75-regular-hm.datx' using ($1):(0):(0):(100) with vector nohead ls 1 , \
     '../dat/hgt-tot-habitat-rel-raxml-75-regular-hm.datx' using ($1-.20):(0):(.4):(0) with vector nohead ls 2, \
     '../dat/hgt-tot-habitat-rel-raxml-75-regular-hm.datx' using ($1-.20):(100):(.4):(0) with vector nohead ls 2


plot '../dat/hgt-tot-habitat-rel-raxml-75-regular-hm.datx' using ($1):(100*$2/100):(0.15):(15) with boxxyerrorbars ls 4 fs solid
#white
plot '../dat/hgt-tot-habitat-rel-raxml-75-regular-hm.datx' using ($1):(100*$3/100):(0.15):(15) with boxxyerrorbars ls 5 fs solid



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


set arrow 1 from  15,40 to 53,40 as 4
set arrow 2 from  58,40 to 97,40 as 4
set label 1 "Host" font ",26"  at 30, 30 tc ls 1
set label 3 "Environment" font ",26"  at 60, 30 tc ls 1


#plot outside range just to show arrows
plot -1 with lines




unset multiplot



