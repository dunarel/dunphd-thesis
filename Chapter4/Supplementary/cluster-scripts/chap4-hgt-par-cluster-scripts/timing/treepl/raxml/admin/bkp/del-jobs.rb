#!/usr/bin/env jruby

require 'rubygems'
require 'yaml'

class ManageResults

 def initialize()
  @config_yml = YAML.load_file('../templ/config.yml')
  @exec_yml = YAML.load_file('../templ/exec.yml')

  cmd =  "bqstat -u badescud"
  @jobs = `#{cmd}`.split("\n")
   5.times {@jobs.shift }
 
  @stage = @config_yml["stage"]
  @timing_prog = @config_yml["timing_prog"]

  end 

  def default

   puts @jobs.inspect
   @jobs.each {|jb|
     job_id = ""
     job_name = ""
     job_nb = ""

    if jb =~ /^(\S+)\s+(\S+)\s+(\S+)\s+(\S+)/
     job_id = "#{$1}"  
     job_name =  "#{$4}"  
     if job_name =~ /jpbeast\-(\S+)/
        job_nb = "#{$1}" 
     end

      job_tsk_id = "#{$1}" if job_id =~ /^(\S+)\.mp2\.m$/
    end
      
      puts "job_id: #{job_id}, job_name: #{job_name}, job_nb: #{job_nb}, job_tsk_id: #{job_tsk_id}"
      cmd = "qdel #{job_tsk_id}"; puts cmd; puts `#{cmd}` 
    }



     #cmd = "bqstat -u badescud  ls work/#{gn}/*/*/dated_tree.annot"; puts cmd; 
     #annot_fs = `#{cmd}`.split("\n")
     #annot_fs.each {|an|
      #   
      #   ins = "mkdir -p results/#{fld}"; puts ins; puts `#{ins}`
       #  ins = "cp #{an} results/#{fld}/dated_tree.annot"; puts ins; puts `#{ins}`
     #}
     
     
     #cmd = "rm -fr results/#{gn}/*/*/gene_beast.log"; puts cmd; puts `#{cmd}` 
     #cmd = "rm -fr results/#{gn}/*/*/gene_beast.ops"; puts cmd; puts `#{cmd}` 
     #cmd = "rm -fr results/#{gn}/*/*/gene_beast.trees"; puts cmd; puts `#{cmd}` 
     #cmd = "rm -fr results/#{gn}/*/*/gene_beast.xml"; puts cmd; puts `#{cmd}` 
     #cmd = "rm -fr results/#{gn}/*/*/gene_res.tr"; puts cmd; puts `#{cmd}` 
     #cmd = "rm -fr results/#{gn}/*/*/starting_tree.nwk"; puts cmd; puts `#{cmd}` 
        
     
   #puts %x[ls ./#{gn}]

   
 #cat values.txt | awk '{print $2}' | xargs -t -I{} sh -c 'rm -fr results/{}/mrcas.yaml'
 #cat values.txt | awk '{print $2}' | xargs -t -I{} sh -c 'rm -fr results/{}/*/*/gene_res.tr'
 #cat values.txt | awk '{print $2}' | xargs -t -I{} sh -c 'rm -fr results/{}/*/*/dated_tree.nwk.r8s'

  end

 end
 
  mr = ManageResults.new
  mr.default


  
 

