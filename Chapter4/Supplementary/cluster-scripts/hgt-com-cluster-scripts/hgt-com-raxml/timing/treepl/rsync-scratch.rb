#!/usr/bin/env ruby

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


  opts.on("--wall HOURS") do |wall|
   $options[:wall] = wall
  end

  opts.on("--threads NB") do |threads|
   $options[:threads] = threads
  end


 end
 option_parser.parse!
 puts $options.inspect

 class RsyncScratch
 
  def initialize
    @home_d = `echo $HOME`.chomp
    @scratch_d = `echo $SCRATCH`.chomp
  end  

  def home_d 
   @home_d   
  end

  def scratch_d
   @scratch_d
  end

  def local_dir
   "hgt-com-110/hgt-com-raxml/timing/treepl"
  end


  def rsync_to(dir)
   
    ldir = "#{home_d}/#{local_dir}/#{dir}"
    #puts ldir

    sdir = "#{scratch_d}/#{local_dir}/#{dir}"
    #puts sdir

    cmd="rsync -avzx --del #{ldir}/ #{sdir}/"
    puts cmd; puts `#{cmd}`
   
  end

  def rsync_from(dir)
   
    ldir = "#{home_d}/#{local_dir}/#{dir}"
    #puts ldir

    sdir = "#{scratch_d}/#{local_dir}/#{dir}"
    #puts sdir

    cmd="rsync -avzx --del #{sdir}/ #{ldir}/"
    puts cmd; puts `#{cmd}`

   
  end  

 end

 rs = RsyncScratch.new
 #rs.rsync_to("work")
 #rs.rsync_to("jobs")
 # rs.rsync_from("results")






  
 
