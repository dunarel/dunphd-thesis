#!/usr/bin/env jruby

require 'rubygems'
require 'erb'
require 'optparse'

 #parse command line
 $options = {}
 option_parser = OptionParser.new do |opts|
  # Create a switch
  #opts.on("-i","--iteration") do
  # $options[:iteration] = true
  #end
  # Create a flag
  opts.on("--range RANGE") do |range|
   $options[:range] = range
   $rng_min = range.split("-")[0].to_i
   $rng_max = range.split("-")[1].to_i

  end

  opts.on("--wall HOURS") do |wall|
   $options[:wall] = wall
  end

  opts.on("--threads NB") do |threads|
   $options[:threads] = threads
  end


 end
 option_parser.parse!
 
 
 puts $options.inspect


class GenQsubFiles

 def initialize()
  @job_hours = $options[:wall]
  @job_nb_threads = $options[:threads]
  
 end

 

 def pers(job_idx)

   @job_s = "%05d" % job_idx
  
  
 end

 def gen_one_file()
    #qsub template erb file
    qsub_text = File.read("templ/qsub-job.ksh.erb")
    
    #qsub specific file
    qsub_f = File.new("qsubs/job-qsub-#{@job_s}.ksh", "w")
    
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
  idx_f = File.new("job-idx.txt", "a")
   
  ($rng_min..$rng_max).each {|idx| 
   
   puts "idx: #{idx}"
   pers(idx)
   idx_f.puts @job_s 
   gen_one_file()
  
  }
  idx_f.close
  
 end
 

end


 # hours, job_no
 gqf = GenQsubFiles.new()
 gqf.gen_all_files()


 
 








    





