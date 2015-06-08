
require 'rubygems'
require 'msa_tools'

require 'nokogiri'
require 'open-uri'

require 'java'
require '/root/devel/db_srv/sp_projects/proc-hom-sp/dist/proc-hom-sp.jar'
JavaPalTiming = org.uqam.doct.proc.hom.sp.PalTiming



module TimeEstimTreePl

  def exp_mrcas_yaml()
    puts "in exp_mrcas_yaml()"

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

    mrcas_hsh = {}
    (0..(mrcas.length-1)).each {|x|
      mrcas_hsh[x] = mrcas_string(mrcas[x])
    }

    # puts "mrcas_hsh: #{mrcas_hsh}"
    locate_results_files()
    #write mrcas file to disk as yaml
    File.open(@mrcas_gene_f, "w+") do |f|
      f.puts mrcas_hsh.to_yaml()
    end


  end




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

 
end




module TimeEstim
  

  def calc_timed_trees()
     
    cnt = 0
   
    #@genes[81..109].each { |gn|
    @genes.each { |gn|
      cnt += 1
      #fl = fl.split

      
      #@gene_name=fl[1]
      @gene = gn
      locate_gene_results_files()

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


