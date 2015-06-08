#!/usr/bin/env ruby

require 'rubygems'
require 'pathname'
require 'posix/spawn'
require '../lib/local-config.rb'


 class ClusPar
  include POSIX::Spawn
  
  def initialize
    puts "in RsyncScrath.initialize..."
    extend LocalConfig
   

    init()
  end

  def init
    puts "in RsyncScrath.init, last called after all extensions"
  end

  def submit_jobs
   jobs_f = Pathname.new "job-idx.txt"
   jobs = jobs_f.read.split

   jobs.each { |jb|

      self.job_idx = jb
     
      system 'qsub', "../qsubs/job-qsub-#{job_s}.ksh"

   }
    
  end
  
 end

cp = ClusPar.new
cp.submit_jobs



#no string interpolation with single quoting separator
#cmd = <<'DOC'
# cat job-idx.txt | ruby -ne 'x = $_.chomp; puts"#{x}"'
#DOC
#child = POSIX::Spawn::Child.new(cmd)
#puts child.out








