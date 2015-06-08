#!/usr/bin/env ruby                                                                                                                                                                                               #https://makandracards.com/makandra/15003-how-to-ruby-heredoc-without-interpolation
#http://stackoverflow.com/questions/8309234/use-ruby-one-liners-from-ruby-code
#http://benoithamelin.tumblr.com/ruby1line
 

require 'rubygems'
require 'erb'
require 'optparse'
require 'yaml'
require 'fileutils'
require 'pathname'
require '../lib/local-config.rb'

 class CheckProgress
   include FileUtils

  def initialize
    puts "in Class.initialize..."
    extend LocalConfig
    init()

    # @work_d =  self.sdir + "work"
    # work_d =  self.ldir + "results"  
  end

  def init
    #puts "in Class.init, last called after all extensions"
  end


  def show_timing


   #no string interpolation with single quoting separator
cmd = <<'DOC'
 cat #{self.sdir}/subm/jpraxml-*.o* | ruby -ne '@fen_f=$1 if $_ =~ /jobs_f.*job-tasks-(.*)\.yaml/; puts"#{@fen_f} #{$1}" if $_ =~ /Resources.*(walltime.*)/'
DOC
  
  system cmd;
  
  end
  
  def show_stalled

stalled = <<`DOC`
 cat #{self.sdir}/work/*/*/*/sched-jobs.log | egrep Stalled | wc
DOC
   stalled = stalled.split(" ")[0].to_i

    puts "stalled: #{stalled}"

  end


  def show_results
results = <<`DOC`
  cat #{self.sdir}/work/*/*/*/sched-jobs.log |grep fen_align.re |wc 
DOC
   results = results.split(" ")[0].to_i

    puts "results: #{results}"

    



  end

end


  cp = CheckProgress.new
  cp.show_timing
  cp.show_stalled
  cp.show_results

 

#stalled = `"#{cmd}"`

#puts stalled






