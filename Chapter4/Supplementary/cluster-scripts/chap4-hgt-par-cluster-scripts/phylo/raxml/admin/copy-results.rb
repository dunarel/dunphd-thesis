#!/usr/bin/env jruby

require 'rubygems'
require 'yaml'

class ManageResults

 def initialize()
  @config_yml = YAML.load_file('templ/config.yml')
  @exec_yml = YAML.load_file('templ/exec.yml')

  cmd =  "cat templ/values.txt | awk '{print $2}'"
  @genes = `#{cmd}`.split("\n")
 
  @stage = @config_yml["stage"]
  @timing_prog = @config_yml["timing_prog"]

  end 

  def copy_annot

   @genes.each {|gn|

   case [@stage,@timing_prog]
     when ["hgt-par", "beast"]
     cmd = "ls work/#{gn}/*/*/dated_tree.annot"; puts cmd; 
     annot_fs = `#{cmd}`.split("\n")
     annot_fs.each {|an|
         fld = "#{$1}"  if an =~ /^work\/(.+)\/dated_tree.annot$/
         ins = "mkdir -p results/#{fld}"; puts ins; puts `#{ins}`
          cmd1 = "cat work/#{fld}/gene_beast.log | awk '{print $1}' | tail -n 1"; puts cmd1; 
          nb_states = `#{cmd1}`.chomp
          if nb_states == "1000000"
           ins = "cp #{an} results/#{fld}/dated_tree.annot"; puts ins; puts `#{ins}`
           #prevent 100% processor usage
           sleep 0.2
          else
            puts "only >#{nb_states}<"
          end
     }
     
     
     #cmd = "rm -fr results/#{gn}/*/*/gene_beast.log"; puts cmd; puts `#{cmd}` 
     #cmd = "rm -fr results/#{gn}/*/*/gene_beast.ops"; puts cmd; puts `#{cmd}` 
     #cmd = "rm -fr results/#{gn}/*/*/gene_beast.trees"; puts cmd; puts `#{cmd}` 
     #cmd = "rm -fr results/#{gn}/*/*/gene_beast.xml"; puts cmd; puts `#{cmd}` 
     #cmd = "rm -fr results/#{gn}/*/*/gene_res.tr"; puts cmd; puts `#{cmd}` 
     #cmd = "rm -fr results/#{gn}/*/*/starting_tree.nwk"; puts cmd; puts `#{cmd}` 
        
     
    end
  
    #puts %x[ls ./#{gn}]

   }
 

 #cat values.txt | awk '{print $2}' | xargs -t -I{} sh -c 'rm -fr results/{}/mrcas.yaml'
 #cat values.txt | awk '{print $2}' | xargs -t -I{} sh -c 'rm -fr results/{}/*/*/gene_res.tr'
 #cat values.txt | awk '{print $2}' | xargs -t -I{} sh -c 'rm -fr results/{}/*/*/dated_tree.nwk.r8s'

  end

 end
 
  mr = ManageResults.new
  mr.copy_annot


  
 

