#!/usr/bin/env ruby

require 'rubygems'
require 'erb'
require 'fileutils'
require '../lib/local-config.rb'

#gem install sys-proctable --platform linux
#require 'sys/proctable'

 class RsyncScratch
  
  def initialize
    puts "in Class.initialize..."
    extend LocalConfig
    init()
  end  
  def init
    #puts "in RsyncScrath.init, last called after all extensions"
  end

 
  def rsync_to(dir)
   
    #create folder if non existant
    FileUtils.mkdir_p self.sdir if not Dir.exists? self.sdir

    cmd="rsync -avzx --del #{self.ldir}/#{dir}/ #{self.sdir}/#{dir}/"
    puts cmd; puts `#{cmd}`
    
    
  end


  def rsync_from(dir)
   
    cmd="rsync -avzx --del #{self.sdir}/#{dir}/ #{self.ldir}/#{dir}/"
    puts cmd; puts `#{cmd}`

   
  end  

 end

 rs = RsyncScratch.new
 #puts rs.exec_d
 #puts rs.home_d


 #puts rs.local_dir

  #work 
   rs.rsync_to("work")
   rs.rsync_to("jobs")
   rs.rsync_to("qsubs")
   rs.rsync_to("subm")

  #code
   rs.rsync_to("admin")
   rs.rsync_to("exec")
   rs.rsync_to("lib")
   rs.rsync_to("templ")
   rs.rsync_to("test")

  #results
   #rs.rsync_from("res_loc")
   #rs.rsync_from("results")
  

 





  
 
