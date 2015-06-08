#!/usr/bin/env ruby

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
  end  

  def init
    #puts "in Class.init, last called after all extensions"
   end

  def iterate_fens
    #collect statistics
    win_dims_a = []
    dim_genes_h = {}    
    fen_tot_h = {}
    fen_calc_h = {}

    #work_d =  Pathname.new "#{self.ldir}/results"
    #work_d =  self.sdir + "work"
    work_d =  self.sdir + "results"

    puts "work_d: #{work_d}"   

    all_fens_arr = `ls -d #{work_d}/*/*/*`.split("\n")
    all_fens_a = all_fens_arr.collect {|fn| Pathname.new(fn).relative_path_from(work_d) }
    #puts "all_fens_a: #{all_fens_a.inspect}"                                          
    #puts "all_fens_cnt: #{all_fens_a.length}"
    #sleep 6

    all_fens_a.each { |fn|
      base, fen_name = fn.split
      gene_name, win_size = base.split
      @gene_name = gene_name.to_s
      @fen_name = fen_name.to_s
      @win_size = win_size.to_s
      

      #puts "fen_name: #{@fen_name}, @gene_name: #{@gene_name}, @win_size: #{@win_size}"
      if !win_dims_a.include? @win_size    
          win_dims_a << @win_size
          dim_genes_h[@win_size] = []
      end 
      
      if !dim_genes_h[@win_size].include? @gene_name  
       dim_genes_h[@win_size] << @gene_name 
       fen_tot_h[[@win_size,@gene_name]] = 0
       fen_calc_h[[@win_size,@gene_name]] = 0
      end

      
      fin_f = work_d + fn + @config_yml["finished_file"]
      started_f = work_d + fn + @config_yml["started_file"] 

      #puts "fin_f: #{fin_f}"
      
      fen_tot_h[[@win_size,@gene_name]] += 1
      fen_calc_h[[@win_size,@gene_name]] += 1 if fin_f.exist? 
       puts "Unfinished: #{work_d + fn}" if !fin_f.exist? and started_f.exist?
       #puts "Unstarted: #{work_d + fn}" if !started_f.exist?
             

      hgt_inp_f = work_d + fn + "input.txt"
      #puts "hgt_inp_f: #{hgt_inp_f}"
      
      #rm_rf(hgt_inp_f)

      #gen_sp = (self.home_d + "hgt-com-110/gene_blo_seqs_sp/#{@gene_name}_sp.new").read
      #nwk_re = self.exec_d + "hgt-par-110/phylo/raxml/work" + fn + "RAxML_bipartitions.fen_align.re" # |  sed 's/0\.0000/0\.1/g' >> $out 
      #puts "nwk_re: #{nwk_re}"

      #nwk_bs = 
      
      #f = hgt_inp_f.open "w"
      #f.puts gen_sp
      #f.close
      

      #

      #cat ~/$1/gene_blo_seqs_sp/${col2}_sp.new > $out
      #cat ~/$1/gene_blo_seqs_raxml/results/${col2}/RAxML_bipartitions.${col2}.re |  sed 's/0\.0000/0\.1/g' >> $out 
      #cat ~/$1/gene_blo_seqs_raxml/results/${col2}/RAxML_bootstrap.${col2}.bs | sed 's/0\.0000/0\.1/g' >> $out

    }
    puts "win_dims_a: #{win_dims_a.inspect}"
    puts "dim_genes_h: #{dim_genes_h.inspect}"
    #puts "fen_tot_h: #{fen_tot_h.inspect}"
    #puts "fen_calc_h: #{fen_calc_h.inspect}"


    win_dims_a.each {|wd|
      puts "win_dim: #{wd}"

      dim_genes_h[wd].each {|dg|
        tot = fen_tot_h[[wd,dg]]
        calc = fen_calc_h[[wd,dg]]
        dif = tot.to_i - calc.to_i
        puts "gene: #{dg}, #{tot}, #{calc}, #{dif}" if dif != 0


      }

    }
    
    #summary

    wdtot = {} 
    wdcalc = {}
  
    puts "WIN\tTOT\tCALC\tDIF"

    win_dims_a.each {|wd|
      wdtot[wd] = 0
      wdcalc[wd] = 0
      #puts "win_dim: #{wd}"

      dim_genes_h[wd].each {|dg|
        tot = fen_tot_h[[wd,dg]].to_i
        calc = fen_calc_h[[wd,dg]].to_i
        dif = tot - calc
        wdtot[wd] += tot
        wdcalc[wd] += calc

        #puts "gene: #{dg}, #{tot}, #{calc}, #{dif}"


      }
      
      puts "#{wd}\t#{wdtot[wd]}\t#{wdcalc[wd]}\t#{wdtot[wd] - wdcalc[wd]}"
   
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

 cp = CheckProgress.new
 cp.iterate_fens
   


 





  
 
