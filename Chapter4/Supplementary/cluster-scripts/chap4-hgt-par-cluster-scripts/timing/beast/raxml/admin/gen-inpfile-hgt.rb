#!/usr/bin/env ruby

require 'rubygems'
require 'erb'
require 'optparse'
require 'yaml'
require 'fileutils'
require 'pathname'
require '../lib/local-config.rb'

 class GenInpfile
   include FileUtils

  def initialize
    puts "in Class.initialize..."
    extend LocalConfig
    init()
  end  

   def init
    #puts "in Class.init, last called after all extensions"
   end

  def iterate_fens
    work_d =  self.ldir + "work"
    puts "work_d: #{work_d}"   

    all_fens_arr = `ls -d #{work_d}/*/*/*`.split("\n")
    all_fens_a = all_fens_arr.collect {|fn| Pathname.new(fn).relative_path_from(work_d) }
    #puts "all_fens_a: #{all_fens_a.inspect}"                                          
    puts "all_fens_cnt: #{all_fens_a.length}"
    all_fens_a.each { |fn|
      base, @fen_name = fn.split
      @gene_name, @win_size = base.split

      puts "fen_name: #{@fen_name}, @gene_name: #{@gene_name}, @win_size: #{@win_size}"    
     
      hgt_inp_f = work_d + fn + "input.txt"
      puts "hgt_inp_f: #{hgt_inp_f}"
      
      rm_rf(hgt_inp_f)

      gen_sp = (self.home_d + "hgt-com-110/gene_blo_seqs_sp/#{@gene_name}_sp.new").read
      nwk_re = (self.home_d + "hgt-par-110/phylo/raxml/results" + fn + "RAxML_bipartitions.fen_align.re").read.gsub(/0\.0000/, '0.1')
      nwk_bs = (self.home_d + "hgt-par-110/phylo/raxml/res_loc" + fn + "RAxML_bootstrap.fen_align.bs").read.gsub(/0\.0000/, '0.1')

      #puts "nwk_re: #{nwk_re}"
      #puts "modif: ----------------"
      #nwk_re.gsub!(/0\.0000/, '0.1')
      #puts "nwk_re: #{nwk_re}"

      
      
      f = hgt_inp_f.open "w"
       f.puts gen_sp
       f.puts nwk_re
       f.puts nwk_bs

      f.close
      

      #cat ~/$1/gene_blo_seqs_sp/${col2}_sp.new > $out
      #cat ~/$1/gene_blo_seqs_raxml/results/${col2}/RAxML_bipartitions.${col2}.re |  sed 's/0\.0000/0\.1/g' >> $out 
      #cat ~/$1/gene_blo_seqs_raxml/results/${col2}/RAxML_bootstrap.${col2}.bs | sed 's/0\.0000/0\.1/g' >> $out

    }

  end


  def copy_fens(recreate=false)
    
    work_d =  Pathname.new "#{self.sdir}/work"
    puts "work_d: #{work_d}"

    all_fens_arr = `ls -d #{work_d}/*/*/*`.split("\n")
    all_fens_a = all_fens_arr.collect {|fn| Pathname.new(fn).relative_path_from(work_d) }
    puts "all_fens_a: #{all_fens_a.inspect}"                                          
    puts "all_fens_cnt: #{all_fens_a.length}"
    
    all_fens_a.each { |fn|

      fen_src_d = Pathname.new("#{self.sdir}/work") + fn
      fen_dst_d = Pathname.new("#{self.sdir}/results") + fn

      #recreate folder if asked
      fen_dst_d.rmtree if recreate == true and fen_dst_d.exist?
      FileUtils.mkdir_p fen_dst_d if not Dir.exists? fen_dst_d

    @files_yml["active_files"].each {|fl|
      #puts "fl: #{fl}"
      fen_src_f = fen_src_d + fl
      fen_dst_f = fen_dst_d + fl
      puts "fen_src_f: #{fen_src_f}"
      puts "fen_dst_f: #{fen_dst_f}"
      FileUtils.cp(fen_src_f, fen_dst_f) if fen_src_f.exist?


    }
                 

      
      
        

    }    


  end
 

 end

 gi = GenInpfile.new
 gi.iterate_fens
   


 





  
 
