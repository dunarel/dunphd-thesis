
require 'rubygems'
require 'msa_tools'

require 'nokogiri'
require 'open-uri'

require 'java'
require '/root/devel/db_srv/sp_projects/proc-hom-sp/dist/proc-hom-sp.jar'
JavaPalTiming = org.uqam.doct.proc.hom.sp.PalTiming



module TimeEstimTreePl



 

  def prepare_exec_files()

    puts "@timed_tr_template_d: #{@timed_prog_d}"
    puts "======================================@gene.id: #{@gene.id}, @gene.name: #{@gene.name}============================="
    sleep 5
   
    #make sure there is no result file
    #for correct stop condition
    File.delete @timed_tr_dated_f if File.exists?(@timed_tr_dated_f)
    #go to working folder
    Dir.chdir @timed_tr_d

    len = GeneBloRun.find_by_gene_id(@gene.id).blocks_length


    #
    sql = "select m.id,
                  m.abrev,
                  m.time_min,
                  m.time_max
           from mrcas m
           where mrca_criter_id = 0
           order by m.time_max asc"
    mrcas = Mrca.find_by_sql(sql)

    #mrca_ids = mrcas.collect{|m| m.id}

    puts mrcas.inspect
    puts "length: #{mrcas.length}"
    mrca_activ = Array.new(mrcas.length,false)
    puts mrca_activ.inspect


    #test activate constraints
    (0..(mrcas.length-1)).each {|x|

      mrcas_str = ""
      (0..x-1).each { |prev_idx|
        if mrca_activ[prev_idx] == true
          mrcas_str += mrcas_string(mrcas[prev_idx])
        end
      }
      #all cases include current step
      mrcas_str += mrcas_string(mrcas[x])
      #puts "mrcas_prev: #{mrcas_str}"

      #test current constraints
      File.open(@treepl_cfg_tree_f, "w+") do |f|
        f.puts "treefile  = gene_res.tr"
        f.puts "smooth = 100"
        f.puts "numsites = #{len}"
        f.puts
        f.puts "#{mrcas_str}"
        f.puts "outfile = dated_tree.nwk"
        f.puts "nthreads = 4"
        #f.puts "thorough"
        #f.puts "log_pen"




      end

      cmd = "sync"; puts `#{cmd}`
      sleep 2

      cmd = "treePL gene_res.cfg"
      puts `#{cmd}`

      cmd = "sync"; puts `#{cmd}`
      sleep 2
      #test size of result file
      sz = File.size(@timed_tr_dated_f)
      puts "size: #{sz}"
      # sleep 1
      mrca_activ[x] = true if sz != 0

    }
    puts "all tested, final step----------------"
    #final step
    mrcas_str = ""
    (0..(mrcas.length-1)).each {|x|
      if mrca_activ[x] == true
        mrcas_str += mrcas_string(mrcas[x])
      else
        mrcas_str += "# skiped constraint #{x}\n"
      end
    }
    #test current constraints
    File.open(@treepl_cfg_tree_f, "w+") { |f|
      f.puts "treefile  = gene_res.tr"
      f.puts "smooth = 100"
      f.puts "numsites = #{len}"
      f.puts
      f.puts "#{mrcas_str}"
      f.puts "outfile = dated_tree.nwk"
      f.puts "nthreads = 4"
      f.puts "thorough"
      #f.puts "log_pen"
    }

    cmd = "sync"; puts `#{cmd}`
    sleep 2

    cmd = "treePL gene_res.cfg"
    puts `#{cmd}`

    cmd = "sync"; puts `#{cmd}`
    sleep 2
    #test size of result file
    nb_constr = mrca_activ.keep_if{|el| el == true}.length

    sz = File.size(@timed_tr_dated_f)
    puts "final size: #{sz}, nb_constr: #{nb_constr} "
    puts "gene_id: #{@gene.id}, gene_name: #{@gene.name}"

    restart_cnt = 20
    while sz == 0 && restart_cnt >0
      puts "retry nb: #{restart_cnt}"
      cmd = "sync"; puts "#{cmd}"; puts `#{cmd}`
      cmd = "treePL gene_res.cfg"; puts "#{cmd}"; puts `#{cmd}`
      cmd = "sync"; puts "#{cmd}"; puts `#{cmd}`
      sz = File.size(@timed_tr_dated_f)
      restart_cnt -= 1
    end


    raise "really any valid constraints, on #{nb_constr}, gene.id #{@gene.id}, gene.name #{@gene.name}" if sz == 0

    sleep 5


  end


end

module TimeEstimBeast

  def prepare_exec_files()
  
    #mve to working dir
    #Dir.chdir @hgt_gene_results_dir

    #use java class to root and rescale the tree
    #String inputTreeF = "/root/local/whme_beast/hgt_com/secE/gene_res.tr";
    #String inputTreeF  = "/root/local/whme_beast/hgt_com/secE/out.tre";

    #String outputTreeF =  "/root/local/whme_beast/hgt_com/secE/gene_res_rooted_scaled.tre";

    pt = JavaPalTiming.new @jdbc_conn, @timed_tr_unrooted_f, \
      @timed_tr_rooted_scaled_f

    #scale to root of prokaryotes
    pt.set_root_age 4290
    pt.scale_tree
    pt.save_output_tree
    pt.calculate_rstatistics

    puts "estimate: mean: #{pt.get_fdr_estimate_meanlog} sd: #{pt.get_fdr_estimate_sdlog}"
    puts "sd      : mean: #{pt.get_fdr_sd_meanlog} sd: #{pt.get_fdr_sd_sdlog}"

    #open template
    puts "@timed_tr_template_xml_f: #{@beast_template_cfg_tree_f}"
    #f = File.open(@beast_template_cfg_tree_f)
    # doc = Nokogiri::XML(f)


    #f.close
    #puts "doc: #{doc.to_s}"

    #get template
    doc = Nokogiri::XML(File.open(@beast_template_cfg_tree_f)) { |config|
      config.strict.nonet
    }

    #tree_seq = Nokogiri::XML::Node.new "sss", doc
    #tree_seq.content = "This is the sequence"



    #foo  = frag.children.first
    #foo.swap( Nokogiri::XML::Text.new( "bar", foo.document ) )
    #puts frag

    #read java generate tree
    timed_tr_rooted_scaled = File.open(@timed_tr_rooted_scaled_f, 'rb') { |f| f.read }
    #timed_tr_rooted_scaled.gsub!(/\n/, "")

    #replace template node with sequence
    frag = doc.search("//to_replace_starting_tree").first
    frag.swap( Nokogiri::XML::Text.new( timed_tr_rooted_scaled, frag.document ) )

    puts "frag: #{frag}"

    prior_ucld_mean_n = doc.search("//prior[@id='prior']/logNormalPrior[parameter[@idref='ucld.mean']]").first
    prior_ucld_mean_n["mean"]=pt.get_fdr_estimate_meanlog.to_s
    prior_ucld_mean_n["stdev"]=pt.get_fdr_estimate_sdlog.to_s
    puts "prior_ucld_mean_n: #{prior_ucld_mean_n}"
    #
    prior_ucld_stdev_n = doc.search("//prior[@id='prior']/logNormalPrior[parameter[@idref='ucld.stdev']]").first
    prior_ucld_stdev_n["mean"]=pt.get_fdr_sd_meanlog.to_s
    prior_ucld_stdev_n["stdev"]=pt.get_fdr_sd_sdlog.to_s
    puts "prior_ucld_stdev_n #{prior_ucld_stdev_n}"
    #
    model_ucld_mean_n = doc.search("//logNormalDistributionModel/mean/parameter[@id='ucld.mean']").first
    model_ucld_mean_n["value"]=pt.get_fdr_estimate_meanlog.to_s
    puts "model_ucld_mean_n: #{model_ucld_mean_n}"
    #
    #this is subject to question
    #alternative get_fdr_estimate_sdlog
    model_ucld_stdev_n = doc.search("//logNormalDistributionModel/stdev/parameter[@id='ucld.stdev']").first
    model_ucld_stdev_n["value"]=pt.get_fdr_sd_meanlog.to_s
    puts "model_ucld_stdev_n #{model_ucld_stdev_n}"




    #.each { |node|
    #new_node = doc.create_element ""
    #new_node.inner_html = "replaced with sequence"
    #node.replace new_node
    #node.children.remove
    #node.content = 'Children removed.'

    #replacement_killer = Nokogiri::XML::Text.new("ok dokey", node.document)
    #puts "replacement_killer: #{replacement_killer}"
    #doc.add
    # node.add_next_sibling replacement_killer
    #node.remove
    #}


    #local copy fasta alignement
    FileUtils.cp(@fasta_align_f,@beast_fasta_align_f)


    #find taxon container
    taxa_n = doc.search("//taxa[@id='taxa']").first
    #remove contents and prepare container
    #puts "taxa_n: #{taxa_n}"
    taxa_n.children.remove
    taxa_n.add_child(doc.create_text_node("\n\t\t"))

    #find alignment container
    align_n = doc.search("//alignment[@id='alignment']").first
    #remove contents and prepare container
    #puts "align_n #{align_n}"
    align_n.children.remove
    align_n.add_child(doc.create_text_node("\n\t\t"))

    #tt_n = doc.create_text_node "\n"
    #taxa_n.add_child(tt_n)

    f= @beast_fasta_align_f
    begin
      #puts f
      fasta = Bio::FastaFormat.open(f)
      n_seq = 0
      n_bp = 0
      fasta.each do |entry|
        #add definitions to xml
        tx_n = doc.create_element "taxon"
        tx_n["id"]=entry.definition
        taxa_n.add_child(tx_n)
        taxa_n.add_child(doc.create_text_node("\n\t\t"))

        #add sequences to xml
        sq_n = doc.create_element "sequence"
        tx_ref_n = doc.create_element "taxon"
        tx_ref_n["idref"]=entry.definition
        #tx_ref_n.content = ""
        sq_n.add_child(doc.create_text_node("\n\t\t\t"))
        sq_n.add_child(tx_ref_n)
        sq_n.add_child(doc.create_text_node("\n\t\t\t"))
        sq_n.add_child(doc.create_text_node("#{entry.naseq}\n\t\t"))

        align_n.add_child(sq_n)
        align_n.add_child(doc.create_text_node("\n\t\t"))



        #puts "definition: #{entry.definition}"
        #puts "seq: #{entry.naseq}"
        n_seq += 1
        n_bp = entry.naseq.length
      end
      puts n_seq.to_s + " " + n_bp.to_s
    rescue Exception=>e
      puts e.message
      puts e.backtrace.inspect
    end

    #taxa_n.add_child(doc.create_text_node(""))

    # Save a string to a file.
    aFile = File.new( @beast_cfg_tree_f, "w")
    aFile.write(doc)
    aFile.close


  end

  def exec_local
    #puts "doc: #{doc.to_s}"
    #tst = doc.xpath("//to_replace_starting_tree")
    #puts "tst: #{tst}"

    #make sure there is no result file
    File.delete @timed_tr_dated_f if File.exists?(@timed_tr_dated_f)

    #execute beast
    Dir.chdir @timed_tr_d
    sys "java -Djava.library.path=/root/lib64 -jar ~/local/BEASTv1.7.4/lib/beast.jar -overwrite ./gene_beast.xml"

    #remote
    #java -Djava.library.path=/home/badescud/lib/ -jar ~/local/BEASTv1.7.4/lib/beast.jar -beagle_SSE -beagle_instances 1 -overwrite ./gene_beast.xml

  end

  def parse_results_local()
    puts "from TimeEstimBeast"
    #mve to working dir
    Dir.chdir @timed_tr_d
    puts "getwd: #{Dir.getwd}"
    #annotate original tree with tree posteriors
    sys "~/local/BEASTv1.7.4/bin/treeannotator -heights median -burnin 10 -limit 0.5 -target starting_tree.nwk gene_beast.trees dated_tree.annot"
    #remove annotations
    sys "cat dated_tree.annot | perl -ne \"s/\\[.+?\\]//g; print;\" > dated_tree.nex"
    #convert nexus to newick
    sys "java -jar ~/local/phyutility/phyutility.jar -vert -in dated_tree.nex -out dated_tree.nwk"

  end

end




module TimeEstim
  




  def locate_results_files
    
    @genes_dir =  "#{AppConfig.hgt_par_dir}/hgt-par-#{@phylo_prog}-#{@win_size}"

    #Dir.chdir @gene_dir

    @valid_win_path = "#{@genes_dir}/#{@gene.name}/valid_win.idx"
    #puts "valid_win_path: #{@valid_win_path}"
    #sys "cp #{@valid_win_path} results/#{@gene_dir}/"
    @win_path = "#{@genes_dir}/#{@gene.name}/#{@win_dir}"
    
    #hgt results files
    #@hgt_results_dir = "#{AppConfig.hgt_com_dir}/hgt-com-#{@phylo_prog}/results"
    #@hgt_gene_results_dir = "#{@hgt_results_dir}/hgt-com-#{@phylo_prog}_gene#{@gene.name}_id#{@gene.id}.BQ"
    @hgt_win_results_fil = "#{@win_path}/output.txt"
  
    #sys "cat #{@output_path} | wc "
          
    #@fasta_align_f = "#{AppConfig.hgt_com_dir}/gene_blo_seqs_msa/fasta/#{@gene.name}.fasta"
    #dated trees
    
    @timed_tr_work_gene_d = "#{@timed_tr_work_d}/#{@gene.name}"
    #mrca constraints are gene level
    @mrcas_gene_f = "#{@timed_tr_work_gene_d}/mrcas.yaml"

    @timed_tr_size_d = "#{@timed_tr_work_gene_d}/#{@win_size}"
    @timed_tr_d = "#{@timed_tr_size_d}/#{@win_dir}"
    #trees
    @timed_tr_unrooted_f = "#{@timed_tr_d}/gene_res.tr"
    #@treepl_cfg_tree_f = "#{@timed_tr_d}/gene_res.cfg"


    #@timed_tr_rooted_scaled_f = "#{@timed_tr_d}/starting_tree.nwk"
    #

    #! local files should not have gene identifier
    #should be anonymous, identification elements outside filename
    #@beast_fasta_align_f = "#{@timed_tr_d}/align_beast.fasta"
    #@beast_cfg_tree_f = "#{@timed_tr_d}/gene_beast.xml"




  end


  def prepare_input_tree()

    [10,25,50].each { |win_size|
      @win_size = win_size

      locate_results_files()

      File.open(@valid_win_path,"r") { |vwf|

        #puts "vwf: #{vwf}"
        vwf.each { |win_dir|
          @win_dir = win_dir
          @win_dir.chomp!
          #puts win_dir
          win_dir_comp = @win_dir.split("-")
          @fen_no = win_dir_comp[0]
          @fen_idx_min = win_dir_comp[1]
          @fen_idx_max = win_dir_comp[2]

          #puts "fen_no: #{@fen_no}, fen_idx_min: #{@fen_idx_min}, fen_idx_max: #{@fen_idx_max}"

          locate_results_files()
         
          if File.exists?(@hgt_win_results_fil)
            #extract gene tree and make a local file with it
            s = File.open(@hgt_win_results_fil, 'rb') { |f| f.read }

            #puts "s: #{s}"

            res =  /Gene\sTree\s\:\n(.+)\n+=+/.match(s)
            #puts res[1]

            tree_str = res[1]
            tree_str = tree_str.gsub("\n", "")

            #make place
            puts "@timed_tr_gene_d: #{@timed_tr_work_gene_d}"
            Dir.mkdir(@timed_tr_work_gene_d, "755".to_i(8)) unless File.exists?(@timed_tr_work_gene_d)
            puts "@timed_tr_size_d: #{@timed_tr_size_d}"
            Dir.mkdir(@timed_tr_size_d, "755".to_i(8)) unless File.exists?(@timed_tr_size_d)
            #timed_tr_d is window directory
            puts "@timed_tr_d: #{@timed_tr_d}"
            Dir.mkdir(@timed_tr_d, "755".to_i(8)) unless File.exists?(@timed_tr_d)


            puts "@timed_tr_unrooted_f: #{@timed_tr_unrooted_f}"
            #puts "@timed_tr_rooted_scaled_f: #{@timed_tr_rooted_scaled_f}"

            #write tree file to disk
            File.open(@timed_tr_unrooted_f, "w+") do |f|
              f.puts tree_str
            end

          end


        } #win_dir
      } #vwp

    } #win size

  end



  def calc_timed_trees()
     
    cnt = 0
   
    #@genes[81..109].each { |gn|
    @genes.each { |gn|
      cnt += 1
      #fl = fl.split

      
      #@gene_name=fl[1]
      @gene = gn
      locate_results_files()

      #import one gene

      #execute all procedures given as options
      @opt[:calc_procs].each { |pr|
        #puts "pr: #{pr}"
        self.send(pr)
      }

      #calc_one_timed_beast() if @timing_prog == :beast
      #calc_one_timed_treepl() if @timing_prog == :treepl

      
    }
  end

  def calc_timed_transfers_all_genes()

    cnt = 0

    @genes.each { |gn|
      cnt += 1
      #fl = fl.split


      #@gene_name=fl[1]
      @gene = gn
      locate_gene_results_files()

      #import one gene
      calc_timed_transfers_one_gene()

    }
  end


 
  
  
  def mrcas_string(mr)
    #puts "mrca string assemble..."

    res = ""
    
   
    sql = "select gbs.NCBI_SEQ_ID
             from gene_blo_seqs gbs
              join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
              join TAXON_GROUPS tg on tg.TAXON_ID = ns.TAXON_ID
             where gene_id = #{@gene.id} and
                   tg.PROK_GROUP_ID in (select mpg.PROK_GROUP_ID
                                        from mrcas m
                                         join MRCA_PROK_GROUPS mpg on mpg.MRCA_ID = m.id
                                        where id = #{mr.id}
                                        )"
    ncbi_seqs = GeneBloSeq.find_by_sql(sql)
    if ncbi_seqs.length !=0
      mrca_str = "mrca = #{mr.abrev} #{ncbi_seqs.collect{|seq| seq.ncbi_seq_id}.to_s.gsub(/[\[\],]/,"")}\n"
      mrca_str+= "min = #{mr.abrev} #{mr.time_min}\n"
      mrca_str+= "max = #{mr.abrev} #{mr.time_max}\n"
      res += mrca_str
    end
   
    
    return res
    
  end
 
    
    
  def calc_timed_transfers_one_gene

    puts "@timed_tr_dated_f: #{@timed_tr_dated_f}"
    puts "gene.id: #{@gene.id}, gene.name: #{@gene.name}"
    #sleep 5
    pt = JavaPalTiming.new 
    pt.load_rooted_tree(@timed_tr_dated_f);
    #@jdbc_conn, @hgt_gene_dat_tree_fil
    #age = pt.get_age("154687337, 308174920")
    #puts "age: #{age}"

    contins = HgtComIntContin.where("gene_id = ?", @gene.id).select("id,from_subtree,to_subtree")
    contins.each {|cont|
      id = cont.id
      from_age = pt.get_age_node(cont.from_subtree)
      to_age = pt.get_age_node(cont.to_subtree)
      #age_md = pt.get_age(cont.from_subtree,cont.to_subtree)
      age_md = pt.get_age_branch(cont.to_subtree)
      #age_md = pt.get_age_node(cont.to_subtree)

      puts "id: #{id}, from_age: #{from_age}, to_age: #{to_age}, age_md: #{age_md}"
      cont.from_age = from_age
      cont.to_age = to_age
      #use destination age
      cont.age_md = age_md
      cont.save
       
    }
    #sleep 5
  end
  
  def test_time_estim 
    puts "@arTransferGroup: #{@arTransferGroup.table_name}"
  end
  
  #cont.to_age = to_age
end


