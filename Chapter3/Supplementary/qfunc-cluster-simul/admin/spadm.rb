#!/usr/bin/env jruby

  require 'rubygems'
  require 'open5'

 # Server Project Administration
 # Dunarel Badescu, May 2011
 require 'rubygems'
 require 'net/ssh'
 require 'optparse'
 
 # This hash will hold all of the options
 # parsed from the command-line by
 # OptionParser.
 options = {}
 
 optparse = OptionParser.new do|opts|
   # Set a banner, displayed at the top
   # of the help screen.
   opts.banner = "Usage: spadm [options]"
 
   # This displays the help screen, all programs are
   # assumed to have this option.
   opts.on( '-h', '--help', 'Display this screen' ) do
     puts opts
     exit
   end
 
   options[:component] = nil
   opts.on( '--component COMPONENT', String, 'shm/derby/simul' ) do |component|
     options[:component] = component
   end

   options[:action] = nil
   opts.on( '--action ACTION', String, 'deploy/delete/start/stop/collect' ) do |action|
     options[:action] = action
   end

   options[:level] = nil
   opts.on( '--level LEVEL', String, 'one/all' ) do |level|
     options[:level] = level
   end

   # Run Suite
   options[:run] = false
   opts.on( '-r', '--run', 'Run all tests' ) do
     options[:run] = true
   end

   # Get results
   options[:get] = false
   opts.on( '-g', '--get', 'Get results file from blades' ) do
     options[:get] = true
   end

 
   # Get results and wrap-up
   options[:close] = false
   opts.on( '-c', '--close', 'Close work' ) do
     options[:close] = true
   end

   # Check il all finished
   options[:finished] = false
   opts.on( '-f', '--finished', 'Check if all finished' ) do
     options[:finished] = true
   end

   # Launch database client
   options[:dbclient] = false
   opts.on( '-d', '--dbclient', 'Launch Database Client' ) do
     options[:dbclient] = true
   end

   #Check Db Progress
   options[:check_progress] = false
   opts.on( nil, '--check_progress', 'Check Database Progress' ) do
     options[:check_progress] = true
   end



 end
 
 # Parse the command-line. Remember there are two forms
 # of the parse method. The 'parse' method simply parses
 # ARGV, while the 'parse!' method parses ARGV and removes
 # any options found there, as well as any parameters for
 # the options. What's left is the list of files to resize.
 optparse.parse!
 
 puts "Being verbose" if options[:verbose]
 puts "Being quick" if options[:quick]
 puts "Logging to file #{options[:logfile]}" if options[:logfile]
 
 puts options.inspect
 
 #rest of command line
 ARGV.each do|f|
   puts "Additional parameter #{f}..."
   sleep 0.5
 end

 module Kernel
  def sys(cmd)
    puts cmd; system(cmd)
  end
 end


 class Spadm

   attr_reader :admin_folder

  def initialize()
    
    @jruby_exec = "~/dunarel/jruby-1.6.2/bin/jruby"
    @machines = {}

    #@machines.store("compute-00-03.hpcc.licef.ca",["03","test_debug"])
    @machines.store("compute-00-04.hpcc.licef.ca",["04","f06_LSP"])
    @machines.store("compute-00-05.hpcc.licef.ca",["05","f06_LSM"])
    @machines.store("compute-00-06.hpcc.licef.ca",["06","f06_EPP"])
    @machines.store("compute-00-07.hpcc.licef.ca",["07","f06_EPM"])

    @machines.store("compute-00-08.hpcc.licef.ca",["08","f05_LSP"])
    @machines.store("compute-00-09.hpcc.licef.ca",["09","f05_LSM"])
    @machines.store("compute-00-10.hpcc.licef.ca",["10","f05_EPP"])
    @machines.store("compute-00-11.hpcc.licef.ca",["11","f05_EPM"])

    @machines.store("compute-00-12.hpcc.licef.ca",["12","f04_LSP"])
    @machines.store("compute-00-13.hpcc.licef.ca",["13","f04_LSM"])
    @machines.store("compute-00-14.hpcc.licef.ca",["14","f04_EPP"])
    @machines.store("compute-00-15.hpcc.licef.ca",["15","f04_EPM"])

    #puts @machines.inspect()
 

   #administration
   @proj_name = "simul_ruby"
   @private_folder = "/home/abdiallo/dunarel"
   @proj_folder = "#{@private_folder}/#{@proj_name}"
   @admin_folder = "#{@private_folder}/admin"
   @proj_ij = "#{@private_folder}/#{@proj_name}/db/derby/bin/ij"
 
   @machine = `hostname`
   @machine.chomp!
   @task = @machines[@machine]
   
   @short_machine = @task[0] unless @task.nil?
   @test_suit = @task[1] unless @task.nil?
   #puts "@short_machine: #{@short_machine}"

  

   @shm_entry = "/dev/shm/abdiallo"
   @shm_loc = "#{@shm_entry}/dunarel"
   @shm_proj = "#{@shm_loc}/#{@short_machine}/#{@proj_name}" 

   #database
   @shm_db = "#{@shm_proj}/db"

   #simulations
   @shm_ruby_lib = "#{@shm_loc}/#{@short_machine}/#{@proj_name}/lib"
   @shm_files_folder = "#{@shm_proj}/files"
   @proj_results_folder = "#{@proj_folder}/results"
 

   #ensure chdir in admin_folder
   Dir.chdir(@admin_folder)
  end
 
   #check if machine is in permited hash 
   def legal_machine?
     @short_machine.nil? ? false : true   
 
   end

  #delete one machine
  def del_one_proj2shm()
     #checks
     if not legal_machine?
      puts "Wrong machine!"
     elsif db_server_started?
      puts "Database already started"
     elsif File.exist?(@shm_loc)
       sys "rm -fr #{@shm_loc}"
     end

       #delete teams container if non empty
       begin
        Dir.delete(@shm_entry)
       rescue 
        puts "Folder not deleted!"
       end

  end

   #deploy one machine
   def dep_one_proj2shm()

     if legal_machine?
       #do not delete deployment folder
       #show error
       if File.exist?(@shm_loc)
         puts "Deployment folder exists.. please remove first"
       else 
         #create deployment folder
         sys "mkdir -p #{@shm_loc}/#{@short_machine}"

         #deploy project folder
         sys "cp -r #{@proj_folder} #{@shm_loc}/#{@short_machine}/"
       end

     else
      puts "Wrong machine!"          
     end
   end


  #delete all machines
  def del_all_proj2shm()

   @machines.each_key { |m|
    puts "machine: #{m}"
    Net::SSH.start(m, "abdiallo") { |ssh|
     result = ssh.exec!("#{ENV['JRUBY_HOME']}/bin/jruby #{@admin_folder}/spadm.rb --component shm --action delete --level one")
     puts result
    }
   }

  end

  #deploy all machines
  def dep_all_proj2shm()

   @machines.each_key { |m|
    puts "machine: #{m}"
    Net::SSH.start(m, "abdiallo") { |ssh|
      result = ssh.exec!("#{ENV['JRUBY_HOME']}/bin/jruby #{@admin_folder}/spadm.rb --component shm --action deploy --level one")
     puts result
    }
   }

  end

  #derby 

   #check if server started
   def db_server_started?
     #if deleted it doesn't exist anymore
     if not File.exists?(@shm_db)
      false
     elsif 
      Dir.chdir(@shm_db)  
      resp =  `derby/bin/NetworkServerControl ping`
      Dir.chdir(@admin_folder)
      not (resp =~ /Connection\sobtained/).nil?
     end
 
   end


  #stop one machine
  def stop_one_db()
     if legal_machine?
      #
      if db_server_started?
        #stop server
        Dir.chdir(@shm_db)  
        sys "derby/bin/NetworkServerControl shutdown"
        Dir.chdir(@admin_folder)

      end
     else
      puts "Wrong machine!"          
     end

  end

   #start one machine
   def start_one_db()

     if legal_machine?
       #do not stop db
       #show error
       if db_server_started?
         puts "Database already started"
       else 
            
        #start server in db folder 
        Dir.chdir(@shm_db)  
        sys "derby/bin/NetworkServerControl start -h 0.0.0.0 &"
        Dir.chdir(@admin_folder)
       end

     else
      puts "Wrong machine!"          
     end
   end


  #stop all machines
  def stop_all_db()

   @machines.each_key { |m|
    puts "machine: #{m}"
    Net::SSH.start(m, "abdiallo") { |ssh|
     #delegate to one script
     result = ssh.exec!("#{ENV['JRUBY_HOME']}/bin/jruby #{@admin_folder}/spadm.rb --component derby --action stop --level one")
     puts result
    }
   }

  end

  #start all machines
  def start_all_db()

   @machines.each_key { |m|
    puts "machine: #{m}"
    Net::SSH.start(m, "abdiallo") { |ssh|
     #delegate to one script
    result = ssh.exec!("#{ENV['JRUBY_HOME']}/bin/jruby #{@admin_folder}/spadm.rb --component derby --action start --level one")
     puts result
    }
   }

  end

  #simul 

   #check if simulation is running
   def simul_started?
  
     res = `ps -ef | grep simul_two_subtrees | grep -v grep | awk '{print $2}'` 
     puts "res: #{res}"

     res == "" ? false: true    

   end

   #check all simulations
   def finished_all_simul?

    all_finished = true
    @machines.each_key { |m|
 
    Net::SSH.start(m, "abdiallo") { |ssh|
     #delegate to one script
     result = ssh.exec!("ps -ef | grep simul_two_subtrees | grep -v grep | awk '{print $2}'")
     puts "machine: #{m}, #{result}"
     all_finished = false if not result.nil?
    }
   }
   all_finished
   end


  #stop one simulation
  def stop_one_simul()
     if legal_machine?
      #
      if db_server_started?
        #stop simul
        res = `ps -ef | grep simul_two_subtrees | grep -v grep | awk '{print $2}'`           
        sys "kill -9 #{res}"
      end
     else
      puts "Wrong machine!"          
     end

  end



   #start one simul
   def start_one_simul()
         
     if legal_machine?
       #do not stop db
       #show error
       if simul_started?
         puts "Simulation already started"
       else 
            
        #start simulation in ruby lib folder
         
        Dir.chdir(@shm_ruby_lib)  
         
        sys "#{@jruby_exec} simul_two_subtrees.rb #{@short_machine} #{@test_suit} > run.log &"
        Dir.chdir(@admin_folder)
       end

     else
      puts "Wrong machine!"          
     end
   end


  #collect one simul
   def collect_one_simul()

     if legal_machine?
       #do not stop db
       #show error
       if simul_started?
         puts "Wait for simulation to finish !"
       else 
        #collect simulation in master's result folder
        sys "cp #{@shm_files_folder}/#{@short_machine}_#{@test_suit}.csv #{@proj_results_folder}/"  
       end

     else
      puts "Wrong machine!"          
     end
   end


  #stop all simulations
  def stop_all_simul()

   @machines.each_key { |m|
    puts "machine: #{m}"
    Net::SSH.start(m, "abdiallo") { |ssh|
     #delegate to one script
     result = ssh.exec!("#{ENV['JRUBY_HOME']}/bin/jruby #{@admin_folder}/spadm.rb --component simul --action stop --level one")
     puts result
    }
   }

  end

  #start all simulations
  def start_all_simul()

   @machines.each_key { |m|
    puts "mmachine: #{m}"
    
    Net::SSH.start(m, "abdiallo") { |ssh|
     #delegate to one script 
     ssh.exec!("source ~/.bash_profile")
     result = ssh.exec!("#{ENV['JRUBY_HOME']}/bin/jruby #{@admin_folder}/spadm.rb --component simul --action start --level one")
     puts result
    }
   }

  end


  #collect all simulations
  def collect_all_simul()
   @machines.each_key { |m|
    puts "machine: #{m}"
    Net::SSH.start(m, "abdiallo") { |ssh|
     #delegate to one script
     result = ssh.exec!("#{ENV['JRUBY_HOME']}/bin/jruby #{@admin_folder}/spadm.rb --component simul --action collect --level one")
     puts result
    }
   }

  end





  def check_db_progress()

  #check db progress
 
   @machines.each_key { |m|
    Net::SSH.start(m, "abdiallo") { |ssh|
     #delegate to one script
      res = `echo \"connect 'jdbc:derby://#{m}:1527/simul_ruby_db';select count(*) from simul_test_elem;\" | /home/abdiallo/dunarel/simul_ruby/db/derby/bin/ij`
   
      res =~ /-+\s*(\d+)/
      nb_tests = $1.chomp
      puts "machine: #{m}, nb_tests: #{nb_tests}"

    }
   }

  end





 end


  #task distribution
  spadm = Spadm.new()
  #shm
  if options[:component] == "shm" and
     options[:action] == "delete" and
     options[:level] == "one" then
   spadm.del_one_proj2shm() 
  elsif options[:component] == "shm" and
     options[:action] == "deploy" and
     options[:level] == "one" then
   spadm.dep_one_proj2shm() 
  elsif options[:component] == "shm" and
     options[:action] == "delete" and
     options[:level] == "all" then
   spadm.del_all_proj2shm()
  elsif options[:component] == "shm" and
     options[:action] == "deploy" and
     options[:level] == "all" then
   spadm.dep_all_proj2shm()
    
  end

  #database
  if options[:component] == "derby" and
     options[:action] == "stop" and
     options[:level] == "one" then
   spadm.stop_one_db() 
  elsif options[:component] == "derby" and
     options[:action] == "start" and
     options[:level] == "one" then
   spadm.start_one_db() 
  elsif options[:component] == "derby" and
     options[:action] == "stop" and
     options[:level] == "all" then
   spadm.stop_all_db()
  elsif options[:component] == "derby" and
     options[:action] == "start" and
     options[:level] == "all" then
   spadm.start_all_db()
    
  end

  #simul
  if options[:component] == "simul" and
     options[:action] == "stop" and
     options[:level] == "one" then
   spadm.stop_one_simul() 
  elsif options[:component] == "simul" and
     options[:action] == "start" and
     options[:level] == "one" then
   spadm.start_one_simul() 
  elsif options[:component] == "simul" and
     options[:action] == "stop" and
     options[:level] == "all" then
   spadm.stop_all_simul()
  elsif options[:component] == "simul" and
     options[:action] == "start" and
     options[:level] == "all" then
     spadm.start_all_simul()
  elsif options[:component] == "simul" and
     options[:action] == "collect" and
     options[:level] == "one" then
   spadm.collect_one_simul()
  elsif options[:component] == "simul" and
     options[:action] == "collect" and
     options[:level] == "all" then
   spadm.collect_all_simul()

  end

    if options[:run]
      #run
      spadm.dep_all_proj2shm()
      spadm.start_all_db()
      spadm.start_all_simul()

    end

    if options[:get]
      #get
      spadm.collect_all_simul()

    end

    if options[:close]
      #erase
      spadm.stop_all_simul()
      spadm.stop_all_db()
      spadm.del_all_proj2shm()
    end
      
    if options[:finished]
      #check if all simulations finished (terminated)
      puts "All finished ?: #{spadm.finished_all_simul?}"
    end

    if options[:dbclient]
      #start dbclient
      Dir.chdir("#{spadm.admin_folder}/dbclient")
      sys "java -jar ./run.jar &"
      Dir.chdir(spadm.admin_folder)
    end

    if options[:check_progress]
      spadm.check_db_progress()
    end
      
   

