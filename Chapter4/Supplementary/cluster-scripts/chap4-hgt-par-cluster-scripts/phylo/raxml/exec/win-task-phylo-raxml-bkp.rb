#!/home/badescud/local/bin/ruby 

 require 'rubygems'
 require 'optparse'
 require '../../../../lib/local-config.rb'
 require 'posix/spawn'


class WinTask
  include POSIX::Spawn

  def initialize
    puts "in Class.initialize..."
    extend LocalConfig
    init()
  end
  def init
    #puts "in Class.init, last called after all extensions"
  end

  def execute
   #calculate best tree
   cmd = "../../../../exec/raxml -T #{self.opt_threads} -m GTRGAMMA -# 20 -s fen_align.phy -n fen_align.tr"
   puts cmd
   #pid = Kernel.spawn(cmd, {:out => "raxml1.log"})
   pid = spawn(cmd, {:out => "raxml1.log"})
   Process.wait(pid)
   sleep 5
   
   #calculate bootstraps
   cmd = "../../../../exec/raxml -T #{self.opt_threads} -m GTRGAMMA -b 12345 -# 100 -s fen_align.phy -n fen_align.bs -k"
   puts cmd
   pid = spawn(cmd, {:out => "raxml2.log"})
   Process.wait(pid)
   sleep 5
    
   #annotate best tree
   cmd = "../../../../exec/raxml -T 2 -m GTRGAMMA -f b -t RAxML_bestTree.fen_align.tr -z RAxML_bootstrap.fen_align.bs -n fen_align.re"
   puts cmd
   pid = spawn(cmd, {:out => "raxml3.log"})
   Process.wait(pid)
   sleep 5
    
   
  end
  


end


  puts `pwd`
 
  wt = WinTask.new
  wt.execute

  
 #Process.setpriority(Process::PRIO_PROCESS, 0, -2)

 #puts Process.getpriority(Process::PRIO_USER, 0)   
 #puts Process.getpriority(Process::PRIO_PROCESS, 0) 


 #b_sec = rand(5...20)
 #uts "sleep to nb_sec: #{nb_sec}"

  #leep nb_sec
 


# 10.times.map{ 20 + Random.rand(11) }





#calculate 100 bootstraps
#../raxml -T 24 -m GTRGAMMA -b 12345 -# 100 -s ../msa/$gene.phy -n $gene.bs -k
#put replicates on tree
#../raxml -T 24 -m GTRGAMMA -f b -t RAxML_bestTree.$gene.tr -z RAxML_bootstrap.$gene.bs -n $gene.re
