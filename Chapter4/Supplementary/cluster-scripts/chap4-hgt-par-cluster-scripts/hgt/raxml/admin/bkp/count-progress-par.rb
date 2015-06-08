#!/usr/bin/env jruby

require 'rubygems'
require 'rainbow'
require 'yaml'

 
 class ManageResults

   def initialize()
  @config_yml = YAML.load_file('templ/config.yml')
  @exec_yml = YAML.load_file('templ/exec.yml')

     cmd =  "cat templ/values.txt | awk '{print $2}'"
     @genes = `#{cmd}`.split("\n")

  @stage = @config_yml["stage"]
  @timing_prog = @config_yml["timing_prog"]

  end

  def count_progress
   
   #res_type = "results"
   res_type = "work"

   puts "starting ..."

   genes =  `cat templ/values.txt | awk '{print $2}'`
   genes = genes.split "\n"

   #[50,25,10].each { |ws|
    [10].each { |ws|
   
    puts "---------------win_size: #{ws}----------------"

    idx = 0
    genes.each { |gn|

     idx += 1
 
     wins_nb =  `ls #{res_type}/#{gn}/#{ws} | wc | awk '{print $1}'`
     wins_nb = wins_nb.chomp()

     #`ls #{res_type}/#{gn}/#{ws}/*/dated_tree.annot | wc | awk '{print $1}'`
     #calcs_nb = calcs_nb.chomp()     
        calcs_nb = 0 
     

        cmd = "ls #{res_type}/#{gn}/#{ws}/*/gene_beast.log"; puts cmd;
        gene_beast_logs = `#{cmd}`.split("\n")
        gene_beast_logs.each {|lg|
          cmd1 = "cat #{lg} | awk '{print $1}' | tail -n 1"; 
          nb_states = `#{cmd1}`.chomp
          if nb_states == "1000000"
             calcs_nb += 1    
          end
        }



     
     zeros_nb = `ls -s #{res_type}/#{gn}/#{ws}/*/dated_tree.annot | sed -n '/^0/p' |wc |  awk '{print $1}'`
     zeros_nb = zeros_nb.chomp()

     gn_color = :default
     gn_color = :green if wins_nb == calcs_nb
     
     zr_color = :default
     zr_color = :red if zeros_nb.to_i > 0 

     #puts sprintf("%2d - %s",index,task.name.bright).color(color)
   
     #printf("%2d - %s\n",index,task.name.bright)
     printf("%3d:  ws: %2d, gene: %s, wins_nb: #{wins_nb} , calcs_nb: #{calcs_nb}, zeros_nb: %s \n", idx, ws, gn.color(gn_color), zeros_nb.color(zr_color))
       
     }

    }  
    #puts genes.inspect

  end

end

  mr = ManageResults.new
  mr.count_progress()
  
   




