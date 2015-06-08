reset
n=50	#number of intervals
max=3000.	#max value
min=0.	#min value
width=(max-min)/n	#interval width
#function used to map a value to the intervals
hist(x,width)=width*floor(x/width)+width/1.0
set term svg	#output terminal and file
set output "histogram.svg"
set xrange [min:max]
set yrange [0:]
set y2range [0:]
#to put an empty boundary around the
#data inside an autoscaled graph.
#set offset graph 0.05,0.05,0.05,0.0
set xtics min,(max-min)/10,max rotate by 90 out offset 0,-2.0 nomirror

#set boxwidth width*0.9
set style fill solid 0.5	#fillstyle
set ytics out nomirror
set y2tics out nomirror

set xlabel "Destination Branch Time Distribution (Million years)" offset 0,-1.0
set ylabel "Frequency"
set y2label "K density"
#count and plot

plot "hgt-com-family-rel-raxml-75-all-tm.csv" using (hist($1,width)):(1.0) smooth freq w boxes lc rgb"blue" notitle axis x1y1, \
     "hgt-com-family-rel-raxml-75-all-tm.csv" u ($1):(1.0/362.0):(60.0) smooth kdensity with lines lc rgb"red" notitle axis x1y2

#plot "hgt-com-family-raxml-75-all-tm.csv" using ($1):(1.0) with points lc rgb"blue" notitle axis x1y1











#set terminal svg rounded size 450,360
#set output 'sombrero.svg'



