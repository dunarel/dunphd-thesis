#!/home/badescud/local/bin/ruby 

 #Task Scheduler
 #Dunarel Badescu 2013, april 

 require 'yaml'
 require 'ostruct'
 require 'optparse'
 require '../lib/local-config.rb'
 require 'posix/spawn'  

 class SchedJobs 
  include POSIX::Spawn

  def initialize
    puts "in Class.initialize..."
    extend LocalConfig
    init()

    @raised_echild_arr = []
    @finished_child_arr = []
    @task_fen_h = {}
    
  end
  def init
    #puts "in Class.init, last called after all extensions"
  end


  #jobs from execution folder jobs
  def load_jobs

    
    jobs_f = "#{self.sdir}/jobs/job-tasks-#{self.job_s}.yaml" 
    puts "jobs_f: #{jobs_f}"

    jobs_yaml = File.read(jobs_f)
    
    jobs_yaml = jobs_yaml.gsub("!ruby/object:HgtParFen","")
    #puts jobs_yaml
   

    @jobs = YAML.load(jobs_yaml)

    puts @jobs.inspect    

    @jobs_nb = @jobs.length
  
    puts "@jobs_nb = #{@jobs_nb}"
  end

  #with system calls
  def count_run_procs
     run_procs = 0
     @spawned_tasks.delete_if { |st|
         
         begin
          st_res = Process.waitpid(st, Process::WNOHANG)
          #puts "st: #{st}, st_res: #{st_res}"
          if st_res.nil?
            run_procs += 1
            #keep
            false
          else
            @finished_child_arr << st
            #unregister fen
            fen_d = @task_fen_h.delete st
            puts "Finished: #{st}, #{fen_d}"
            #mark active task for deletion
            true 
          end
         rescue Errno::ECHILD
            puts "Unclean task removal"
            @finished_child_arr << st
            #unregister fen
            fen_d = @task_fen_h.delete st
            puts "Finished: #{st}, #{fen_d}"
            #mark active task for deletion
            true 
        end

        }

    puts "run_procs: #{run_procs}"
    return run_procs

  end

 
  #folders from execution folder work
  def launch_jobs

    puts "self.opt_procs: #{self.opt_procs}"

   #grpid = Process.getpgrp   
   #pid = Process.ppid

    #puts "pid: #{pid}, grpid: #{grpid}"

    @spawned_tasks = []
    @jobs.each_with_index {|it, idx|

      it = it["attributes"]

      puts "idx: #{idx}, it: #{it.inspect}"        

      fen_n = Pathname.new "#{it["name"]}/#{it["win_size"]}/#{it["fen_no"]}-#{it["fen_idx_min"]}-#{it["fen_idx_max"]}"

      fen_d = self.sdir + Pathname.new("work") + fen_n
      
      puts "fen_n: #{fen_n}, fen_d: #{fen_d.inspect}"
     

      
      #wait until possible to spawn
      until count_run_procs  < self.opt_procs
       #time to wait for next check
       sleep 2
      end

      #skip if fen already calculated
      #or uncalculable
      fen_d_res = self.sdir + Pathname.new("results") + fen_n
      
      fin_f = fen_d_res + @config_yml["finished_file"]
      started_f = fen_d_res + @config_yml["started_file"]
      
      #puts "started_f: #{started_f}"
      #puts "fin_f: #{fin_f}"
                
      if fin_f.exist?
       puts "Already calculated !"
       next
      elsif started_f.exist? and started_f.read =~ /^ERROR:.*entirely\sof\sundetermined\svalues/
       puts "Uncalculable !"
       next
      end 
      
       
      #spawn current task
      puts "before spawn_one_task..."
      spwn_tsk = spawn_one_task(fen_d)
      puts "after  spawn_one_task... spwn_tsk: #{spwn_tsk}"
      #register task
      @spawned_tasks << spwn_tsk
      #register fen
      @task_fen_h[spwn_tsk] = fen_d
      @spawned_tasks.each { |st|
        puts "spawned_task: #{st}, #{@task_fen_h[st]}"
      }
      
      #puts "@raised_echild_arr: #{@raised_echild_arr}"
      #puts "@finished_child_arr: #{@finished_child_arr}"
    }
    puts "finished launching jobs!"
 

  end

  #from execution folder exec, win_task.rb
  def spawn_one_task(fen_d)
    puts "in spawn_one_task"   
    puts "fen_d: #{fen_d}"

    cmd = "#{self.sdir}/exec/win-task-#{@config_yml["stage"]}-#{@config_yml["phylo_prog"]}.rb --threads #{self.opt_threads}"
    puts cmd
    pid = spawn(cmd, {:chdir => fen_d.to_s, :out => "sched-jobs.log"})   
    puts "ending spawn_one_task"

    return pid
  end

 end
 

  #Main 
  sj = SchedJobs.new
  sj.load_jobs
  sj.launch_jobs

  #wait for all child processes to finish
  puts "wait for all child processes to finish..."
  Process.waitall
  puts "OK, all done!"
  sleep 5

 
  
