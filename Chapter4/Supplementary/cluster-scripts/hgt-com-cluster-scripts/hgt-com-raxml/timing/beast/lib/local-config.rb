
require 'rubygems'
require 'erb'
require 'optparse'
require 'yaml'
require 'fileutils'
require 'pathname'



module LocalConfig

  #jobid from command line, for external overwrite
  attr_accessor :job_idx

  def parse_cmdline
    #config
    $options = {}
    option_parser = OptionParser.new do |opts|
      # Create a switch
      #opts.on("-i","--iteration") do
      # $options[:iteration] = true
      #end
      # Create a flag
      opts.on("--execloc NAME") do |it|
       $exec_loc = it
      end

      # Create a flag
      opts.on("--range RANGE") do |it|
       $opt_rng = it
       $opt_rng_min = it.split("-")[0].to_i
       $opt_rng_max = it.split("-")[1].to_i
      end

      opts.on("--wall HOURS") do |it|
       $opt_wall = it
      end

      opts.on("--procs NB") do |it|
       $opt_procs = it
      end

      opts.on("--threads NB") do |it|
       $opt_threads = it
      end

      opts.on("--jobid NB") do |it|
       #sets it on command line parsing as default for @job_idx field
       self.job_idx = it
      end




   end
     #parse
     option_parser.parse!
     #puts $options.inspect

  end


  def init
    #puts "in LocalConfig.init"
    
    #puts "config_root_d: #{self.config_root_d }"

    @config_yml = YAML.load_file(self.config_root_d +  "templ/config.yml")

    # @exec_yml = YAML.load_file('../templ/exec.yml')
    # @files_yml = YAML.load_file('../templ/files.yml')
    


    #puts "@config_yml: #{@config_yml.inspect}"

    #puts "exec_yml: #{@exec_yml.inspect}"
    #puts "files_yml: #{@files_yml.inspect}"

    parse_cmdline()
       
    super

  end  

  def job_name
    @config_yml["job_name"]
  end

  def queue
    @config_yml["queue"]
  end

  def opt_wall
    $opt_wall
  end

  def opt_procs
    $opt_procs.to_i
  end

  def opt_threads
    $opt_threads.to_i
  end
  
  def job_s
     "%05d" % self.job_idx
    # job_idx
  end

  #based on this file location
  def config_root_d 
    Pathname.new(__FILE__).dirname.parent 
   end
     
  def home_d 
   Pathname.new @config_yml["home"]      
  end

  def exec_d
   key = @config_yml["exec_loc"]
   val = Pathname.new @config_yml[key]
   #puts "key: #{key}, val: #{val}" 
    
   return val

  end

  def local_dir
    Pathname.new @config_yml["local_dir"]
  end

  def ldir
    ldir = Pathname.new "#{home_d}/#{local_dir}"
    #puts ldir
  end

  def sdir
    sdir = Pathname.new "#{exec_d}/#{local_dir}"
    #puts sdir 
  end


 

 end

