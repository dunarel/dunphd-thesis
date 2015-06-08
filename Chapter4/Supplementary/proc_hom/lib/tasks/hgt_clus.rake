require 'hgt'

namespace :hgt_clus  do


  #SqlInfin
  SqlInfin = 2147483647

  desc "default job"
  task :default, [:thres] => :environment do |task, args|
    puts "running default job"

    hg=Hgt.new 
    
    hg.calc_section = :synth
    hg.phylo_prog = "raxml"
    
    
    hg.hgt_type = :regular
    hg.thres = args.thres.to_i
    
    hg.calc_type = :rel
        
    hg.gn_tt_min_th = 7
    
     [:family,:habitat].each {|crit|
     #[:family].each {|crit|
      hg.crit = crit  
      hg.exp_tt_gr_hg()
     }
    
    
   


  end

  task :hgt_tot => :environment do
    puts "running hgt_tot job"

    hg=Hgt.new :hgt_tot
    
    hg.calc_section = :synth
    hg.phylo_prog = "raxml"
    
    
    hg.hgt_type = :regular
    hg.thres = 75
    
    hg.calc_type = :rel
        
    hg.gn_tt_min_th = 7
    
     [:family,:habitat].each {|crit|
      hg.crit = crit  
      hg.exp_tt_gr_hg()
     }
    
    
    
    
    
    


  end
  
end

