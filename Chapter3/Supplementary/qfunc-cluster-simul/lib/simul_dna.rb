require 'simul_frame'

module UqamDoc
  
  class SimulDna < SimulFrame
    
    def initialize()
      super
      #specific to this class
      @align_type = "dna"
      @dist = "ham"
    end
    
    
     def set_simulation_default_run_parameters()
      
      #test ident
      @test_ident = :default
      #simulation parameters
      @nb_replic = 5
      @nb_species = 16
      @lv0_length = 440 # 21 *6
      @lv3_length = 21
      @insert_point = 60
      @scaling_factor0 = 1
      @scaling_factor1 = 1
      @scaling_factor2 = 1
    end
    
    def set_q_func_default_run_parameters()
      #run parameters
      @win_width = 21
      @win_step = 1
      @f_opt_max = 6
      @f_disp_max = 6
    end
    
      def set_start_seqs_and_evol_params()
      
      #anc_seq0 = @@ud.get_uniform_seq("G", @lv0_length)
      #anc_seq1 = @@ud.get_uniform_seq("A", @lv3_length)
      #anc_seq2 = @@ud.get_uniform_seq("A", @lv3_length)
      
      
      @anc_seq0 = @@ud.get_random_seq_na(@lv0_length).upcase
      #puts @anc_seq0
      @anc_seq1 = @@ud.get_random_seq_na(@lv3_length).upcase
      @anc_seq2 =@anc_seq1
      #@anc_seq2 = @@ud.get_random_seq_na(@lv3_length).upcase
      
      #evolution model parameters
      #@seqgen_par0 = "-q -mHKY -t0.1 -f0.25,0.25,0.25,0.25"
      #@seqgen_par1 = "-q -mHKY -t1.0 -f0.2978,0.2074,0.2764,0.2184"
      #@seqgen_par2 = "-q -mHKY -t0.1 -f0.2440,0.2616,0.3233,0.1711"
      @seqgen_par0 = "-q -mGTR"
      @seqgen_par1 = "-q -mGTR"
      @seqgen_par2 = "-q -mGTR"
      
      
      #puts @anc_seq0,@anc_seq0.length()
      #puts @anc_seq1,@anc_seq1.length()
      #puts @anc_seq2,@anc_seq2.length()
      
    end
    
    def q_func_exec()
      #q_func_execution
      opt = "--calc_type #{@calc_type} --f_opt_max #{@f_opt_max} --align_type #{@align_type} --dist #{@dist} --winl #{@win_width} --win_step #{@win_step} --optim #{@optim}"
      cmd =  "#{@q_func_prog_exec} --msa_fasta #{@msa_fasta}  --x_ident_csv #{@x_ident_csv} --q_func_csv #{@q_func_csv} #{opt}"
      puts "#{cmd}"
      sys cmd
      
    end
    
  
     #variable @scaling_factor0
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
      
       (4..4).each  {|func_no|
        
        rng.each {|rng_param|
          puts func_no,rng_param
          @f_opt_max = func_no
          @scaling_factor0 = rng_param
          test_replic()
          #output_values()
          
        }
        
      }
      
    end
    
    #variable @scaling_factor1
    def test2()
      
      @simul_test = @simul_suite.simul_test.create(:test_ident => "test2")
      
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
      
       (1..4).each  {|func_no|
        
        rng.each {|rng_param|
          puts func_no,rng_param
          @f_opt_max = func_no
          @scaling_factor1 = rng_param
          @scaling_factor2 = rng_param
          test_replic()
          #output_values()
          
        }
        
      }
      
    end
    
    #variable @scaling_factor1 and 2
    def test3()
      
      @simul_test = @simul_suite.simul_test.create(:test_ident => "test3")
      
      #default
      @scaling_factor0 = 0.5
      @scaling_factor1 = 1
      @scaling_factor2 = 1
      @calc_type = "simple" #auto/simple
      @optim = "km"
      
      #prepare range
      rng1  = []
      rng2 = []
      
       (0..19).each { |i|
        rng1 << 0.5 - i*0.025
        rng2 << 0.5 + i*0.025
        
      }
      #rng = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8 , 0.9, 1]
      
      puts rng1.inspect()
      puts rng2.inspect()
      
      
       (1..4).each  {|func_no|
        
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
    
    #variable @scaling_factor0
    #only function 4
    def test4()
      
      @simul_test = @simul_suite.simul_test.create(:test_ident => "test4")
      
      #default
      @scaling_factor0 = 1
      @scaling_factor1 = 1
      @scaling_factor2 = 1
      @calc_type = "auto"
      @optim = 'nj'
      
      #prepare range
      rng = []
       (1..20).each { |i| rng << i*0.05}
      #rng = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8 , 0.9, 1]
      
      puts rng.inspect()
      
       (4..4).each  {|func_no|
        
        rng.each {|rng_param|
          puts func_no,rng_param
          @f_opt_max = func_no
          @scaling_factor0 = rng_param
          test_replic()
          #output_values()
          
        }
        
      }
      
    end
    
    #variable @scaling_factor1
    def test5()
      
      @simul_test = @simul_suite.simul_test.create(:test_ident => "test5")
      
      #default
      @scaling_factor0 = 1
      @scaling_factor1 = 1
      @scaling_factor2 = 1
      @calc_type = "auto"
      @optim = "km"
      @f_disp_max = 6
      
      
      #prepare range
      rng = []
       (1..20).each { |i| rng << i*0.05}
      #rng = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8 , 0.9, 1]
      
      puts rng.inspect()
      
       (6..6).each  {|func_no|
        
        rng.each {|rng_param|
          puts func_no,rng_param
          @f_opt_max = func_no
          @scaling_factor1 = rng_param
          @scaling_factor2 = rng_param
          test_replic()
          #output_values()
          
        }
        
      }
      
    end
    
    #####66666666666666666666666666666666666666666666666666666666666666666666666666666666666666
    def test6()
      
      @simul_test = @simul_suite.simul_test.create(:test_ident => "test6")
      
      #default
      @scaling_factor0 = 0.5
      @scaling_factor1 = 1.0
      @scaling_factor2 = 1.0
      @calc_type = "auto" #auto/simple
      @optim = "km"
      @f_disp_max = 6
      @tree_type = TreeType::POLYPHYLETIC
      
      
      #prepare range
      rng1  = []
      rng2 = []
      
       (0..19).each { |i|
        rng1 << 0.5 - i*0.025
        rng2 << 0.5 + i*0.025
        
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
      @scaling_factor0 = 0.5
      @scaling_factor1 = 1.0
      @scaling_factor2 = 1.0
      @calc_type = "auto" #auto/simple
      @optim = "km"
      @f_disp_max = 6
      @tree_type = TreeType::MONOPHYLETIC
      
      
      #prepare range
      rng1  = []
      rng2 = []
      
       (0..19).each { |i|
        rng1 << 0.5 - i*0.025
        rng2 << 0.5 + i*0.025
        
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


    #variable @scaling_factor0
    def test8()
      
      @simul_test = @simul_suite.simul_test.create(:test_ident => "test8")
      
      #default
      @scaling_factor0 = 1
      @scaling_factor1 = 1
      @scaling_factor2 = 1
      @calc_type = "auto"
      @optim = 'km'
      @f_disp_max = 6
      @tree_type = TreeType::POLYPHYLETIC
      
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

    #variable @scaling_factor0
    def test9()
      
      @simul_test = @simul_suite.simul_test.create(:test_ident => "test9")
      
      #default
      @scaling_factor0 = 1
      @scaling_factor1 = 1
      @scaling_factor2 = 1
      @calc_type = "auto"
      @optim = 'km'
      @f_disp_max = 6
      @tree_type = TreeType::MONOPHYLETIC
      
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

 #555555555555555555555555555555555555555555555555555555555555555555555
    #
    def test10()
      
      @simul_test = @simul_suite.simul_test.create(:test_ident => "test10")
      
      #default
      @scaling_factor0 = 0.5
      @scaling_factor1 = 1.0
      @scaling_factor2 = 1.0
      @calc_type = "auto" #auto/simple
      @optim = "km"
      @f_disp_max = 5
      @tree_type = TreeType::POLYPHYLETIC
      
      
      #prepare range
      rng1  = []
      rng2 = []
      
       (0..19).each { |i|
        rng1 << 0.5 - i*0.025
        rng2 << 0.5 + i*0.025
        
      }
      #rng = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8 , 0.9, 1]
      
      puts rng1.inspect()
      puts rng2.inspect()
      
      
       (5..5).each  {|func_no|
        
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
    
    def test11()
      
      @simul_test = @simul_suite.simul_test.create(:test_ident => "test11")
      
      #default
      @scaling_factor0 = 0.5
      @scaling_factor1 = 1.0
      @scaling_factor2 = 1.0
      @calc_type = "auto" #auto/simple
      @optim = "km"
      @f_disp_max = 5
      @tree_type = TreeType::MONOPHYLETIC
      
      
      #prepare range
      rng1  = []
      rng2 = []
      
       (0..19).each { |i|
        rng1 << 0.5 - i*0.025
        rng2 << 0.5 + i*0.025
        
      }
      #rng = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8 , 0.9, 1]
      
      puts rng1.inspect()
      puts rng2.inspect()
      
      
       (5..5).each  {|func_no|
        
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


    #variable @scaling_factor0
    def test12()
      
      @simul_test = @simul_suite.simul_test.create(:test_ident => "test12")
      
      #default
      @scaling_factor0 = 1
      @scaling_factor1 = 1
      @scaling_factor2 = 1
      @calc_type = "auto"
      @optim = 'km'
      @f_disp_max = 5
      @tree_type = TreeType::POLYPHYLETIC
      
      #prepare range
      rng = []
       (1..20).each { |i| rng << i*0.05}
      #rng = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8 , 0.9, 1]
      
      puts rng.inspect()
      
       (5..5).each  {|func_no|
        
        rng.each {|rng_param|
          puts func_no,rng_param
          @f_opt_max = func_no
          @scaling_factor0 = rng_param
          test_replic()
          #output_values()
          
        }
        
      }
      
    end

   #variable @scaling_factor0
    def test13()
      
      @simul_test = @simul_suite.simul_test.create(:test_ident => "test13")
      
      #default
      @scaling_factor0 = 1
      @scaling_factor1 = 1
      @scaling_factor2 = 1
      @calc_type = "auto"
      @optim = 'km'
      @f_disp_max = 5
      @tree_type = TreeType::MONOPHYLETIC
      
      #prepare range
      rng = []
       (1..20).each { |i| rng << i*0.05}
      #rng = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8 , 0.9, 1]
      
      puts rng.inspect()
      
       (5..5).each  {|func_no|
        
        rng.each {|rng_param|
          puts func_no,rng_param
          @f_opt_max = func_no
          @scaling_factor0 = rng_param
          test_replic()
          #output_values()
          
        }
        
      }
      
    end
   #44444444444444444444444444444444444444444444444444444444444444444444444444444444444444444444
    #
    def test14()
      
      @simul_test = @simul_suite.simul_test.create(:test_ident => "test14")
      
      #default
      @scaling_factor0 = 0.5
      @scaling_factor1 = 1.0
      @scaling_factor2 = 1.0
      @calc_type = "auto" #auto/simple
      @optim = "km"
      @f_disp_max = 4
      @tree_type = TreeType::POLYPHYLETIC
      
      
      #prepare range
      rng1  = []
      rng2 = []
      
       (0..19).each { |i|
        rng1 << 0.5 - i*0.025
        rng2 << 0.5 + i*0.025
        
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
    
    def test15()
      
      @simul_test = @simul_suite.simul_test.create(:test_ident => "test15")
      
      #default
      @scaling_factor0 = 0.5
      @scaling_factor1 = 1.0
      @scaling_factor2 = 1.0
      @calc_type = "auto" #auto/simple
      @optim = "km"
      @f_disp_max = 4
      @tree_type = TreeType::MONOPHYLETIC
      
      
      #prepare range
      rng1  = []
      rng2 = []
      
       (0..19).each { |i|
        rng1 << 0.5 - i*0.025
        rng2 << 0.5 + i*0.025
        
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


    #variable @scaling_factor0
    def test16()
      
      @simul_test = @simul_suite.simul_test.create(:test_ident => "test16")
      
      #default
      @scaling_factor0 = 1
      @scaling_factor1 = 1
      @scaling_factor2 = 1
      @calc_type = "auto"
      @optim = 'km'
      @f_disp_max = 4
      @tree_type = TreeType::POLYPHYLETIC
      
      #prepare range
      rng = []
       (1..20).each { |i| rng << i*0.05}
      #rng = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8 , 0.9, 1]
      
      puts rng.inspect()
      
       (4..4).each  {|func_no|
        
        rng.each {|rng_param|
          puts func_no,rng_param
          @f_opt_max = func_no
          @scaling_factor0 = rng_param
          test_replic()
          #output_values()
          
        }
        
      }
      
    end
    
    #variable @scaling_factor0
    def test17()
      
      @simul_test = @simul_suite.simul_test.create(:test_ident => "test17")
      
      #default
      @scaling_factor0 = 1
      @scaling_factor1 = 1
      @scaling_factor2 = 1
      @calc_type = "auto"
      @optim = 'km'
      @f_disp_max = 4
      @tree_type = TreeType::MONOPHYLETIC
      
      #prepare range
      rng = []
       (1..20).each { |i| rng << i*0.05}
      #rng = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8 , 0.9, 1]
      
      puts rng.inspect()
      
       (4..4).each  {|func_no|
        
        rng.each {|rng_param|
          puts func_no,rng_param
          @f_opt_max = func_no
          @scaling_factor0 = rng_param
          test_replic()
          #output_values()
          
        }
        
      }
      
    end

    #variable @scaling_factor0
    def test_debug()
      
      @simul_test = @simul_suite.simul_test.create(:test_ident => "test_debug")
      
      #default
      @scaling_factor0 = 1
      @scaling_factor1 = 1
      @scaling_factor2 = 1
      @calc_type = "auto"
      @optim = 'km'
      @f_disp_max = 4
      @tree_type = TreeType::POLYPHYLETIC
      
      #prepare range
      rng = []
       (9..12).each { |i| rng << i*0.05}
      #rng = [0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8 , 0.9, 1]
      
      puts rng.inspect()
      
       (4..4).each  {|func_no|
        
        rng.each {|rng_param|
          puts func_no,rng_param
          @f_opt_max = func_no
          @scaling_factor0 = rng_param
          test_replic()
          #output_values()
          
        }
        
      }
      
    end


######################################################################################














  end
  
end
