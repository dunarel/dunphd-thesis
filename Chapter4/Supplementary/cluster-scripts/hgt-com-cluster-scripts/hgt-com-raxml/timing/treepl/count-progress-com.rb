#!/usr/bin/env ruby

require 'rubygems'
require 'rainbow'

 #res_type = "results"
 res_type = "work"

puts "starting ..."

 genes =  `cat values.txt | awk '{print $2}'`
 genes = genes.split "\n"

   
  idx = 0
  genes.each { |gn|

   idx += 1
 
  wins_nb =  "1"
    calcs_nb = `ls #{res_type}/#{gn}/dated_tree.nwk | wc | awk '{print $1}'`
    calcs_nb = calcs_nb.chomp()
   
    zeros_nb = `ls -s #{res_type}/#{gn}/dated_tree.nwk | sed -n '/^0/p' |wc |  awk '{print $1}'`
    zeros_nb = zeros_nb.chomp()

    gn_color = :default
    gn_color = :green if wins_nb == calcs_nb
     
    zr_color = :default
    zr_color = :red if zeros_nb.to_i > 0 

    #puts sprintf("%2d - %s",index,task.name.bright).color(color)
   
    #printf("%2d - %s\n",index,task.name.bright)
    printf("%3d:  gene: %s, wins_nb: #{wins_nb} , calcs_nb: #{calcs_nb}, zeros_nb: %s \n", idx, gn.color(gn_color), zeros_nb.color(zr_color))

  
 }

  
 #puts genes.inspect
