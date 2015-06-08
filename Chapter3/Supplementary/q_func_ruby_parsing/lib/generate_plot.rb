require 'erb'


windows = ["5","10","20"]
win = ""

middles = [2,5,10]
middle = 0

f_names = ["Q0","Q1","Q2","Q3","Q4"]
f_name = ""

y_ranges = [[-1,1,0.2],
           [-0.05,0.25,0.2],
           [-0.07,0.07,0.05],
           [-0.03,0.2,0.15],
           [-0.05,0.55,0.45],
]
y_range_min = 0
y_range_max = 0
y_label = 0

f_indexes = [6,7,8,9,10]
f_idx = 0

f_titles = [
  "log (1 + D(X,Y) - V(X))",
  "D(X,Y) - V(X)",
  "D(X,Y) - V(Y)",
  "2*D(X,Y) - V(X) - V(Y)",
  "D(X,Y)"
]
f_title = ""
====================================================================
set terminal postscript eps noenhanced defaultplex \
   leveldefault color colortext \
   dashed dashlength 3.0 linewidth 1.0 butt \
   palfuncparam 2000,0.003 \
   "Helvetica" 16
set output "./q_func_hpv_adn_E6.eps"

#
set size 1,0.75
set size ratio 0.5
set lmargin 3
set bmargin 3
set rmargin 3
set tmargin 3

#
set datafile separator ","
#set xrange [0:2060]
#set yrange [-1:1]
set y2range [0:1]
set y2tics border




set style line 1 bgnd
set style line 2 lt rgb "cyan"
set style rect fc lt -1 fs solid 0.25 noborder

set style line 3 lt 1 lc rgb "black" lw 3
set style line 4 lt 1 lc rgb "red" lw 3
set style line 5 lt 1 lc rgb "green" lw 3
#set style line 6 lt 1 lc rgb "dark-blue" lw 3
set style line 6 lt 1 lc rgb "blue" lw 3

set style line 8 lt 3 lc rgb "black" lw 3
#vertical delimiter
set parametric
const=386
set trange [0:1]
#
plot  "./q_func_hpv_adn_E6.csv" using 2:9 title 'Q0' with lines ls 3 \
      ,"./q_func_hpv_adn_E6.csv" using 2:4 axes x1y2 title 'dXY inv_' with lines ls 4 \
      ,"./q_func_hpv_adn_E6.csv" using 2:6 axes x1y2 title 'vX inv' with lines ls 5 \
      ,"./q_func_hpv_adn_E6.csv" using 2:8 axes x1y2 title 'vY inv' with lines ls 6

======================================================================
template = ERB.new <<END
#
#
set terminal postscript eps noenhanced defaultplex \
   leveldefault color colortext \
   dashed dashlength 3.0 linewidth 1.0 butt \
   palfuncparam 2000,0.003 \
   "Helvetica" 16
set output "../eps_s/neisseria_<%= win %>_<%= f_name %>.eps"

#
set size 1,0.75
set size ratio 0.5
set lmargin 2
set bmargin 1
set rmargin 0
set tmargin 0

#
set datafile separator ","
set xrange [0:2060]
set yrange [<%= y_range_min %>:<%= y_range_max %>]
set style line 1 bgnd
set style line 2 lt rgb "cyan"
set style rect fc lt -1 fs solid 0.25 noborder

#
set obj rect from 423, -1 to 437,1
set label at 423-10, <%= y_label %> "L1" front font "Helvetica,12"

set obj rect from 516, -1 to 536,1
set label at 516-10, <%= y_label %> "L2" front font "Helvetica,12"

set obj rect from 645, -1 to 761,1
set label at 645+30, <%= y_label %> "L3" front font "Helvetica,12"

set obj rect from 864, -1 to 902,1
set label at 864-5, <%= y_label %> "L4" front font "Helvetica,12"

set obj rect from 1023, -1 to 1172,1
set label at 1023+40, <%= y_label %> "L5" front font "Helvetica,12"

set obj rect from 1260, -1 to 1292,1
set label at 1260-5, <%= y_label %> "L6" front font "Helvetica,12"

set obj rect from 1380, -1 to 1454,1
set label at 1380+15, <%= y_label %> "L7" front font "Helvetica,12"

set obj rect from 1557, -1 to 1586,1
set label at 1557-5, <%= y_label %> "L8" front font "Helvetica,12"

set obj rect from 1707, -1 to 1775,1
set label at 1707+10, <%= y_label %> "L9" front font "Helvetica,12"

set obj rect from 1845, -1 to 1925,1
set label at 1845+5, <%= y_label %> "L10" front font "Helvetica,12"

set obj rect from 2013, -1 to 2033,1
set label at 2013-30, <%= y_label %> "L11" front font "Helvetica,12"

set obj rect from 387,-1 to 389,1 fs solid 0.10
set obj rect from 471,-1 to 479,1 fs solid 0.10
set obj rect from 588,-1 to 599,1 fs solid 0.10
set obj rect from 807,-1 to 818,1 fs solid 0.10
set obj rect from 960,-1 to 974,1 fs solid 0.10
set obj rect from 1215,-1 to 1223,1 fs solid 0.10
set obj rect from 1332,-1 to 1343,1 fs solid 0.10
set obj rect from 1497,-1 to 1502,1 fs solid 0.10
set obj rect from 1659,-1 to 1661,1 fs solid 0.10
set obj rect from 1812,-1 to 1814,1 fs solid 0.10
set obj rect from 1959,-1 to 1976,1 fs solid 0.10
#
set style line 3 lt 1 lc rgb "dark-blue" lw 3
set style line 8 lt 3 lc rgb "black" lw 3
#vertical delimiter
set parametric
const=386
set trange [0:1]
#
plot  "../files/q_func_neisseria_<%= win %>.csv" using ($2+<%= middle %>):<%= f_idx %> title '<%= f_name %> = <%= f_title %>' with lines ls 3, \
const,t notitle with lines ls 8
#
END

(0..2).each {|win_idx|
  win = windows[win_idx]
  middle = middles[win_idx]

  (0..4).each { |name_idx|
    f_name = f_names[name_idx]
    f_idx = f_indexes[name_idx]
    f_title = f_titles[name_idx]
    y_range_min= y_ranges[name_idx][0]
    y_range_max= y_ranges[name_idx][1]
    y_label = y_ranges[name_idx][2]

    #puts "win: #{win}, middle: #{middle}, f_name: #{f_name}, f_idx: #{f_idx}, f_title: #{f_title}"
    t= template.result(binding)
    #puts t

    f = File.new("../gnu_plot/ruby_neisseria.plt", "w")
     f.puts t

    f.close


    #puts `gnuplot -persist ../gnu_plot/ruby_neisseria.plt`
    puts `gnuplot ../gnu_plot/ruby_neisseria.plt`
    filename = "neisseria_#{win}_#{f_name}"
    cmd = "../gnu_plot2/eps2png -f ../eps_s/#{filename}.eps"
    puts `#{cmd}`

  }
  
}

#copy results to article folder
 puts `pwd`
 puts `rm -rf /home/dunarel_b/PROJETS/article_conf_ifcs_2009_v3/eps_s/*`
 puts `cp -r /home/dunarel_b/PROJETS/q_func_jruby_ba/eps_s/* /home/dunarel_b/PROJETS/article_conf_ifcs_2009_v3/eps_s/`
 