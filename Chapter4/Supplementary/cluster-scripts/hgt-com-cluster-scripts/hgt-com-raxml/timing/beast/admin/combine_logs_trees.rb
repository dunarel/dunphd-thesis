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

    @here =  FileUtils.pwd()
 
  end

  def finalize
     FileUtils.cd @here
  end

  def init
    #puts "in RsyncScrath.init, last called after all extensions"
  end


  def copy_fens(recreate=false)
    
    #work_d =  Pathname.new "#{self.sdir}/work"
    work_d =  Pathname.new "#{self.ldir}/res_loc"
    puts "work_d: #{work_d}"

    #all_fens_arr = `ls -d #{work_d}/*/*/*`.split("\n")
    all_fens_arr = `ls -d #{work_d}/*`.split("\n")
    all_fens_a = all_fens_arr.collect {|fn| Pathname.new(fn).relative_path_from(work_d) }
    #puts "all_fens_a: #{all_fens_a.inspect}"                                          
    puts "all_fens_cnt: #{all_fens_a.length}"
    #sleep 5
    
    all_fens_a.each { |fn|
       
      fen_src_d = self.ldir + "res_loc" + fn
      FileUtils.cd fen_src_d
      puts "in #{FileUtils.pwd}"

      #combine logs
      cmd = "#{home_d}/local/BEASTv1.7.5/bin/logcombiner -burnin 2000000 gene_beast1.log gene_beast2.log gene_beast3.log gene_beast.log"
      puts cmd; puts `#{cmd}`

      #combine trees
      cmd = "#{home_d}/local/BEASTv1.7.5/bin/logcombiner -trees -burnin 2000000 gene_beast1.trees gene_beast2.trees gene_beast3.trees gene_beast.trees"
      puts cmd; puts `#{cmd}`
  
      starting_tree_f = self.ldir + "work" + fn + "starting_tree.nwk"

      #annotate trees 
      cmd = "#{home_d}/local/BEASTv1.7.5/bin/treeannotator -heights median -burnin 0 -limit 0.5 -target #{starting_tree_f} gene_beast.trees dated_tree.annot"
      puts cmd; puts `#{cmd}`

      
      fen_src_f = fen_src_d + "dated_tree.annot"
      fen_dst_d = self.ldir + "results" + fn
      fen_dst_f = fen_dst_d + "dated_tree.annot"                                                                                                                               
                                                                                                                                                                                            
      puts "fen_src_f: #{fen_src_f}"                                                                                                                                                    
      puts "fen_dst_f: #{fen_dst_f}"                                                                                                                                                    
      FileUtils.mkdir_p fen_dst_d if not Dir.exists? fen_dst_d
      FileUtils.mv(fen_src_f, fen_dst_f) if fen_src_f.exist?

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

 #do not recreate when broken on server
 cr.copy_fens(false)

 cr.finalize()

 





  
 
