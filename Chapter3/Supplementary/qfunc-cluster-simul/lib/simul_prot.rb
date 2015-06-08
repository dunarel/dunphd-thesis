require 'simul_frame'

module UqamDoc
  
  class SimulProt < SimulFrame
    
     def initialize()
      super
      #specific to this class
      @align_type = "prot"
      @dist = "scoredist"
    end
    
    def set_simulation_default_run_parameters()
      
      #test ident
      @test_ident = :default
      #simulation parameters
      @nb_replic = 50
      @nb_species = 16
      @lv0_length = 42 # 7 *6
      @lv3_length = 7
      @insert_point = 20
      @scaling_factor0 = 1
      @scaling_factor1 = 1
      @scaling_factor2 = 1
    end
    
    
    def set_q_func_default_run_parameters()
      #run parameters
      @win_width = 7
      @win_step = 1
      @f_opt_max = 6
      @f_disp_max = 6
      @protmatrix = "blosum62"
    end
    
    def set_start_seqs_and_evol_params()
      
     
      
      @anc_seq0 = @@ud.get_random_seq_na(@lv0_length).upcase
      #puts @anc_seq0
      @anc_seq1 = @@ud.get_random_seq_na(@lv3_length).upcase
      @anc_seq2 =@anc_seq1
      #@anc_seq2 = @@ud.get_random_seq_na(@lv3_length).upcase
      
      @seqgen_par0 = "-q -mBLOSUM"
      @seqgen_par1 = "-q -mBLOSUM"
      @seqgen_par2 = "-q -mBLOSUM"
      
      
      #puts @anc_seq0,@anc_seq0.length()
      #puts @anc_seq1,@anc_seq1.length()
      #puts @anc_seq2,@anc_seq2.length()
      
    end
    
    def q_func_exec()
      #q_func_execution
      opt = "--calc_type #{@calc_type} --f_opt_max #{@f_opt_max} --align_type #{@align_type} --dist #{@dist} --winl #{@win_width} --win_step #{@win_step} --optim #{@optim} --protmatrix #{@protmatrix} "
      cmd =  "#{@q_func_prog_exec} --msa_fasta #{@msa_fasta}  --x_ident_csv #{@x_ident_csv} --q_func_csv #{@q_func_csv} #{opt}"
      puts "#{cmd}"
      sys cmd
      
    end
    
     def test1()
      
      @simul_test = @simul_suite.simul_test.create(:test_ident => "test1")
      
      #default
      @scaling_factor0 = 1
      @scaling_factor1 = 1
      @scaling_factor2 = 1
      @calc_type = "simple" #auto/simple
      @optim = "km"
      
      #prepare range
      rng = []
       (1..20).each { |i| rng << i*0.05}
      #rng = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8 , 0.9, 1]
      
      puts rng.inspect()
      
       (6..6).each  {|func_no|
        
        rng.each {|rng_param|
          puts func_no,rng_param
          @f_opt_max = func_no
          @scaling_factor0 = rng_param
          test_replic()
          #output_values()
          
        }
        
      }
      
    end
    
    
    
    
    #
    def test6()
      
      @simul_test = @simul_suite.simul_test.create(:test_ident => "test6")
      
      #default
      @scaling_factor0 = 0.5
      @scaling_factor1 = 1
      @scaling_factor2 = 1
      
      @calc_type = "auto" #auto/simple
      @optim = "km"
     
      
      #prepare range
      rng1  = []
      rng2 = []
      
       (0..19).each { |i|
        rng1 << 0.5 - i*0.05
        rng2 << 0.5 + i*0.05
        
      }
      #rng = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8 , 0.9, 1]
      
      puts rng1.inspect()
      puts rng2.inspect()
      
      
       (6..6).each  {|func_no|
        
         (0..19).each {|i|
          # puts func_no,rng_param
          @f_opt_max = func_no
          @scaling_factor1 = rng1[i]
          @scaling_factor2 = rng2[i]
          test_replic()
          #output_values()
          
        }
        
      }
      
    end
    
    def test7()
      
      @simul_test = @simul_suite.simul_test.create(:test_ident => "test7")
      
      #default
      @scaling_factor0 = 1
      @scaling_factor1 = 1
      @scaling_factor2 = 1
      
      @calc_type = "auto" #auto/simple
      @optim = "nj"
      
      #prepare range
      rng1  = []
      rng2 = []
      
       (0..19).each { |i|
        rng1 << 1 - i*0.05
        rng2 << 1 + i*0.05
        
      }
      #rng = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8 , 0.9, 1]
      
      puts rng1.inspect()
      puts rng2.inspect()
      
      
       (4..4).each  {|func_no|
        
         (0..19).each {|i|
          # puts func_no,rng_param
          @f_opt_max = func_no
          @scaling_factor1 = rng1[i]
          @scaling_factor2 = rng2[i]
          test_replic()
          #output_values()
          
        }
        
      }
      
    end
    
     def test8()
      
      @simul_test = @simul_suite.simul_test.create(:test_ident => "test8")
      
      #default
      @scaling_factor0 = 2
      @scaling_factor1 = 2
      @scaling_factor2 = 2
      
      @calc_type = "simple" #auto/simple
      @optim = "km"
      
      #prepare range
      rng1  = []
      rng2 = []
      
       (0..19).each { |i|
        #rng1 << 1 - i*0.05
        rng2 << 0.5 + 2* i*0.05
        
      }
      #rng = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8 , 0.9, 1]
      
      #puts rng1.inspect()
      puts rng2.inspect()
      
      
       (4..4).each  {|func_no|
        
         (0..19).each {|i|
          # puts func_no,rng_param
          @f_opt_max = func_no
          @scaling_factor1 = rng2[i]
          @scaling_factor2 = rng2[i]
          test_replic()
          #output_values()
          
        }
        
      }
      
    end
    
    
    
    
  end
  
end