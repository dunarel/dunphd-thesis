#!/usr/bin/env ruby

require 'rubygems'
require 'csv'
 
require 'erb'
require 'optparse'
require 'yaml'
require 'fileutils'
require 'pathname'
require '../lib/local-config.rb'



 include FileUtils
   

 class CheckProgress

  def initialize
    #puts "in Class.initialize..."                                                                                                                                                        
    extend LocalConfig                                                                                                                                                                   
    init()                                                                                                                                                                               
                                                                                                                                                                                      
    @here =  FileUtils.pwd()     

    #puts "here: #{@here}"
  
    # @scratch = Pathname.new(`echo $SCRATCH`.chomp)

   #puts "scratch: #{scratch}"
   # @work_d = @scratch + "hgt-com-110/hgt-com-raxml/timing/beast/work"
 
    @work_d = self.ldir + "res_loc"
    
    #puts "work_d: #{@work_d}"
   
   @stats_arr = []  



  end

  def init
    # puts "in RsyncScrath.init, last called after all extensions"                                                                                                                        
  end



    
  def iterate_fens

    puts "gene,max_iter,mean_ess,stdev_ess"

  fens_a = `ls -d #{@work_d}/*`.split
   #puts "fens_a: #{fens_txt}"

  #fens_a = fens_txt.split "\n"
   fens_a.each { |fen|
    
    fen_d = Pathname.new(fen)
    base, gene = fen_d.split
    #next if not gene.to_s == "purB"
    
      #puts "gene: #{gene.inspect}, base: #{base.inspect}"

      chdir fen_d
      begin
       max_iter_mil, mean_ess, stdev_ess = check_progress_one_fen
       max_iter = max_iter_mil.to_i / 10000
      rescue Exception => e  
        #puts "#{gene}: #{e.message}"
        max_iter, mean_ess, stdev_ess = 0, 0, 0
      end

      puts "#{gene}, #{max_iter.to_i}, #{mean_ess.to_i}, #{stdev_ess.to_i}"
      @stats_arr << [ max_iter_mil, mean_ess, stdev_ess]
   
     
    }
   # puts @stats_arr.inspect

   end

   def check_progress_one_fen

begin
log_txt = <<`DOC`
~/local/BEASTv1.7.4/bin/loganalyser -burnin 0 gene_beast.log 
DOC
rescue
 return [0,0,0]
end

  #puts log_txt

#reuse text



#title_txt = <<`DOC`
# echo "#{log_txt}" | head -n 17 | tail -n 1   
#DOC

 #puts "title_txt: #{title_txt}"
 max_iter = log_txt.match('maxState\s+=\s+(\d+)').captures[0]

 #puts "max_iter: #{max_iter}"
    
 mean_ess = log_txt.match('ucld.mean.+$')[0].split(" ")[6]
 mean_stdev = log_txt.match('ucld.stdev.+$')[0].split(" ")[6]


#find position of occurance
#pos = <<`DOC`
# echo "#{log_txt}" | grep -n "ucld.stdev" | awk '{print $1}'
#DOC
#  stdev_row = pos.split(":")[0]


#ess_txt = <<`DOC`
# echo "#{log_txt}" | head -n #{stdev_row} | tail -n 2 | awk '{print $1,$7}'  
#DOC

  #puts ess_txt
 
     [max_iter, mean_ess, mean_stdev]

   end


    def extract_failed
     arr_of_arrs = CSV.read("../log/progress3.csv",:headers => true).to_a
     arr_of_arrs.shift

     #puts "arr_of_arrs: #{arr_of_arrs.to_a.inspect}"
    
      arr_of_arrs.each { |row|
        max_iter = row[1].chomp.to_i
        if ![0,2000].include? max_iter
         puts row.inspect
        end


      }
   end

   def finalize
    chdir @here
   end

  end

  
   cp = CheckProgress.new
   cp.iterate_fens

   #cp.extract_failed
   cp.finalize



  # stalled = stalled.split(" ")[0].to_i
  # | tail -n 10 | head -n 2 | awk '{print $1,$7}'
  #echo "#{log_txt}" | tail -n 10 | head -n 2 | awk '{print $1,$7}'  
  #puts "stalled: #{stalled}"



