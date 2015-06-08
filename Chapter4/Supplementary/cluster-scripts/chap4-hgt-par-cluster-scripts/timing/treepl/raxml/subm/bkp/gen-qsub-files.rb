#!/usr/bin/env ruby

require 'rubygems'
require 'erb'
require '../lib/local-config.rb'


class GenQsubFiles
  def initialize
    puts "in Class.initialize..."
    extend LocalConfig
    init()
  end
  def init
    #puts "in Class.init, last called after all extensions"
  end


 def gen_one_file()
    

    #qsub template erb file
    qsub_text = (self.ldir + "templ/qsub-job.ksh.erb").read
    
    #qsub specific file
    qsub_f = File.new(self.ldir + "qsubs/job-qsub-#{job_s}.ksh", "w")
    

    #puts "self.job_s: #{self.job_s}, qsub_f: #{qsub_f.inspect}"

    #write qsub file from erb template
    b= binding
    qsub_erb = ERB.new(qsub_text)

    #uses 
    qsub_f.puts qsub_erb.result(b)

    qsub_f.close
    
    #puts qsub_erb.result(b)


 end

 def gen_all_files()
  #output index files
  #appends indexes
  idx_f = File.new(self.ldir + "subm/job-idx.txt", "a")
   
  ($opt_rng_min..$opt_rng_max).each {|idx| 
   #add index to submit list
   idx_f.puts idx

   puts "idx: #{idx}"
   self.job_idx = idx
   puts "self.job_s #{self.job_s}"
   gen_one_file()
  
  }
  idx_f.close
  
 end
 

end


 # ./gen-qsub-files.rb --range 100-100 --procs 11 --threads 2 --wall 36 
 # hours, job_no
 gqf = GenQsubFiles.new()
 gqf.gen_all_files()
