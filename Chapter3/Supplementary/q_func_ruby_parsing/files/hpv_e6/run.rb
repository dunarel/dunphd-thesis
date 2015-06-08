
require 'rubygems'
require 'bio'
require 'bio/io/flatfile'
require 'bio/db'
require 'bio/db/newick'

require 'mathn'


class RunQCalc
  attr_accessor :parser,
    :dir,
    :seqs_file,
    :msa_file,
    :ident_x_file,
    :q_calc_proj_dir,
    :q_calc_prog_file,
    :q_calc_cmd,
    :q_func_csv,
    :gnuplot_plt,
    :gnuplot_eps,
    :gnuplot_png


  def initialize()


    @q_calc_proj_dir = "/data/PROJETS2/q_func_cpp/"
    @q_calc_prog_file = "dist/gcc_debug/GNU-Linux-x86/q_func_cpp"
    
    @data_dir = '/data/PROJETS2/q_func_ruby_parsing/files/hpv_e6/'
    @msa_file = @data_dir + 'v07_codon_hpv_adn_E6.fa'
    #same identifiers
    @ident_x_file = @data_dir  + 'x_ident_16_18.csv'
    @q_func_csv = @data_dir + 'q_func_hpv_adn_E6.csv'
    
    @gnuplot_plt = @data_dir + 'q_func_hpv_adn_E6.plt'
    @gnuplot_eps = @data_dir + 'q_func_hpv_adn_E6.eps'
    @gnuplot_png = @data_dir + 'q_func_hpv_adn_E6.png'
  end


  def calc_q_val()
    
    opt = "--msa_fasta #{@msa_file} " +
          "--x_ident_csv #{@ident_x_file} " +
          "--q_func_csv #{@q_func_csv} " +
          "--align_type dna " +
         "--dist ham " +
         #"--dist jknucl " +
         "--winl 9 "
        
    cmd = "#{@q_calc_proj_dir}#{@q_calc_prog_file} #{opt}"
    puts cmd
    
    #puts `#{cmd}`

    IO.popen(cmd) { |p| p.each { |f| puts f } }
  end

  def gnuplot_png()
    Dir.chdir(@data_dir+"files/nucl") { |path|
     puts `pwd`
     cmd = "gnuplot #{@gnuplot_plt}"
     puts cmd
     puts `#{cmd}`
     cmd = "convert -density 350 #{@gnuplot_eps} -resize 50% #{@gnuplot_png}"
     puts cmd
     puts `#{cmd}`
    }


  end

end



run_q_calc = RunQCalc.new
run_q_calc.calc_q_val()
run_q_calc.gnuplot_png()





#a_e6.prot_to_dna()
#parser = UqamDoc::Parsers.new
#puts parser.parse_ictv_hpv_adn("E6").length




