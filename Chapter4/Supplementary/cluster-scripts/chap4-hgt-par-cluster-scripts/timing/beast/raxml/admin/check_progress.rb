#!/usr/bin/env ruby
 require 'pathname'
 require 'fileutils'

 include FileUtils
   

 class CheckProgress

  def initialize
   @here = Pathname.new pwd
   #puts "here: #{@here}"
  
   @scratch = Pathname.new(`echo $SCRATCH`.chomp)

   #puts "scratch: #{scratch}"
   @work_d = @scratch + "hgt-par-110/timing/beast/raxml/work/*/*" 
   #puts "work_d: #{@work_d}"
   
   @stats_arr = []  

    puts "gene,win_size,fen,iter,mean_ess,stdev_ess"
  end

    
  def iterate_fens



  fens_a = `ls -d #{@work_d}/*`.split
   #puts "fens_a: #{fens_txt}"

  #fens_a = fens_txt.split "\n"
   fens_a.each { |fen|
    
    fen_d = Pathname.new(fen)
    base, fen_s = fen_d.split
    base, win_size_s = base.split
    base, gene_s = base.split
   

    #next if not gene.to_s == "purB"
    
      chdir fen_d
      begin
       max_iter_mil, mean_ess, stdev_ess = check_progress_one_fen
       max_iter = max_iter_mil.to_i / 10000
      rescue Exception => e  
        #puts "#{gene}: #{e.message}"
        max_iter, mean_ess, stdev_ess = 0, 0, 0
      end

      puts "#{gene_s},#{win_size_s},#{fen_s},#{max_iter},#{mean_ess.to_i},#{stdev_ess.to_i}"
      @stats_arr << [ max_iter_mil, mean_ess, stdev_ess]
   
     
    }
    puts @stats_arr.inspect
   end

   def check_progress_one_fen

begin
log_txt = <<`DOC`
~/local/BEASTv1.7.4/bin/loganalyser gene_beast3.log 
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

   def finalize
    chdir @here
   end

  end

  
   cp = CheckProgress.new
   cp.iterate_fens

   cp.finalize



  # stalled = stalled.split(" ")[0].to_i
  # | tail -n 10 | head -n 2 | awk '{print $1,$7}'
  #echo "#{log_txt}" | tail -n 10 | head -n 2 | awk '{print $1,$7}'  
  #puts "stalled: #{stalled}"



