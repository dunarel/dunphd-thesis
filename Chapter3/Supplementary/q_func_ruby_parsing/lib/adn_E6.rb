
require 'rubygems'
require 'bio'
require 'bio/io/flatfile'
require 'bio/db'
require 'bio/db/newick'

require 'mathn'

require 'soap/wsdlDriver'
require 'base64'

require 'msa_rest_ws'
require 'msa_tools'

class AdnE6
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
    @parser = UqamDoc::Parsers.new
    #parser.msa_replace_random('/data/PROJETS2/q_func_ruby_parsing/files/nucl/', 'orig_E1.fasta', 'noalign_random_E1.fasta','aligned_random_E1.fasta')
    #maf = UqamDoc::Mafft.new
    #puts  maf.parameters.inspect
    #puts maf.parameterdetails('matrix').inspect
    @q_calc_proj_dir = "/data/PROJETS2/q_func_cpp/"
    @q_calc_prog_file = "dist/gcc_debug/GNU-Linux-x86/q_func_cpp"
    
    @data_dir = '/data/PROJETS2/q_func_ruby_parsing/'
    @seqs_file = @data_dir + 'files/nucl/v02_orig_hpv_adn_E6.fasta'
    @msa_file = @data_dir + 'files/nucl/v02_msa_hpv_adn_E6.fasta'
    #same identifiers
    @ident_x_file = @data_dir  + 'files/nucl/x_ident_16_18.csv'
    @q_func_csv = @data_dir + 'files/nucl/v02_q_func_hpv_adn_E6.csv'
    @gnuplot_plt = @data_dir + 'files/nucl/v02_q_func_hpv_adn_E6.plt'
    @gnuplot_eps = @data_dir + 'files/nucl/v02_q_func_hpv_adn_E6.eps'
    @gnuplot_png = @data_dir + 'files/nucl/v02_q_func_hpv_adn_E6.png'
  end

  def parse_ictv_hpv_gene_adn()
    seqs = @parser.parse_ictv_hpv_adn('E6')
    puts seqs.inspect

    #seqs.delete('HPV-42')
    #seqs.delete('HPV-cand91')
    #seqs.delete('HPV-cand96')


    parser.seqshash_to_fastafile(seqs, @seqs_file)

  end

  def align_hpv_proteins()
    parser = UqamDoc::Parsers.new
    seqs = parser.fastafile_to_fastastring(@seqs_file)

    #align
    maf = UqamDoc::Mafft.new #cw2=UqamDoc::ClustalW2.new
    #puts  maf.parameters.inspect
    puts maf.parameterdetails('matrix').inspect
    # less than 62% identical.
    # One would use a higher numbered BLOSUM matrix for aligning
    # two closely related sequences and a lower number for more divergent sequences.
    job_id = maf.submit_protein(seqs, "bl30")  #bl30,bl45,bl80,bl62 job_id= cw2.submit_dna(seqs)
    #recuperate
    fasta_str = maf.get_msa_wait(job_id) #fasta_str = cw2.get_msa_wait(job_id)
    #puts fasta_str


    parser.string_to_file(fasta_str,@msa_file)
  end

  def align_hpv_adn()
    parser = UqamDoc::Parsers.new
    seqs = parser.fastafile_to_fastastring(@seqs_file)

    #align
    maf = UqamDoc::Mafft.new #cw2=UqamDoc::ClustalW2.new
    #puts  maf.parameters.inspect
    #puts maf.parameterdetails('matrix').inspect
    # less than 62% identical.
    # One would use a higher numbered BLOSUM matrix for aligning
    # two closely related sequences and a lower number for more divergent sequences.
    job_id = maf.submit_dna(seqs)
    #recuperate
    fasta_str = maf.get_msa_wait(job_id)
    #puts fasta_str
    parser.string_to_file(fasta_str,@msa_file)
  end



  def prot_to_dna()

    parser = UqamDoc::Parsers.new
    #read protein file
    seqs = parser.fastafile_to_original_alignment(@seqs_file)
    puts seqs.class
    seqs.each_pair {|key, value| 
      puts "#{key} is #{value}"
      aa = Bio::Sequence.auto(value).aa().to_s()
      puts "translation is #{aa}"

    }

    


  end

  def calc_q_val()
    
    opt = "--msa_fasta #{@msa_file} " +
          "--x_ident_csv #{@ident_x_file} " +
          "--q_func_csv #{@q_func_csv} " +
          "--align_type dna " +
         "--dist ham " +
         #"--dist jknucl " +
         "--winl 18 "
        
    cmd = "#{@q_calc_proj_dir}#{@q_calc_prog_file} #{opt}"
    puts cmd
    puts `#{cmd}`
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



a_e6 = AdnE6.new
a_e6.parse_ictv_hpv_gene_adn()
#a_e6.align_hpv_adn()
#a_e6.calc_q_val()
#a_e6.gnuplot_png()





#a_e6.prot_to_dna()
#parser = UqamDoc::Parsers.new
#puts parser.parse_ictv_hpv_adn("E6").length




