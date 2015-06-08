#!/usr/bin/env ruby

require 'rubygems'
require 'erb'
require 'optparse'
require 'yaml'
require 'fileutils'
require 'pathname'
require '../lib/local-config.rb'

 class CopyRes
  
  def initialize
    puts "in Class.initialize..."
    extend LocalConfig
    init()
  end

  def init
    #puts "in RsyncScrath.init, last called after all extensions"
  end


  def copy_fens(recreate=false)
    
    work_d =  Pathname.new "#{self.sdir}/work"
    puts "work_d: #{work_d}"

    all_fens_arr = `ls -d #{work_d}/*/*/*`.split("\n")
    all_fens_a = all_fens_arr.collect {|fn| Pathname.new(fn).relative_path_from(work_d) }
    puts "all_fens_a: #{all_fens_a.inspect}"                                          
    puts "all_fens_cnt: #{all_fens_a.length}"
    
    all_fens_a.each { |fn|

     fen_src_d = self.sdir + "work" + fn
     #copy results to 2 folders, for rsync and local reuse on server (BIG FILES)
     [["results","results_files"],["res_loc","res_loc_files"]].each{ |fld, var| 
      fen_dst_d = self.sdir + fld + fn

      #recreate folder if asked
      begin
       fen_dst_d.rmtree if recreate == true 
      rescue Errno::ENOENT
        puts "No folder: #{fen_dst_d}"
      end


      FileUtils.mkdir_p fen_dst_d if not Dir.exists? fen_dst_d
       # puts "@files_yml: #{@files_yml.inspect}"
       # puts "@files_yml[#{var}]: #{@files_yml[var]}"
      @files_yml[var].each {|fl|
       #puts "fl: #{fl}"
       fen_src_f = fen_src_d + fl
       fen_dst_f = fen_dst_d + fl
       puts "fen_src_f: #{fen_src_f}"
       puts "fen_dst_f: #{fen_dst_f}"
       FileUtils.cp(fen_src_f, fen_dst_f) if fen_src_f.exist?
      }
    }
                 

    }    


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

 cr = CopyRes.new
 #puts rs.exec_d
 #puts rs.home_d
 cr.copy_fens(true)

 





  
 
