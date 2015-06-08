
require 'output_unrooted_patch'
require 'msa_tools_v2'
require 'ar_tests'
require 'ruby_checks'

require 'rubygems'
require 'bio'
#require 'bio/tree'
require 'faster_csv'

class TreeType
  MONOPHYLETIC=1
  POLYPHYLETIC=2
end



module UqamDoc
  
  
  class SimulFrame
    
    
=begin
    
    #replicates
    attr_accessor :nb_replic
    #trees
    attr_accessor :lv0_tree_file, :t0,:t1,:t2

    #simulation parameters
    attr_accessor :nb_species,
      :lv0_length,
      :lv3_length,
      :insert_point,
      :scaling_factor0,
      :scaling_factor1,
      :scaling_factor2

    attr_accessor :q_func_csv,:q_func_prog_exec,
      :proj_folder,:create_tree_folder,
      :create_tree_exec,
      :msa_fasta,:x_ident_csv
    attr_accessor :f_opt_max,:win_width , :win_step
    #seq-gen location
    attr_accessor :seqgen_prog_folder,:seqgen_prog_exec
    #ancestor seqs
    attr_accessor :anc_seq0,:anc_seq1,:anc_seq2
    #seqgen_params
    attr_accessor :seqgen_par0,:seqgen_par1,:seqgen_par2
    #seq-gen input files
    attr_accessor :lv0_sgen_in_file,:lv1_sgen_in_file,:lv2_sgen_in_file
    #seq-gen output files
    attr_accessor :lv0_sgen_out_file,:lv1_sgen_out_file,:lv2_sgen_out_file
    #seq-gen alignments
    attr_accessor :lv0_align,:lv1_align,:lv2_align,
      :lv3_align
    #mutated alignment
    attr_accessor :lv3_fasta_file,:sm3_fasta_file
    #results file
    attr_accessor :simul_results_csv,:simul_results_hdl
=end
    
    attr_accessor :calc_type,
      :debug_level
    
    public
    
    def initialize()
      @debug_level = 0
      #file locations
      @create_tree_prog_folder = "#{$project_folder}/create_tree"
      @create_tree_prog_exec = "#{@create_tree_prog_folder}/createTree"
      #project folder
      @files_folder = "#{$project_folder}/files"
      
      #trees

      @tree_type = TreeType::POLYPHYLETIC;

      @lv0_tree_file = "#{@create_tree_prog_folder}/species_unrooted.new"
      @lv0_rooted_tree_file = "#{@create_tree_prog_folder}/species_rooted.new"

      #seq-gen location
      @seqgen_prog_folder = "#{$project_folder}/seqgen"
      @seqgen_prog_exec = "#{@seqgen_prog_folder}/seq-gen"

      #seq-gen input files
      @lv0_sgen_in_file = "#{@files_folder}/species_unrooted.nw"
      @lv1_sgen_in_file = "#{@files_folder}/lv1.nw"
      @lv2_sgen_in_file = "#{@files_folder}/lv2.nw"
      #seq_gen output files
      @lv0_sgen_out_file = "#{@files_folder}/species_unrooted.dat"
      @lv1_sgen_out_file = "#{@files_folder}/lv1.dat"
      @lv2_sgen_out_file = "#{@files_folder}/lv2.dat"
      
      #lv3 is the concatenated lv1+lv2
      @lv3_fasta_file = "#{@files_folder}/lv3.fa"
      #sm3 is the modified
      @sm3_fasta_file = "#{@files_folder}/sm3.fa"
      
      #
      @q_func_prog_folder = "#{$project_folder}/bin"
      @q_func_prog_exec = "#{@q_func_prog_folder}/q_funcb"
      
      
      @msa_fasta = "#{@files_folder}/sm3.fa"
      @x_ident_csv = "#{@files_folder}/x_ident_test.csv"
      #q_func result file
      @q_func_csv = "#{@files_folder}/q_auto_test.csv"
      #q_func options
      
      #tested values
      @lv_q_func_ratio = 0
      @lv_rand_ratio = 0
      #averages
      @lv_q_func_ratio_avg = 0
      @lv_rand_ratio_avg = 0
      #results
      @results_folder = "#{@files_folder}"
      #@simul_results_csv = "#{@results_folder}/simul_results.csv"
      
      
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
    
    
    
    #create random tree
    def create_random_tree()
      
      Dir.chdir(@create_tree_prog_folder)
      puts `#{@create_tree_prog_exec} #{@nb_species}`
      puts Dir.pwd  #unless debug_level <=0
      puts "ok"
    end
    
    #read tree
    def read_tree()
      str = @@ud.get_file_as_string(@lv0_tree_file)
      puts "tree: #{str}"  unless debug_level <=0
      
      
      @t0 = Bio::Newick.new(str, nil).tree
      
    end

    def read_rooted_tree()
      str = @@ud.get_file_as_string(@lv0_rooted_tree_file)
      puts "tree: #{str}"  unless debug_level <=0


      @t0 = Bio::Newick.new(str, nil).tree

    end


    
    def show_nodes()
      lv = @t0.leaves()
      lv.each {|n| puts "node: >#{@t0.get_node_name(n)}<"}
    end

    def extract_subtree_left()
      head_children = []
      head_children = @t0.children(@t0.root)
      lv1_nodes = @t0.leaves(head_children[0])

      puts "head_children: #{head_children.inspect}"
      puts "lv1_nodes: #{lv1_nodes.inspect}"
      #extract tree
      @t1 = @t0.subtree_with_all_paths(lv1_nodes)
      @t1.remove_nonsense_nodes()
      #
      puts "t1.output_unrooted(): #{@t1.output_unrooted()}"
      puts "t1 number_of_nodes: #{@t1.number_of_nodes()}"
      puts "t1 number_of_edges: #{@t1.number_of_edges()}"

    end


    def extract_subtree_right()
      head_children = []
      head_children = @t0.children(@t0.root)
      lv2_nodes = @t0.leaves(head_children[1])
      #extract tree
      @t2 = @t0.subtree_with_all_paths(lv2_nodes)
      @t2.remove_nonsense_nodes()
      #
      puts "t2.output_unrooted(): #{@t2.output_unrooted()}"
      puts "t2 number_of_nodes: #{@t2.number_of_nodes()}"
      puts "t2 number_of_edges: #{@t2.number_of_edges()}"
    end


    
    def extract_subtree1()
      #extract nodes
      mid_nb_species =  @nb_species/2
      lv1_nodes = []
      (1..mid_nb_species).each {|n| lv1_nodes << @t0.get_node_by_name(n.to_s)}
      #
      puts "lv1_nodes: #{lv1_nodes.inspect}" unless debug_level <=0
      
      #extract tree
      @t1 = @t0.subtree_with_all_paths(lv1_nodes)
      @t1.remove_nonsense_nodes()
      #
      puts "t1.output_unrooted(): #{t1.output_unrooted()}" unless debug_level <=0
      puts "number_of_nodes: #{@t1.number_of_nodes()}" unless debug_level <=0
      puts "number_of_edges: #{@t1.number_of_edges()}" unless debug_level <=0
      
    end
    
    def save_x_ident()
      #extract nodes
      mid_nb_species =  @nb_species/2
      
      lv1_nodes = (1..mid_nb_species).to_a
      #lv1_nodes = (34..42).to_a
      
      @@ud.array_to_ids_csvfile(lv1_nodes , @x_ident_csv, header = false, quotes = false)
      #
      puts "lv1_nodes: #{lv1_nodes.inspect}"
      
    end


    def save_x_ident_left()

      #extract leaves
      lv1_nodes = @t1.leaves().to_a


      @@ud.array_to_ids_csvfile(lv1_nodes , @x_ident_csv, header = false, quotes = false)
      #
      puts "lv1_nodes: #{lv1_nodes.inspect}"

    end
    
    
    def extract_subtree2()
      #extract nodes
      mid_nb_species =  @nb_species/2
      lv2_nodes = []
      (mid_nb_species+1..@nb_species).each {|n| lv2_nodes << @t0.get_node_by_name(n.to_s)}
      #
      puts "lv2_nodes: #{lv2_nodes.inspect}" unless debug_level <=0
      @t2 = @t0.subtree_with_all_paths(lv2_nodes)
      @t2.remove_nonsense_nodes()
      
    end
    
    #prepare ancestor sequences
    def prepare_ancestor_sequences0()

      #remove root too
      @t0.remove_nonsense_nodes();

      align_seq0 = Bio::Alignment::OriginalAlignment.new()
      align_seq0.add_seq(@anc_seq0, "orig0")
      ancf0 = ""
      ancf0 << align_seq0.output_phylip()
      ancf0 << "1\n"
      ancf0 << @t0.output_unrooted()
      puts ancf0 unless debug_level <=0
      #write tree to disk
      @@ud.string_to_file(ancf0, @lv0_sgen_in_file)
      
    end
    
    def prepare_ancestor_sequences1()
      
      align_seq1 = Bio::Alignment::OriginalAlignment.new()
      align_seq1.add_seq(@anc_seq1, "orig1")
      
      ancf1 = ""
      ancf1 << align_seq1.output_phylip()
      ancf1 << "1\n"
      ancf1 << @t1.output_unrooted()
      puts ancf1 unless debug_level <=0
      #write tree to disk
      @@ud.string_to_file(ancf1, @lv1_sgen_in_file)
    end
    
    def prepare_ancestor_sequences2()
      align_seq2 = Bio::Alignment::OriginalAlignment.new()
      align_seq2.add_seq(@anc_seq2, "orig2")
      
      ancf2 = ""
      ancf2 << align_seq2.output_phylip()
      ancf2 << "1\n"
      ancf2 << @t2.output_unrooted()
      puts ancf2 unless debug_level <=0
      #write tree to disk
      @@ud.string_to_file(ancf2, @lv2_sgen_in_file)
    end
    
    
    def generate_and_parse_seqgen()
      #generate sequences
      puts `#{@seqgen_prog_exec} #{@seqgen_par0} -l#{@lv0_length} -n1 < #{@lv0_sgen_in_file} -s #{@scaling_factor0} > #{@lv0_sgen_out_file}`
      puts `#{@seqgen_prog_exec} #{@seqgen_par1} -l#{@lv3_length} -n1 -k1 < #{@lv1_sgen_in_file} -s #{@scaling_factor1} > #{@lv1_sgen_out_file}`
      puts `#{@seqgen_prog_exec} #{@seqgen_par2} -l#{@lv3_length} -n1 -k1 < #{@lv2_sgen_in_file} -s #{@scaling_factor2} > #{@lv2_sgen_out_file}`
      
      
      #parse generated sequences
      
      lv0_phyl = Bio::Phylip::PhylipFormat.new(@@ud.get_file_as_string(@lv0_sgen_out_file))
      @lv0_align = lv0_phyl.alignment
      puts "@lv0_align-----------------------------------------------" unless debug_level <=0
      puts @lv0_align.output_fasta() unless debug_level <=0
      
      lv1_phyl = Bio::Phylip::PhylipFormat.new(@@ud.get_file_as_string(@lv1_sgen_out_file))
      @lv1_align = lv1_phyl.alignment
      puts "@lv1_align-----------------------------------------------" unless debug_level <=0
      puts @lv1_align.output_fasta() unless debug_level <=0
      #puts @lv1_align.to_hash()
      
      
      lv2_phyl = Bio::Phylip::PhylipFormat.new(@@ud.get_file_as_string(@lv2_sgen_out_file))
      @lv2_align = lv2_phyl.alignment
      puts "@lv2_align-----------------------------------------------" unless debug_level <=0
      puts @lv2_align.output_fasta() unless debug_level <=0
      
      
      @lv3_align = @lv1_align.add_sequences(@lv2_align)
      puts "@lv3_align-----------------------------------------------" unless debug_level <=0
      puts @lv3_align.output_fasta() unless debug_level <=0
      @@ud.string_to_file(@lv3_align.output_fasta(), @lv3_fasta_file)
      #puts lv3_align.output_fasta()
      
    end
    
    #insert
    def slice_and_dice_alignments()
      #insert generated slice
      small_slice1 = @lv0_align.alignment_slice(0,@insert_point)
      puts "@lv0_align[6]: #{@lv0_align["6"].inspect}"
      puts "small_slice1[6]: #{small_slice1["6"].inspect}"
      puts "small_slice1" unless debug_level <=0
      puts small_slice1.output_fasta() unless debug_level <=0
      puts "small_slice1.alignment_length: #{small_slice1.alignment_length}"
      
      small_slice2 = @lv0_align.alignment_slice((@insert_point + @lv3_length),(@lv0_length-@insert_point-@lv3_length))
      puts "small_slice2[6]: #{small_slice2["6"].inspect}"
      puts "small_slice2.alignment_length: #{small_slice2.alignment_length}"
      puts "small_slice2" unless debug_level <=0
      puts small_slice2.output_fasta() unless debug_level <=0
      
      sm3 = small_slice1
      sm3.alignment_concat(@lv3_align)
      puts "@lv3_align[6]: #{@lv3_align["6"].inspect}"
      sm3.alignment_concat(small_slice2)
      puts "small_slice3------------------------------------------------------------" unless debug_level <=0
      puts "sm3[6]: #{sm3["6"].inspect}"
      puts "sm3.alignment_length: #{sm3.alignment_length}"
      
      
      puts sm3.output_fasta() unless debug_level <=0
      puts sm3.size() unless debug_level <=0
      #write to disk
      @@ud.string_to_file(sm3.output_fasta(), @sm3_fasta_file)
      
    end
    
    
    def ar_compute_indexes()
      
      #make place
      QFuncCsv.destroy_all
      #load csv into table
      q_func_csv_arr = FasterCSV.read("#{@q_func_csv}")
      head = q_func_csv_arr.shift
      #puts head.inspect()
      #puts head[22]
      
      #indexes are 0 based
      q_func_csv_arr.each { |csv_row|
        db_row = QFuncCsv.new
        db_row.win_start = csv_row[1]
        
        db_row.q_func = case @calc_type
        when "auto" then csv_row[25 + @f_disp_max]
        when "simple" then csv_row[8 + @f_disp_max]
        else "Unknown"
        end
        
        db_row.save
      }

      #find superposing window
      best_row = QFuncCsv.find_by_win_start @insert_point
      #puts "best_row.q_func: #{best_row.q_func}"
      #calculate p_values
      pval_sup_row = QFuncCsv.find :all, :conditions => [ "q_func >= ?", best_row.q_func ]
      pval_inf_row = QFuncCsv.find :all, :conditions => [ "q_func <= ?", best_row.q_func ]
      #puts "pval_sup_row.count: #{pval_sup_row.count}, QFuncCsv.count: #{QFuncCsv.count}"
      
      @pval_sup = pval_sup_row.count.to_f / QFuncCsv.count.to_f
      @pval_inf = pval_inf_row.count.to_f / QFuncCsv.count.to_f
      
      #puts "@pval_sup: #{@pval_sup}"
      
    end
    
=begin
    #return [lv_q_func_ratio, lv_rand_ratio]
    def compute_indexes()
      #parse results
      lv0_q_func_sum = 0
      lv0_rand_sum = 0
      lv0_elements = 0

      #maximum value in outside
      lv0_q_func_max = -Inf
      lv0_rand_max = -Inf
      #minimum value in outside
      lv0_q_func_min = Inf
      lv0_rand_min = Inf


      lv3_q_func_sum = 0
      lv3_rand_sum = 0
      lv3_elements = 0

      #
      lv3_q_func_sup_count = 0
      lv3_rand_sup_cout = 0
      lv3_q_func_inf_count = 0
      lv3_rand_inf_count = 0



      line = 0
      FasterCSV.foreach("#{@q_func_csv}", :quote_char => '"', :col_sep =>',', :row_sep =>:auto) { |row|
        line += 1
        unless line == 1
          #puts "line: #{line}, row1: #{row[1]}. row22: #{row[22]}"

          win_start = row[1].to_i
          win_end = win_start + @win_width
          if  win_start >= @insert_point and win_end <= (@insert_point +@lv3_length) then
            lv3_elements += 1
            lv3_q_func_sum += row[22].to_f
            lv3_rand_sum += row[25].to_f
          else
            lv0_elements += 1
            lv0_q_func_sum += row[22].to_f
            lv0_rand_sum += row[25].to_f
            #update maximum values
            lv0_q_func_max = [row[22].to_f,lv0_q_func_max].max
            lv0_rand_max = [row[25].to_f,lv0_rand_max].max
            #update minimum values
            lv0_q_func_min = [row[22].to_f,lv0_q_func_min].min
            lv0_rand_min = [row[25].to_f,lv0_rand_min].min

          end

        end
      }

      #puts "lv0_q_func_max: #{lv0_q_func_max}, lv0_q_func_min: #{lv0_q_func_min}"

      #rescan elements to capture percentage of greater than max elements
      #or less then min
      line = 0
      FasterCSV.foreach("#{@q_func_csv}", :quote_char => '"', :col_sep =>',', :row_sep =>:auto) { |row|
        line += 1
        unless line == 1
          #puts "line: #{line}, row1: #{row[1]}. row22: #{row[22]}"

          win_start = row[1].to_i
          win_end = win_start + @win_width
          if  win_start >= @insert_point and win_end <= (@insert_point +@lv3_length) then
            lv3_q_func_sup_count += 1 if row[22].to_f > lv0_q_func_max
            lv3_rand_sup_cout += 1 if row[25].to_f > lv0_rand_max
            lv3_q_func_inf_count += 1 if row[22].to_f < lv0_q_func_min
            lv3_rand_inf_count += 1 if row[25].to_f < lv0_rand_min
            #puts "lv3_q_func_sup_count: #{lv3_q_func_sup_count}"
          end

        end
      }


      lv0_q_func = lv0_q_func_sum/lv0_elements
      lv3_q_func = lv3_q_func_sum/lv3_elements


      #
      @lv3_q_func_sup_proc = lv3_q_func_sup_count.to_f / lv3_elements
      @lv3_rand_sup_proc = lv3_rand_sup_cout.to_f / lv3_elements
      @lv3_q_func_inf_proc = lv3_q_func_inf_count.to_f / lv3_elements
      @lv3_rand_inf_proc = lv3_rand_inf_count.to_f / lv3_elements

      #puts "lv3_q_func_sup_proc: #{@lv3_q_func_sup_proc}, lv3_q_func_inf_proc: #{@lv3_q_func_inf_proc}"

      @lv_q_func_ratio = lv3_q_func / lv0_q_func
   
      #puts "lv_q_func_ratio: #{@lv_q_func_ratio}, lv0_q_func: #{lv0_q_func}, lv3_q_func: #{lv3_q_func}" unless debug_level <=0
   
    end

=end
    def generate_trees()

      case @tree_type
      when TreeType::POLYPHYLETIC
         read_tree()
      extract_subtree1()
      extract_subtree2()
      save_x_ident()
    when TreeType::MONOPHYLETIC
      read_rooted_tree()
      extract_subtree_left()
      extract_subtree_right()
      save_x_ident_left()

      end
    end


    def test_replic()
      
      
      @simul_param = @simul_test.simul_param.new
      @simul_param.nb_replic = @nb_replic
      @simul_param.nb_species = @nb_species
      @simul_param.f_opt_max = @f_opt_max
      @simul_param.scaling_factor0 = @scaling_factor0
      @simul_param.scaling_factor1 = @scaling_factor1
      @simul_param.scaling_factor2 = @scaling_factor2
      @simul_param.save
      
      
      (1..@nb_replic).each {|i|
        #begin main
        create_random_tree()

        generate_trees()

        set_start_seqs_and_evol_params()
        prepare_ancestor_sequences0()
        prepare_ancestor_sequences1()
        prepare_ancestor_sequences2()
        generate_and_parse_seqgen()
        slice_and_dice_alignments()
        q_func_exec()
        ar_compute_indexes() #@pval_sup, @pval_inf
        #end main
        
        # puts SimulTestElem.connection.inspect
        # puts `pwd`
        
        @simul_test_elem = @simul_param.simul_test_elem.new
        @simul_test_elem.pval_sup =@pval_sup
        @simul_test_elem.pval_inf =@pval_inf
        @simul_test_elem.save
        sleep 0.100
      }
      
      #calculate 5 values percentiles
      perc_five_sup = @simul_param.perc_five_sup
      perc_five_inf = @simul_param.perc_five_inf
     
      #calculate positive_predictive_value
      pred_val = @simul_param.pred_val
  
      #save results
      #create independent
      @simul_param_result = SimulParamResult.new
      #link to master table
      @simul_param_result.simul_param =@simul_param
      
      @simul_param_result.pval_sup_q0 = perc_five_sup.q0
      @simul_param_result.pval_sup_q25 = perc_five_sup.q25
      @simul_param_result.pval_sup_q50 = perc_five_sup.q50
      @simul_param_result.pval_sup_q75 = perc_five_sup.q75
      @simul_param_result.pval_sup_q100 = perc_five_sup.q100
      #
      @simul_param_result.pval_inf_q0 = perc_five_inf.q0
      @simul_param_result.pval_inf_q25 = perc_five_inf.q25
      @simul_param_result.pval_inf_q50 = perc_five_inf.q50
      @simul_param_result.pval_inf_q75 = perc_five_inf.q75
      @simul_param_result.pval_inf_q100 = perc_five_inf.q100
      @simul_param_result.pred_val_ppv01 = pred_val.ppv01
      @simul_param_result.pred_val_ppv05 = pred_val.ppv05
      #
      @simul_param_result.save
      
      
    end
    
    
   
    
    
    
    def test_test()
      
      @simul_test = @simul_suite.simul_test.create(:test_ident => "test_test")
      
      
      #default
      @scaling_factor0 = 1
      @scaling_factor1 = 1
      @scaling_factor2 = 1
      @calc_type = "simple"
      #prepare range
      rng = []
      [5, 9].each { |i| rng << i*0.05}
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
    
    def test_cases(test_name, test_suit)
      
      #only one test suite
      SimulSuite.destroy_all :test_name => test_name
      
      @simul_suite = SimulSuite.create(:test_name => test_name)
      
      # @simul_results_hdl = File.open(@simul_results_csv,'a')
      # output_header()
      
      test_suit.each { |test|
        self.set_simulation_default_run_parameters()
        self.set_q_func_default_run_parameters()
        self.send(test)
        
      }
      
      # @simul_results_hdl.close()
      
      
    end
    
    def export_simul_results(test_name, machine_id)
      puts "export_simul_results, test_name: #{test_name}, machine_id: #{machine_id}"
      SimulSuite.export_csv(test_name, "#{@results_folder}/#{machine_id}_#{test_name}.csv")

      
    end
    
    
    def test_random_seqs()
      s = Bio::Sequence::NA.new("")
      equal_composition = {'a' =>50, 'c' => 50, 'g' => 50, 't' => 50}
      a =  s.randomize(equal_composition)       #=> "ttaa"  (for example)
      b = a.randomize
      
      puts "a: #{a}"
      puts "b: #{b}"
      
      
      count = 0
      s.randomize { |x| count += 1 }
      puts count                              #=> 4
      
      
    end
    
    
    
    
    
    private
    #helper objects
    @@ud = UqamDoc::Parsers.new
    
    
    
    
  end
  
end
