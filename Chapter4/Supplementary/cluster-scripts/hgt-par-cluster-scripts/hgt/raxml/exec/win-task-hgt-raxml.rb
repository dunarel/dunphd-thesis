#!/home/badescud/local/bin/ruby 

 require 'rubygems'
 require 'optparse'
 require '../../../../lib/local-config.rb'
 require 'posix/spawn'
 require 'pathname'
 require 'thread'


class WinTask
  include POSIX::Spawn

  def initialize
    puts "in Class.initialize..."
    extend LocalConfig
    init()
    #
    @fen_d = Pathname.new Dir.getwd 
    puts "@fen_d: #{@fen_d}"
    @time_samples = []
    #sample size
    @fen_d_size = 20
    #sample each one minute
    @sleep_sample = 600
    #stalled threshold
    @fen_d_epsilon = 5

  end
  def init
    #puts "in Class.init, last called after all extensions"
  end


  #infinite loop
  #enque folder size deltas
  def upd_folder_size
  
   @t1 = Thread.new{  
     
    @time_samples = []
 
    puts "in upd_folder_size..."
    prev_size = 0
    loop {
      puts "in loop each 2 secs"
      this_size = 0
      @fen_d.children.each { |pn|
       this_size += (pn.size? || 0) if pn.file?
      }
      @time_samples << (this_size - prev_size).abs
      puts "upd, @time_samples: #{@time_samples.inspect}"
      sleep @sleep_sample
      prev_size = this_size
    }

   }
   
  end

  def check_folder_size
  
   @t2 = Thread.new{  
            
      #wait for values to accumulate
      while (@time_samples.length < @fen_d_size) do
        sleep @sleep_sample
      end


      puts "in t2..."
      loop {
       
       puts "@time_samples: #{@time_samples.inspect}"
       #samples = @time_samples[1..5]
       # puts "samples: #{samples}"
       #med = samples.sum / samples.length

       #puts "samples:  #{@time_samples.last(3).inspect}, med: #{@time_samples.last(3).sum/3}"
       
       #crop
       
       @time_samples.shift(@time_samples.length - @fen_d_size) if @time_samples.length  > @fen_d_size

       med = @time_samples.reduce(0, :+) / @time_samples.length
       puts "med: #{med}"
       if med < @fen_d_epsilon
        puts "Stalled ! Aborting !"
        exit(0)
       end

       sleep @sleep_sample
      }
      
   }

  end

 

  def execute

   
   Thread.abort_on_exception = true

    #calculate input file
    cmd = "../../../../exec/hgt3.4 -inputfile=input.txt -viewtree=yes"
    puts cmd
    pid = spawn(cmd, {:out => "gene_root.log"})
    #check loop
    upd_folder_size() 
    check_folder_size()
    Process.wait(pid)
    @t2.exit #could block in loop waiting for t1 to enqueue
    @t1.exit
    puts "@time_samples: #{@time_samples.inspect}"
    sleep 5 
   

    #copy partition to rooted_tree folder
    pw_d = Pathname.new FileUtils.pwd
    un_tr_d = pw_d + "unrooted_tree"

    #puts "pw_d: #{pw_d}, un_tr_d: #{un_tr_d}"

    un_tr_d.rmtree if un_tr_d.exist?
    un_tr_d.mkdir

    FileUtils.cp "geneRootLeaves.txt",  un_tr_d
    FileUtils.cp "gene_root.log",  un_tr_d

    #cleanup for hgt computation
    #delete all files except permanent ones
    perm_f_a = @config_yml["perm_files"].collect {|fl|  (pw_d + fl) }

    pw_d.each_child{ |f|
      #local file absolute
      fa = pw_d + f
      puts "fa: #{fa}, perm_f_a: #{perm_f_a}, #{perm_f_a.include? fa}"
   
      fa.delete if fa.file? and !perm_f_a.include?(fa)
      
    }



   
    #calculate hgt transfers
    cmd = "perl ../../../../exec/run_hgt3.4.pl -inputfile=input.txt -bootstrap=yes -nbhgt=200"
    puts cmd
    pid = spawn(cmd, {:out => "hgt1.log"})
    #check loop
    upd_folder_size() 
    check_folder_size()
    Process.wait(pid)
    @t2.exit #could block in loop waiting for t1 to enqueue
    @t1.exit
    puts "@time_samples: #{@time_samples.inspect}"
    sleep 5 
   
   
   
  end
  


end


  puts `pwd`
 
  wt = WinTask.new
  wt.execute

  
 #Process.setpriority(Process::PRIO_PROCESS, 0, -2)
 #puts Process.getpriority(Process::PRIO_USER, 0)   
 #puts Process.getpriority(Process::PRIO_PROCESS, 0) 
 #b_sec = rand(5...20)
 #uts "sleep to nb_sec: #{nb_sec}"
 #leep nb_sec
 # 10.times.map{ 20 + Random.rand(11) }
