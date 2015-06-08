
require 'rubygems'
require 'msa_tools'
require 'fileutils'
require 'ostruct'

require 'nokogiri'
require 'open-uri'

require 'bio'

require 'rserve'

require 'java'
require '/root/devel/db_srv/sp_projects/proc-hom-sp/dist/proc-hom-sp.jar'
JavaPalTiming = org.uqam.doct.proc.hom.sp.PalTiming

#java_import java.sql.Types.DOUBLE



module TimeEstimCom

  def init()
    puts "in TimeEstimCom.init"
    super
  end

  def align_len

    len = GeneBloRun.select("blocks_length").where("gene_id = ?", @gene.id).first.blocks_length

    
  end

  def create_work_folder(recreate = false)

    #timed_tr_d is window directory
    puts "@timed_tr_d: #{@timed_tr_d}"

    #recreate work folder
    sys "rm -fr #{timed_tr_d(:work)}" if recreate == true
    Dir.mkdir(timed_tr_d(:work), "755".to_i(8)) unless File.exists?(timed_tr_d(:work))




    #puts "timed_tr_unrooted_f(:work) #{timed_tr_unrooted_f(:work)}"
    #puts "@timed_tr_rooted_scaled_f: #{@timed_tr_rooted_scaled_f}"


  end

  #export jobs by genes
  def exp_tasks_yaml(tasks_page_dim, task_start_nb)

    sql=<<-EOF
        select distinct hcif.GENE_ID,
               gn.name,
               gbr.BLOCKS_LENGTH  as align_len
        from HGT_COM_INT_FRAGMS hcif
         join GENES gn on hcif.GENE_ID = gn.ID
         join GENE_BLO_RUNS gbr on gbr.GENE_ID = hcif.GENE_ID
    EOF

    puts "sql: #{sql}"
    #add limit 20
    tasks = Gene.find_by_sql(sql)

    #mrca_ids = mrcas.collect{|m| m.id}

    #puts tasks.inspect

    puts "length: #{tasks.length}"

    tasks_len = tasks.length
    #tasks_len = 1

    nb_pages = tasks_len /  tasks_page_dim
    nb_pages_rem = tasks_len % tasks_page_dim
    puts "nb_pages: #{nb_pages}, nb_pages_rem: #{nb_pages_rem}"

    page_ranges = []

    #whole pages
    nb_pages.times { |pn|
      #puts "page number: #{pn}"
      range_min = pn * tasks_page_dim
      range_max = range_min + tasks_page_dim - 1

      #puts "range_min: #{range_min}, range_max: #{range_max}"
      page_ranges << [range_min,range_max]

    }
    #adds remainder
    if nb_pages_rem != 0
      range_min = nb_pages * tasks_page_dim
      range_max = range_min + nb_pages_rem - 1
      #puts "range_min: #{range_min}, range_max: #{range_max}"
      page_ranges << [range_min,range_max]
    end





    page_ranges.each_index { |i|

      rng_min = page_ranges[i][0]
      rng_max = page_ranges[i][1]

      job_tasks = tasks[rng_min..rng_max]


      #puts "rng_min: #{rng_min}, rng_max: #{rng_max}"
      #puts "tasks: #{tasks.inspect}"
      #puts "job_tasks: #{job_tasks.inspect}"

      job_s = "%05d" % (task_start_nb + i )
      File.open("#{timed_tr_compart_d(:jobs)}/job-tasks-#{job_s}.yaml", "w+") do |f|
        f.puts job_tasks.to_yaml()
      end


    }


  end

  #Decorator pattern first in chain to be called
  #super in first position
  def locate_results_files
    #puts "in TimeEstimCom:locate_results_files() call super"
    #call TimeEstim
    super
    #puts "in TimeEstimCom:locate_results_files() returned from super"
    #@treepl_cfg_tree_f = "#{@timed_tr_d}/gene_res.cfg"
    #@timed_tr_rooted_scaled_f = "#{@timed_tr_d}/starting_tree.nwk"
  
  end


  def wg_per_wg
    sql = "select sum(hctt.AGE_MD_WG)/sum(hcit.WEIGHT) as md_wg_per_wg,
                    sum(hctt.AGE_HPD5_WG)/sum(hcit.WEIGHT) as md_hpd5_per_wg,
                    sum(hctt.AGE_HPD95_WG)/sum(hcit.WEIGHT) as md_hpd95_per_wg,
                    sum(hctt.AGE_ORIG_WG)/sum(hcit.WEIGHT) as md_orig_per_wg
             from HGT_COM_INT_TRANSFERS hcit
              join HGT_COM_TRSF_TIMINGS hctt on hctt.HGT_COM_INT_TRANSFER_ID = hcit.id
             where hctt.TIMING_CRITER_ID = #{@timing_criter_id}
             group by hcit.HGT_COM_INT_FRAGM_ID
             order by sum(hctt.AGE_MD_WG)/sum(hcit.WEIGHT) desc"

    wg_per_wg = HgtComIntTransfer.find_by_sql(sql)
  end


  def load_trsfs
    puts "in TimeEstimCom:load_all_trsfs..."
    
    #load trsf ids
    @trsf_ids_arr = {}

    sql=<<-EOF
select distinct hcif.id
from HGT_COM_INT_FRAGMS hcif
where hcif.GENE_ID = #{@gene.id}
    EOF
    trsf_ids = HgtComIntFragm.find_by_sql(sql)
    @trsf_ids_arr = trsf_ids.collect{|seq| seq.id}
    #puts "@trsf_ids_arr: #{@trsf_ids_arr}"



    #load trsfs
    @trsfs_hsh = {}

    @trsf_ids_arr.each {|trid|
      #puts "trid: #{trid}"

      sql=<<-EOF
select distinct hcit.dest_id
from HGT_COM_INT_FRAGMS hcif
 join HGT_COM_INT_TRANSFERS hcit on hcit.HGT_COM_INT_FRAGM_ID = hcif.ID
where hcif.GENE_ID = #{@gene.id} and 
      hcif.ID = #{trid}
      EOF
      trsfs = HgtComIntTransfer.find_by_sql(sql)
      #puts "trsfs: #{trsfs[0].inspect}"
      @trsfs_hsh[trid]= trsfs.collect{|seq| seq.dest_id.to_s}
      #puts "@trsfs_hsh[#{trid}]: #{@trsfs_hsh[trid]}"

        
    }
      
      
    
  end

end




module TimeEstimPar

  def init()
    puts "in TimeEstimPar.init"
    super
  end

  #returns tasks already calculated by server
  # array of [@gene.id, @win_size, @fen_no]
  #used to filter sql for new tasks generation
  def tasks_already_worked_out
    @tasks_annot=[]

    iterate_over_exec_elem { |i|
      #debugging
      #next if @gene.id != 152
      #next if @win_size != 10
      #next if @fen_no != "12"

      #puts "active exec elem: #{i}"
      #prepare_input_files
      @tasks_annot << [@gene.id, @win_size, @fen_no] if File.exists? timed_tr_calc_flag(:res)

    }
    @tasks_annot


  end

  #export genes by nb_contins by window
  def exp_tasks_yaml(tasks_page_dim, task_start_nb, win_size)

    tasks = tasks_already_worked_out

    contr = ""
    tasks.each {|tsk|
      contr += "(#{tsk[0]},#{tsk[1]},#{tsk[2]}),"

    }

    contr.chomp! ","

    puts contr

    sql=<<-EOF
         select  hpf.GENE_ID,
                 gn.NAME as gene_name,
                 hpf.WIN_SIZE,
                 hpf.FEN_NO,
                 hpf.FEN_IDX_MIN,
                 hpf.FEN_IDX_MAX,
                 ((hpf.FEN_IDX_MAX - hpf.FEN_IDX_MIN) + 1) as align_len,
                 count(distinct hpf.HGT_PAR_CONTIN_ID) as nb_trsf
         from HGT_PAR_FRAGMS hpf
          join genes gn on gn.id = hpf.gene_id
         where hpf.win_size = #{win_size} and
            (hpf.GENE_ID, hpf.WIN_SIZE, hpf.FEN_NO) not in (#{contr})
         group by hpf.GENE_ID,
                  gn.NAME,
                  hpf.WIN_SIZE,
                  hpf.FEN_NO,
                  hpf.FEN_IDX_MIN,
                  hpf.FEN_IDX_MAX
         order by count(distinct hpf.HGT_PAR_CONTIN_ID) desc
    EOF


   

    puts "sql: #{sql}"

    #add limit 20
    tasks = HgtParFragm.find_by_sql(sql)

    #mrca_ids = mrcas.collect{|m| m.id}

    #puts tasks.inspect

    puts "length: #{tasks.length}"

    tasks_len = tasks.length
    #tasks_len = 1

    nb_pages = tasks_len /  tasks_page_dim
    nb_pages_rem = tasks_len % tasks_page_dim
    puts "nb_pages: #{nb_pages}, nb_pages_rem: #{nb_pages_rem}"


    page_ranges = []

    #whole pages
    nb_pages.times { |pn|
      #puts "page number: #{pn}"
      range_min = pn * tasks_page_dim
      range_max = range_min + tasks_page_dim - 1

      #puts "range_min: #{range_min}, range_max: #{range_max}"
      page_ranges << [range_min,range_max]

    }

    #adds remainder
    if nb_pages_rem != 0
      range_min = nb_pages * tasks_page_dim
      range_max = range_min + nb_pages_rem - 1
      #puts "range_min: #{range_min}, range_max: #{range_max}"
      page_ranges << [range_min,range_max]
    end


    page_ranges.each_index { |i|

      rng_min = page_ranges[i][0]
      rng_max = page_ranges[i][1]

      job_tasks = tasks[rng_min..rng_max]

      job_s = "%05d" % (task_start_nb + i )
      File.open("#{timed_tr_compart_d(:jobs)}/job-tasks-#{job_s}.yaml", "w+") do |f|
        f.puts job_tasks.to_yaml()
      end


    }


  end

  #Decorator pattern first in chain to be called
  #super in first position
  def locate_results_files

    #puts "in TimeEstimPar:locate_gene_results_files() call super"
    #call TimeEstim
    super
    #puts "in TimeEstimPar:locate_gene_results_files() returned from super"
    #sys "cat #{@output_path} | wc "
    #@treepl_cfg_tree_f = "#{@timed_tr_d}/gene_res.cfg"
    #! local files should not have gene identifier
    #should be anonymous, identification elements outside filename
    #
    #@beast_cfg_tree_f = "#{@timed_tr_d}/gene_beast.xml"
  end

  def create_work_folder(recreate = false)

    #make place
    puts "timed_tr_gene_d(:work): #{timed_tr_gene_d(:work)}"
    Dir.mkdir(timed_tr_gene_d(:work), "755".to_i(8)) unless File.exists?(timed_tr_gene_d(:work))
    puts "timed_tr_size_d(:work): #{timed_tr_size_d(:work)}"
    Dir.mkdir(timed_tr_size_d(:work), "755".to_i(8)) unless File.exists?(timed_tr_size_d(:work))
    #timed_tr_d is window directory
    puts "@timed_tr_d: #{@timed_tr_d}"

    #recreate work folder
    sys "rm -fr #{timed_tr_d(:work)}" if recreate == true
    Dir.mkdir(timed_tr_d(:work), "755".to_i(8)) unless File.exists?(timed_tr_d(:work))


  end

  def load_hgt_par_framgs_timings
    sql=<<-EOF
        select hpf.id,
               hpf.GENE_ID,
               hpf.FROM_SUBTREE,
               hpf.TO_SUBTREE,
               hpf.WIN_SIZE,
               hpf.FEN_NO,
               hpf.FEN_IDX_MIN,
               hpf.FEN_IDX_MAX
        from HGT_PAR_FRAGMS hpf
    EOF

    puts "sql: #{sql}"

    #add limit 20
    fragms = HgtParFragm.find_by_sql(sql)

    #mrca_ids = mrcas.collect{|m| m.id}

    #puts tasks.inspect

    puts "length: #{fragms.length}"

    #cache age for transfer insertion
    @hpf_timings_hsh = {}

    #fragms[0..1].each { |frag|
    fragms.each { |frag|
      puts "frag: #{frag.inspect}"
      @gene =  @genes.select { |gn| gn.id == frag.gene_id }.first
      @win_size = frag.win_size
      @fen_no = frag.fen_no
      @fen_idx_min = frag.fen_idx_min
      @fen_idx_max = frag.fen_idx_max
      #
      @win_dir = "#{@fen_no}-#{@fen_idx_min}-#{@fen_idx_max}"

      puts "@gene: #{@gene.inspect}, win_dir: #{@win_dir}"

      from_subtree = frag.from_subtree
      to_subtree = frag.to_subtree

      all_s1 = from_subtree.split(",").collect {|x| x.chomp.lstrip}
      all_s2 = to_subtree.split(",").collect {|x| x.chomp.lstrip}
      all_s = (all_s1.sort + all_s2.sort).uniq
      all_subtree = all_s.join(",")

      [:beast,:treepl].each {|tm|
        #[:treepl].each {|tm|
        #[:beast].each {|tm|
        self.timing_prog = tm

        [:med, :hpd5, :hpd95, :orig].each {|stat|
          #:treepl has no hpd
          next if [:hpd5, :hpd95, :orig].include?(stat) and tm == :treepl
          #puts "@timed_tr_template_d: #{@timed_prog_d}"
          #puts "timed_tr_dated_f(:res,:med,:nwk): #{timed_tr_dated_f(:res,:med,:nwk)}"


          #age_md[@timing_criter_id] = pt.get_age_branch(to_subtree)
          #age[[@timing_criter_id, stat]] = get_java_mrca_age(timed_tr_dated_f(:res,stat,:nwk), to_subtree, stat)
          puts "timed_tr_dated_f(:res,stat,:nwk): #{timed_tr_dated_f(:res,stat,:nwk)}"

          #if available file
          if File.size? timed_tr_dated_f(:res,stat,:nwk) 
            @hpf_timings_hsh[[frag.id,@timing_criter_id, stat]] = get_java_mrca_age(timed_tr_dated_f(:res,stat,:nwk), all_subtree, stat)
          else
            #whithout resulsts negative value
            @hpf_timings_hsh[[frag.id,@timing_criter_id, stat]] = -1
                      
          end
          


          #puts "@hpf_timings_hsh[[#{frag.id},#{@timing_criter_id}, #{stat}]]: #{@hpf_timings_hsh[[@timing_criter_id, stat]]}"
        }



      } #end timing method




    }

    #puts "@hpf_timings_hsh #{@hpf_timings_hsh.inspect}"

   
       
  end

  def insert_hgt_par_trsf_timings


    #delete timing information
    @conn.execute "truncate table #{@arTrsfTiming.table_name}"
    puts "#{@arTrsfTiming.table_name} table truncated..."
    
    #read all transfers
    trsfs = HgtParTransfer.find :all


    hptt_ins_sql = \
      "insert into hgt_par_trsf_timings
       (timing_criter_id,
        hgt_par_transfer_id,
        age_md_wg,
        age_hpd5_wg,
        age_hpd95_wg,
        age_orig_wg,
        created_at,
        updated_at)
       values
        (?,?,?,?,?,?,current_timestamp,current_timestamp);"

    @hptt_ins_sql = @jdbc_conn.prepare_statement(hptt_ins_sql);
    #prepare statements
    @jdbc_conn.set_auto_commit(false)

    #trsfs[0..1].each { |tr|
    trsfs.each { |tr|
      puts tr.inspect if tr.id.to_i % 1000 == 0

      #

      [:beast,:treepl].each {|tm|
        #[:treepl].each {|tm|
        #[:beast].each {|tm|
        self.timing_prog = tm

        @hptt_ins_sql.set_int(1,@timing_criter_id)
        @hptt_ins_sql.set_int(2,tr.id)
        @hptt_ins_sql.set_double(3,@hpf_timings_hsh[[tr.hgt_par_fragm_id,@timing_criter_id,:med]] * tr.weight)
        if tm == :beast
          @hptt_ins_sql.set_double(4,@hpf_timings_hsh[[tr.hgt_par_fragm_id,@timing_criter_id,:hpd5]] * tr.weight)
          @hptt_ins_sql.set_double(5,@hpf_timings_hsh[[tr.hgt_par_fragm_id,@timing_criter_id,:hpd95]] * tr.weight)
          @hptt_ins_sql.set_double(6,@hpf_timings_hsh[[tr.hgt_par_fragm_id,@timing_criter_id,:orig]] * tr.weight)
        else
          @hptt_ins_sql.set_null(4,java.sql.Types::DOUBLE)
          @hptt_ins_sql.set_null(5,java.sql.Types::DOUBLE)
          @hptt_ins_sql.set_null(6,java.sql.Types::DOUBLE)
        end
        #@hptt_ins_sql.setTimestamp(7, Time.now)

        @hptt_ins_sql.add_batch()



        #hptt = HgtParTrsfTiming.new
        #hptt.timing_criter_id = @timing_criter_id
        #hptt.hgt_par_transfer_id = tr.id

        #puts " age[[#{@timing_criter_id},#{:med}]]: #{ age[[@timing_criter_id,:med]]}"
        #hptt.age_md_wg = @hpf_timings_hsh[[tr.hgt_par_fragm_id,@timing_criter_id,:med]] * tr.weight
        #hptt.age_hpd5_wg = @hpf_timings_hsh[[tr.hgt_par_fragm_id,@timing_criter_id,:hpd5]] * tr.weight if tm == :beast
        #hptt.age_hpd95_wg = @hpf_timings_hsh[[tr.hgt_par_fragm_id,@timing_criter_id,:hpd95]] * tr.weight if tm == :beast
        #hptt.age_orig_wg = @hpf_timings_hsh[[tr.hgt_par_fragm_id,@timing_criter_id,:orig]] * tr.weight if tm == :beast
        #hptt.save
      }
         

    }
    @hptt_ins_sql.execute_batch()
    @jdbc_conn.commit
    @jdbc_conn.set_auto_commit(true)


  end

  def wg_per_wg

    puts "TimeEstimPar:in wg_per_wg..."

    sql=<<-END
select sum(hptt.AGE_MD_WG)/sum(hpt.WEIGHT) as md_wg_per_wg,
       sum(hptt.AGE_HPD5_WG)/sum(hpt.WEIGHT) as md_hpd5_per_wg,
       sum(hptt.AGE_HPD95_WG)/sum(hpt.WEIGHT) as md_hpd95_per_wg,
       sum(hptt.AGE_ORIG_WG)/sum(hpt.WEIGHT) as md_orig_per_wg
from HGT_PAR_TRANSFERS hpt
 join HGT_PAR_TRSF_TIMINGS hptt on hptt.HGT_PAR_TRANSFER_ID = hpt.id
where hptt.TIMING_CRITER_ID = #{@timing_criter_id}
group by hpt.HGT_PAR_FRAGM_ID
order by sum(hptt.AGE_MD_WG)/sum(hpt.WEIGHT) desc
    END

    wg_per_wg = HgtParTransfer.find_by_sql(sql)

    wg_per_wg

  end

  def load_trsfs
    puts "in TimeEstimPar:load_all_trsfs..."

    #load trsf ids
    @trsf_ids_arr = {}

    sql=<<-EOF
select distinct hpf.id
from HGT_PAR_FRAGMS hpf
where hpf.GENE_ID = #{@gene.id}
    EOF
    trsf_ids = HgtParFragm.find_by_sql(sql)
    @trsf_ids_arr = trsf_ids.collect{|seq| seq.id}
    #puts "@trsf_ids_arr: #{@trsf_ids_arr}"



    #load trsfs
    @trsfs_hsh = {}

    @trsf_ids_arr.each {|trid|
      #puts "trid: #{trid}"

      sql=<<-EOF
select distinct hpt.NCBI_SEQ_DEST_ID as dest_id
from HGT_PAR_FRAGMS hpf
 join HGT_PAR_TRANSFERS hpt on hpt.HGT_PAR_FRAGM_ID = hpf.ID
where hpf.GENE_ID = #{@gene.id} and
      hpf.ID = #{trid}
      EOF
      trsfs = HgtParTransfer.find_by_sql(sql)
      #puts "trsfs: #{trsfs[0].inspect}"
      @trsfs_hsh[trid]= trsfs.collect{|seq| seq.dest_id.to_s}
      #puts "@trsfs_hsh[#{trid}]: #{@trsfs_hsh[trid]}"


    }

  end

  def elim_invalid_timings

    @conn.execute <<-EOF
delete from HGT_PAR_TRANSFERS ht
where ht.id in (
 select hpt.id
 from  HGT_PAR_TRANSFERS hpt
  join HGT_PAR_TRSF_TIMINGS hptt on hptt.HGT_PAR_TRANSFER_ID = hpt.id
 where hptt.AGE_MD_WG < 0 or
       hptt.AGE_HPD5_WG < 0 or
       hptt.AGE_HPD95_WG < 0 or
       hptt.AGE_ORIG_WG < 0 or
       hptt.AGE_MD_WG != hptt.AGE_ORIG_WG
 )
    EOF

  end

end


module TimeEstimTreePl

  def treepl_string(id)
    #puts "mrca string assemble..."

    res = ""

    mrca_str = "mrca = #{@mrcas_timings[id].abrev} #{@mrcas_hsh[id].to_s.gsub(/[\[\],]/,"").gsub(/\"/,"")}\n"
    mrca_str+= "min = #{@mrcas_timings[id].abrev} #{@mrcas_timings[id].time_min}\n"
    mrca_str+= "max = #{@mrcas_timings[id].abrev} #{@mrcas_timings[id].time_max}\n"
    res += mrca_str
    

    return res

  end

  def r8s_string(id)
    #puts "mrca string assemble..."
    res = ""
    
    res += "MRCA #{@mrcas_timings[id].abrev} #{@mrcas_hsh[id].to_s.gsub(/[\[\],]/,"").gsub(/\"/,"")}; \n"
    res += "constrain taxon=#{@mrcas_timings[id].abrev} minage=#{@mrcas_timings[id].time_min} maxage=#{@mrcas_timings[id].time_max}; \n"
    res += "\n"

    return res
  end


  def exp_mrcas_yaml()
    puts "in exp_mrcas_yaml()"

    mrcas_hsh = {}
    #@mrcas_comprim_ids_root_a.each_with_index {|id, idx|
    @mrcas_comprim_ids_root_a.each_with_index {|id, idx|
      mrcas_hsh[idx] = treepl_string(id)

      #abrev = @mrcas_timings[id].abrev
      #time_min = @mrcas_timings[id].time_min
      #time_max = @mrcas_timings[id].time_max
      #puts "idx: #{idx}, id: #{id}, abrev: #{abrev}, time_min: #{time_min}, time_max: #{time_max} "
    }

    #puts "mrcas_hsh: #{mrcas_hsh}"
    
    #write mrcas file to disk as yaml
    File.open(timed_tr_mrcas_f(:work), "w+") do |f|
      f.puts mrcas_hsh.to_yaml()
    end


  end

  def exp_treepl_cfg

    res =""
    mrcas_str = ""
    #include root constraint
    @mrcas_comprim_ids_root_a.each_with_index {|id, idx|
      mrcas_str += treepl_string(id)
    }

    puts "mrcas_str #{mrcas_str}"

    cfg_str =<<-EOF
treefile  = gene_rooted.nwk
smooth = 100
numsites = #{align_len}

#{mrcas_str}

outfile = dated_tree.nwk
nthreads = 1
    EOF

    #write gene_res.cfg to disk
    File.open(timed_tr_treepl_cfg_f(:work), "w+") do |f|
      f.puts cfg_str
    end

  end


  def exp_r8s_cfg
     
    res =""
    mrcas_str = ""
    #include root constraint
    @mrcas_comprim_ids_root_a.each_with_index {|id, idx|
      mrcas_str += r8s_string(id)
    }

    puts "mrcas_str #{mrcas_str}"
    
    tr_str = File.open(hgt_tr_rooted_f, 'rb') { |f| f.read }
    #puts "s: #{s}"

    tr1 = Bio::Newick.new(tr_str).tree



    cfg_str =<<-EOF
#nexus
begin trees;
tree bob = #{tr_str};
end;

begin r8s;
blformat lengths=persite nsites=#{align_len} smoothing=100;

#{mrcas_str}

set ftol=1e-10 maxiter=10000;
set smoothing = 0.0001;
divtime method=pl crossv=no;
penalty=additive;
describe plot=chrono_description;


[constrain taxon=root minage=2500 maxage=4500;]
[fixage taxon=root age=4275;]
[set verbose=0; suppresses huge amount of output in CV analyses]
[divtime method=pl algorithm=tn cvStart=-4 cvInc=1 cvNum=7 crossv=yes;]
[describe plot=cladogram;]
[show rates;]
[describe plot=node_info;]
[describe plot=rato_description;]

end;


    EOF

    #write mrcas file to disk as yaml
    File.open(timed_tr_r8s_cfg_f(:work), "w+") do |f|
      f.puts cfg_str
    end

    len = align_len
    puts "len: #{len}"


    #execute
    # r8s -b -f gene_r8s.cfg > outfile.log
    #parse
    # parse bob tree.rb in admin

    

  end


end


module TimeEstimBeast

  #returns document
  def prepare_cfg_xml_doc()

    #move to working dir
    #Dir.chdir @hgt_gene_results_dir

    #use java class to root and rescale the tree
    #String inputTreeF = "/root/local/whme_beast/hgt_com/secE/gene_res.tr";
    #String inputTreeF  = "/root/local/whme_beast/hgt_com/secE/out.tre";

    #String outputTreeF =  "/root/local/whme_beast/hgt_com/secE/gene_res_rooted_scaled.tre";

    pt = JavaPalTiming.new()
    pt.setConn(@jdbc_conn)
    
    pt.loadRootedTree(timed_tr_rooted_f(:work));


    #scale tree to last constraint (for acendent order)
    time_med = @mrcas_timings[@mrcas_comprim_ids_root_a.last].time_med

    #scale tree to first constraint (for descendent order)
    #time_med = @mrcas_timings[@mrcas_comprim_ids_root_a.first].time_med

    puts "gene: #{@gene.name}, time_med: #{time_med}, last id: #{@mrcas_comprim_ids_root_a.last}"
    #sleep 5


    pt.set_root_age time_med
    pt.scale_rooted_tree();    
    pt.save_rooted_tree(timed_tr_rooted_scaled_f(:work))   
    pt.calculate_rstatistics
       
      
    
    #pt.load_unrooted_tree(timed_tr_unrooted_f(:work))
    #pt.midpoint_root_tree
    #scale to root of prokaryotes
    
    #puts "estimate: rate: #{pt.getFdrExpMeanRate}"
    #puts "sd      : rate: #{pt.getFdrExpSdRate}"
    
    puts "mean: #{pt.getRstNormalMean}"
    puts "sd  : #{pt.getRstNormalStdev}"
    puts "mu: #{pt.getRstLogNormalMu}"    
    puts "sg: #{pt.getRstLogNormalSigma}"
    
    
    #puts "estimate: mean: #{pt.get_fdr_estimate_meanlog} sd: #{pt.get_fdr_estimate_sdlog}"
    #puts "sd      : mean: #{pt.get_fdr_sd_meanlog} sd: #{pt.get_fdr_sd_sdlog}"
    
    

    #open template
    puts "@timed_tr_template_xml_f: #{beast_template_cfg_tree_f}"
    #f = File.open(@beast_template_cfg_tree_f)
    # doc = Nokogiri::XML(f)


    #f.close
    #puts "doc: #{doc.to_s}"

    #get template
    doc = Nokogiri::XML(File.open(beast_template_cfg_tree_f)) { |config|
      config.strict.nonet
    }

    #tree_seq = Nokogiri::XML::Node.new "sss", doc
    #tree_seq.content = "This is the sequence"



    #foo  = frag.children.first
    #foo.swap( Nokogiri::XML::Text.new( "bar", foo.document ) )
    #puts frag

    #read java generate tree
    timed_tr_rooted_scaled = File.open(timed_tr_rooted_scaled_f(:work), 'rb') { |f| f.read }
    #timed_tr_rooted_scaled.gsub!(/\n/, "")

    #replace template node with sequence
    frag = doc.search("//to_replace_starting_tree").first
    frag.swap( Nokogiri::XML::Text.new( timed_tr_rooted_scaled, frag.document ) )

    puts "frag: #{frag}"

    # Lognormal relaxed clock with normal mean and stdev
    model_ucld_mean_n = doc.search("//logNormalDistributionModel/mean/parameter[@id='ucld.mean']").first
    model_ucld_mean_n["value"]=pt.getRstNormalMean.to_s
    puts "model_ucld_mean_n: #{model_ucld_mean_n}"
    
    model_ucld_stdev_n = doc.search("//logNormalDistributionModel/stdev/parameter[@id='ucld.stdev']").first
    model_ucld_stdev_n["value"]=pt.getRstNormalStdev.to_s
    puts "model_ucld_stdev_n #{model_ucld_stdev_n}"

    
    prior_ucld_mean_n = doc.search("//prior[@id='prior']/lognormalPrior[parameter[@idref='ucld.mean']]").first
    puts "prior_ucld_mean_n: #{prior_ucld_mean_n}"
    
    prior_ucld_mean_n["mean"]=pt.getRstLogNormalMu.to_s
    prior_ucld_mean_n["stdev"]=pt.getRstLogNormalSigma.to_s
    #puts "prior_ucld_mean_n: #{prior_ucld_mean_n}"
    
    prior_ucld_stdev_n = doc.search("//prior[@id='prior']/exponentialPrior[parameter[@idref='ucld.stdev']]").first
    prior_ucld_stdev_n["mean"]=pt.getRstNormalStdev.to_s
    #prior_ucld_stdev_n["stdev"]=pt.get_fdr_sd_sdlog.to_s
    #puts "prior_ucld_stdev_n #{prior_ucld_stdev_n}"
    
    
    
    # replace log normal priors
    #prior_ucld_mean_n = doc.search("//prior[@id='prior']/logNormalPrior[parameter[@idref='ucld.mean']]").first
    #prior_ucld_mean_n["mean"]=pt.get_fdr_estimate_meanlog.to_s
    #prior_ucld_mean_n["stdev"]=pt.get_fdr_estimate_sdlog.to_s
    #puts "prior_ucld_mean_n: #{prior_ucld_mean_n}"
    #
    #
    #model_ucld_mean_n = doc.search("//logNormalDistributionModel/mean/parameter[@id='ucld.mean']").first
    #model_ucld_mean_n["value"]=pt.get_fdr_estimate_meanlog.to_s
    #puts "model_ucld_mean_n: #{model_ucld_mean_n}"
    #
    # this is subject to question
    # alternative get_fdr_estimate_sdlog
    #model_ucld_stdev_n = doc.search("//logNormalDistributionModel/stdev/parameter[@id='ucld.stdev']").first
    #model_ucld_stdev_n["value"]=pt.get_fdr_sd_meanlog.to_s
    #puts "model_ucld_stdev_n #{model_ucld_stdev_n}"





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

    f= fasta_align_f(:work)
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


    return doc
   

  end


  #takes as input the nokogiri xml doc
  def add_mrcas_to_cfg_xml_doc(doc)

    taxa_n = doc.search("//taxa[@id='taxa']").first
    #prior_ucld_mean_n["mean"]=pt.get_fdr_estimate_meanlog.to_s
    #prior_ucld_mean_n["stdev"]=pt.get_fdr_estimate_sdlog.to_s
    puts "taxa_n: #{taxa_n}"

    taxon_sets_n = doc.search("//descendant::comment()[contains(.,'Taxon')]").first
    #taxon_sets_n = doc.search("//treeModel[@id='treeModel']").first

    priors_n = doc.search("//mcmc[@id='mcmc']/posterior[@id='posterior']/prior[@id='prior']").first


    #taxon_sets_n.each { |ts|
    #  puts "ts: #{ts.content}"
    #}
      
    
    #cycle mrcas
    #for BEAST
    @mrcas_comprim_ids_root_a.each_with_index {|mr, idx|
      abrev = @mrcas_timings[mr].abrev
      time_med = @mrcas_timings[mr].time_med
      stdev = @mrcas_timings[mr].stdev
      puts "idx: #{idx}, nd: #{mr}, abrev: #{abrev}, time_med: #{time_med}, stdev: #{stdev} "
    }



    #each remaining constraint after compression
    @mrcas_comprim_ids_root_a.each_with_index {|id, idx|
      abrev = @mrcas_timings[id].abrev
      time_med = @mrcas_timings[id].time_med
      stdev = @mrcas_timings[id].stdev
      time_min = @mrcas_timings[id].time_min
      time_max = @mrcas_timings[id].time_max
      
      puts "idx: #{idx}, id: #{id}, abrev: #{abrev}, time_med: #{time_med}, stdev: #{stdev} "

      mr_id = "mrca_#{abrev}"
      mr_ncbi_seqs =  @mrcas_hsh[id]
    
      #do not add useless constraints
      #next if mr_ncbi_seqs.empty?
      #puts "mrcas[#{x}]: #{mr.inspect}"
     
      mrca_n = doc.create_element "taxa"
      mrca_n["id"]= mr_id

      mr_ncbi_seqs.each {|seqid|
        #
        sln = win_seq(seqid.to_s).gsub /-/, ""
        puts "id: #{seqid.to_s}, sln: #{sln}, len: #{sln.length}"
        next if sln.length < 1
        #next if

        tx_ref_n = doc.create_element "taxon"
        tx_ref_n["idref"]= seqid.to_s
        #tx_ref_n.content = ""
        mrca_n.add_child(doc.create_text_node("\n\t\t"))
        mrca_n.add_child(tx_ref_n)
      }

      #first node than formatting
      taxa_n.add_next_sibling(mrca_n)
      #add formating
      taxa_n.add_next_sibling(doc.create_text_node("\n\t"))

      #taxon sets
      #taxon_sets_n = doc.search("//descendant::comment()[text()='Taxon Sets']")
      

      #prior_ucld_mean_n["mean"]=pt.get_fdr_estimate_meanlog.to_s
      #prior_ucld_mean_n["stdev"]=pt.get_fdr_estimate_sdlog.to_s
      #puts "taxa_n: #{taxa_n}"

      # Taxon Sets
      #no need to name each small element
      ts_t = \
        "<tmrcaStatistic id=\"tmrca(#{mr_id})\" includeStem=\"false\">
\t\t<mrca>
\t\t\t<taxa idref=\"#{mr_id}\"/>
\t\t</mrca>
\t\t<treeModel idref=\"treeModel\"/>
\t</tmrcaStatistic>"

      ts_n = doc.parse(ts_t)

      #tst = doc.create_element("tmrcaStatistic", {:id => "tmrca(#{mr_id})",:includeStem => "false"})
      #tst.add_child(  txn = doc.create_element "taxa", :idref => mr_id
      #mrn = (doc.create_element "mrca").add_child txn
      
      #mn.add_child tn

      #tn = doc.create_element "treeModel", :idref => "treeModel"


      

      
      #sn.add_child mn
      #sn.add_child tn
      
    
                                 


      #ts_n = doc.create_element "tmrcaStatistic"
      #ts_n["id"]= "tmrca(#{mr_id})"
      #ts_n["includeStem"]= "false"


      #puts "ts_n: #{ts_n.inspect}"

      #first node than formatting
      taxon_sets_n.add_next_sibling(ts_n)
      #add formating
      taxon_sets_n.add_next_sibling(doc.create_text_node("\n\t"))

      #puts "taxon_sets_n: #{taxon_sets_n.inspect}"


      #now put constraints
      #puts "priors_n: #{priors_n}"

      if abrev == "lca"
        np_t=<<-EOF
      <uniformPrior lower="#{time_min}" upper="#{time_max}">
\t\t\t\t\t<statistic idref=\"tmrca(#{mr_id})\"/>
\t\t\t\t</uniformPrior>
        EOF
        puts "gene: #{@gene.name}  ----------    uniformPrior  "
        #sleep 5

      else
        np_t = \
          "<normalPrior mean=\"#{time_med}\" stdev=\"#{stdev}\">
\t\t\t\t\t<statistic idref=\"tmrca(#{mr_id})\"/>
\t\t\t\t</normalPrior>"
      
      
      end

      np_n = doc.parse(np_t)

      priors_n.add_child(doc.create_text_node("\t"))
      priors_n.add_child(np_n)
      priors_n.add_child(doc.create_text_node("\n\t\t\t"))

      
    }


    #cur.add_next_sibling(mrca_n)
    #cur.add_next_sibling(doc.create_text_node("\n\t\t"))



    #mrca_n = doc.create_element "taxa", "contents", :id => "mrca1"
    #mrca_n.add_child(doc.create_text_node("\n\t\t"))


    #doc.create_text_node("\n\t\t")

    #taxa_n.add_next_sibling(mrca_n)

    #h3 = Nokogiri::XML::Node.new "h3", @doc
    #h3.content = "1977 - 1984"
    #h1.add_next_sibling(h3)



    
    return doc

  end


  #save doc to xml file
  def save_cfg_xml_file(doc)

    # Save a string to a file.
    a_file = File.new( beast_cfg_tree_f(:work), "w")
    a_file.write(doc)
    a_file.close


  end


  def win_seq(id)
    @win_seq_hsh[id]
  end

  #load alignment in memory for constraints checking as @win_seq_hsh
  #also write it to file
  def  prepare_local_fasta_align

    puts "in prepare_local_fasta_align..."
    case @stage
    when "hgt-com"
      #local copy fasta alignement
      #FileUtils.cp(fasta_align_f(:orig),fasta_align_f(:work))
      #get whole alignment
      oa = @ud.fastafile_to_original_alignment fasta_align_f(:orig)
      #no slice, just collect
      @win_seq_hsh = oa.alignment_collect() { |str| str }
      #save
      puts "fasta_align_f(:work): #{fasta_align_f(:work)}"
      @ud.seqshash_to_fastafile(@win_seq_hsh,fasta_align_f(:work))

    when "hgt-par"
      #get whole alignment
      oa = @ud.fastafile_to_original_alignment fasta_align_f(:orig)
      #slice
      @win_seq_hsh = oa.alignment_collect() { |str|
        str[self.fen_idx_min..self.fen_idx_max]
      }
      #save
      puts "fasta_align_f(:work): #{fasta_align_f(:work)}"
      @ud.seqshash_to_fastafile(@win_seq_hsh,fasta_align_f(:work))

    end

    
  end

  def prepare_exec_files

    prepare_local_fasta_align
    
    doc = prepare_cfg_xml_doc
    
    doc = add_mrcas_to_cfg_xml_doc(doc)
      
    save_cfg_xml_file(doc)
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

  #stat :med - median, :hpd5 - height_95%_HPD min , :hpd95 - height_95%_HPD
  def parse_height(str, stat)
    puts "str: #{str}"
    res = ""

    # 2 values interval
    rx = /height_95%_HPD=\{(.*?),(.*?)\}/
    z = str.gsub(rx) {
      res = case(stat)
      when :hpd5 then $1
      when :hpd95 then $2
      end
    }

    #single value
    #rx = /height_median=(\d*\.*\d*E)/
    rx = /height_median=(\d*\.*\d*E*-*\d*)/
    
    z = str.gsub(rx) {
      res = $1 if stat == :med
    }

    #null root values
    res = 0.0 if res==""
    #return node statistic as branch length
    #! these are NOT additive trees
    ":#{res}"
    
  end

  def parse_nexus_tree(str, stat)

    #puts "str: #{str}"

    rx = /\[&(.+?)\](:\d*\.?\d*){0,1}/
    tree_str =  str.gsub(rx) { "#{parse_height($1, stat)}" }

    #puts "tree_str: #{tree_str}"

    "#{tree_str}"


  end


  #stat :med - median, :hpd5 - height_95%_HPD min , :hpd95 - height_95%_HPD
  def parse_tree_annot(stat)

    puts "timed_tr_annot_f(:res): #{timed_tr_annot_f(:res)}"

    s = File.open(timed_tr_annot_f(:res), 'rb') { |f| f.read }
    s = s.chomp

    rx = /tree\sTREE1\s=\s\[&R\]\s(.*);\s*End;/
    #puts paranthesis around tree for figtree
    tree_str =  s.gsub(rx) { "tree TREE1 = [&R] (#{parse_nexus_tree($1, stat)});\nEnd; "}
    #no anymore for java PAL parsing
    #tree_str =  s.gsub(rx) { "tree TREE1 = [&R] #{parse_nexus_tree($1, stat)};\nEnd; "}

    #puts "tree_str: #{tree_str}"

    #write statistic dated tree in nexus format
    puts ":res: #{:res}, stat: #{stat}, :nex: #{:nex}, timed_tr_dated_f(:res, stat, :nex): #{timed_tr_dated_f(:res, stat, :nex)}"
    File.open( timed_tr_dated_f(:res, stat, :nex), "w") do |f|
      f.puts tree_str
    end

  
  end

  

end

module TimeEstimConfig
  #  ruby> class Fruit
  #    |   def kind=(k)
  #    |     @kind = k
  #    |   end
  #    |   def kind
  #    |     @kind
  #    |   end
  #    | end
  #   nil
  #ruby> f2 = Fruit.new
  #   #<Fruit:0xfd7e7c8c>
  #ruby> f2.kind = "banana"
  #   "banana"
  #ruby> f2.kind
  #   "banana"

  #timing trees files 

  def init()
    puts "in TimeEstimConfig.init()"
    super
  end

  def timed_prog_d
    case @stage
    when "hgt-com"
      "#{AppConfig.hgt_com_dir}/hgt-com-#{@phylo_prog}/timing/#{@timing_prog.to_s}"
    when "hgt-par"
      #
      #"#{AppConfig.hgt_par_dir}/timing/#{@timing_prog.to_s}/"
      "#{AppConfig.hgt_par_dir}/timing/#{@timing_prog.to_s}/#{@phylo_prog}"
    end

  end

  def remote_timed_prog_d
    case @stage
    when "hgt-com"
      "#{AppConfig.remote_hgt_com_dir}/hgt-com-#{@phylo_prog}/timing/#{@timing_prog.to_s}"
    when "hgt-par"
      "#{AppConfig.remote_hgt_par_dir}/timing/#{@timing_prog.to_s}"
    end

  end

  #floc = :jobs, :work, :res, :templ
  def timed_tr_compart_d(floc)

    case floc
    when :jobs
      "#{timed_prog_d}/jobs"
    when :work
      "#{timed_prog_d}/work"
    when :res
      "#{timed_prog_d}/results"
    when :templ
      "#{timed_prog_d}/templ"
    else
      raise "Please review timed_tr_compart_d options !"

    end

  end

  
  #remote MP2
  #floc = :jobs, :work, :res
  def remote_timed_tr_compart_d(floc)

    case floc
    when :jobs
      "#{remote_timed_prog_d}/jobs"
    when :work
      "#{remote_timed_prog_d}/work"
    when :res
      "#{remote_timed_prog_d}/results"
    end

  end

  #floc = :work, :res
  def timed_tr_gene_d(floc)
    "#{timed_tr_compart_d(floc)}/#{@gene.name}"
  end
  
  #floc = :work, :res
  def timed_tr_size_d(floc)
    "#{timed_tr_gene_d(floc)}/#{@win_size}"
    
  end

  #calculation active working folder
  #floc = :work, :res
  def timed_tr_d(floc)
    
    case @stage
    when "hgt-com"
      #working dir is same as gene dir
      #there are no sizes and windows
      timed_tr_gene_d(floc)
    when "hgt-par"
      "#{timed_tr_size_d(floc)}/#{@win_dir}"
    end


  end

  #only for partial transfers
  #there are windows

  def hgt_genes_dir
    case @stage
    when "hgt-par"
      #moved
      #"#{AppConfig.hgt_par_dir}/hgt-par-#{@phylo_prog}-#{@win_size}"
      Pathname.new "#{AppConfig.hgt_par_dir}/hgt/#{@phylo_prog}/results"
    else
      Raise "Error in stages options !"
    end


  end

  def hgt_valid_win_path
    case @stage
    when "hgt-par"       
      "#{hgt_genes_dir}/#{@gene.name}/valid_win.idx"
    else
      Raise "Error in stages options !"
    end
  end

  def hgt_win_path 
    case @stage
    when "hgt-par"       
      #"#{hgt_genes_dir}/#{@gene.name}/#{@win_dir}"
      #moved
      hgt_genes_dir + @gene.name + "#{@win_size}/#{@win_dir}"
    else
      Raise "Error in stages options !"
    end
    
    
  end


  #original gene tree
  def phylo_prog_best_tree_f
    case @stage
    when "hgt-com"
      "#{AppConfig.hgt_com_dir}/gene_blo_seqs_#{@phylo_prog}/results/#{@gene.name}/RAxML_bipartitions.#{@gene.name}.re"
    when "hgt-par"
      "#{AppConfig.hgt_par_dir}/phylo/#{@phylo_prog}/results/#{@gene.name}/#{@win_size}/#{@win_dir}/RAxML_bipartitions.fen_align.re"

    end
  end

  def hgt_inpfile_f
    case @stage
    when "hgt-com"
      "#{AppConfig.hgt_com_dir}/hgt-com-#{@phylo_prog}/inp-files/#{@gene.name}-inputfile"
    when "hgt-par"
      "#{hgt_win_path}/input.txt"

    end
  end
  
  #local hgt3.4 to obtain root bipartition
  def hgt34_f
    Pathname.new "#{AppConfig.hgt_com_dir}/hgt-com-#{@phylo_prog}/bin/hgt3.4"
  end


  def hgt_results_dir
    case @stage
    when "hgt-com"
      "#{AppConfig.hgt_com_dir}/hgt-com-#{@phylo_prog}/results"
    end
  end

  def hgt_gene_results_dir
    case @stage
    when "hgt-com"
      "#{hgt_results_dir}/hgt-com-#{@phylo_prog}_gene#{@gene.name}_id#{@gene.id}.BQ"
    end
  end
  
  #hgt_results_f
  def hgt_results_f 
    case @stage
    when "hgt-com"
      "#{hgt_gene_results_dir}/output.txt"
    when "hgt-par"
      "#{hgt_win_path}/output.txt"
    end
  end

  def hgt_unrooted_dir
    case @stage
    when "hgt-com"
      Pathname.new "#{hgt_gene_results_dir}/unrooted_tree"
    when "hgt-par"
      Pathname.new "#{hgt_win_path}/unrooted_tree"
    end
  end
  
  def hgt_root_part_f
    case @stage
    when "hgt-com"
      "#{hgt_unrooted_dir}/geneRootLeaves.txt"
    when "hgt-par"
      #"#{hgt_unrooted_dir}/geneRootLeaves.txt"
      Pathname.new hgt_win_path + "geneRootLeaves.txt"
    end
  end


  def hgt_tr_unrooted_f
    case @stage
    when "hgt-com"
      "#{hgt_unrooted_dir}/gene_res.tr"
    when "hgt-par"
      "#{hgt_unrooted_dir}/gene_res.tr"
    end

  end

  def hgt_tr_rooted_f
    case @stage
    when "hgt-com"
      "#{hgt_unrooted_dir}/hgt_tr_rooted.nwk"
    when "hgt-par"
      "#{hgt_unrooted_dir}/hgt_tr_rooted.nwk"
    end
  end




   
  #mrcas are to be input files
  #mrca constraints are gene level
  def mrcas_gene_f
    "#{timed_tr_gene_d(:work)}/mrcas.yaml"
  end

  
  

  #only beast has annotations
  #this file is in NEXUS format
  def timed_tr_annot_f(floc)

    case @timing_prog
    when :beast
      "#{timed_tr_d(floc)}/dated_tree.annot"
    end


  end

  #only beast has med, hpd5, hpd95 in name
  #treepl is just dated_tree
  #stat :med - median, :hpd5 - height_95%_HPD min , :hpd95 - height_95%_HPD
  #frm  :nwk, :nex
  def timed_tr_dated_f(floc, stat, frm)

    case @timing_prog
    when :treepl
      "#{timed_tr_d(floc)}/dated_tree.#{frm.to_s}"
    when :beast
      "#{timed_tr_d(floc)}/dated_tree_#{stat.to_s}.#{frm.to_s}"
    end
    
  end

  #flag to singnify calculations on cluster are done
  #before parse_all_output_files()
  def timed_tr_calc_flag(floc)
    case @timing_prog
    when :treepl
      "#{timed_tr_d(floc)}/dated_tree.nwk"
    when :beast
      "#{timed_tr_d(floc)}/dated_tree.annot"
    end

  end

  def timed_tr_rooted_f(floc)
    "#{timed_tr_d(floc)}/gene_rooted.nwk"

  end

  def timed_tr_rooted_scaled_f(floc)
    "#{timed_tr_d(floc)}/starting_tree.nwk"

  end

  def timed_tr_mrcas_f(floc)
    "#{timed_tr_d(floc)}/mrcas.yaml"

  end

  def timed_tr_r8s_cfg_f(floc)
    "#{timed_tr_d(floc)}/gene_r8s.cfg"

  end

  def timed_tr_treepl_cfg_f(floc)
    "#{timed_tr_d(floc)}/gene_res.cfg"

  end





 
  

  def beast_template_cfg_tree_f
    "#{timed_tr_compart_d(:templ)}/beast_template2.xml"

  end

  def beast_cfg_tree_f(floc)
    "#{timed_tr_d(floc)}/gene_beast.xml"

  end

  #floc = :orig, :work
  def fasta_align_f(floc)

    #same for "hgt-com" and "hgt-par"
    orig_f = "#{AppConfig.hgt_com_dir}/gene_blo_seqs_msa/fasta/#{@gene.name}.fasta"

    #orig_f = ""
    #case @stage
    #when "hgt-com"
      
    #when "hgt-par"
    #  raise "To be determined by slicing with bioruby on windows paramenters !"
    #  orig_f = ""
    #end

    case floc
    when :work
      #! local files should not have gene identifier
      #  should be anonymous, identification elements outside filename
      "#{timed_tr_d(floc)}/align_beast.fasta"
    when :orig
      orig_f
    else
      raise "Please review fasta_align_f options !"
    end

  end

  #timing reports
  #root is same as criter directory
  def tm_base_d
    exp_crit_d
  end

  def tm_base_name
    "#{@stage}-#{crit}-#{phylo_prog}-#{thres}-#{hgt_type.to_s}"
  end

  #form :rel, :abs
  # stat [:med,:hpd5,:hpd95]
  #timing prog tm [:treepl, :beast, :all]
  #when for all timing progs not specified
  #default parameter
  def tm_csv_f(form, stat, tm = :all)

    case form
    when :rel
      "#{tm_base_name}-#{tm.to_s}-#{stat.to_s}-#{hg_step.to_s}.csv"
    when :abs
      "#{tm_base_d}/csv/#{tm_csv_f(:rel,stat,tm)}"
    end

  end

  def tm_bp_erb
    "bp.gp.erb"
  end

  #def tm_bp_erb_f
  #  "#{tm_base_d}/erb/#{tm_bp_erb}"
  #end

  def tm_kn_erb
    "kn.gp.erb"
  end

  def tm_kn_erb_f
    "#{tm_base_d}/erb/#{tm_kn_erb}"
  end

  def tm_hg_erb
    "hg.gp.erb"
  end

  def tm_hg_erb_f
    "#{tm_base_d}/erb/#{tm_hg_erb}"
  end

  def tm_bp_name
    "#{tm_base_name}-bp"
  end

  def tm_kn_name
    "#{tm_base_name}-kn"
  end

  def tm_hg_name
    "#{tm_base_name}-#{hg_step}-hg"
  end

  def tm_qq_name
    "#{tm_base_name}-qq"
  end




end

module TimeEstim
  
  #def time_estim_init()
  #end


  #attr_accessor :opt

  attr_reader :timing_prog

  attr_writer :fen_idx_min,
    :fen_idx_max


  def fen_idx_min
    @fen_idx_min.to_i
  end

  def fen_idx_max
    @fen_idx_max.to_i
  end

  def initialize
   

  end


  def init
    puts "in TimeEstim.init"
    #@opt = {}
    #@opt[:calc_procs] = []

    #file names


   


    #puts "@stage: #{@stage}"
    #    super
    #init new extended modules
    super

  end

  #Decorator pattern last in chain to be called
  def locate_results_files
    #puts "in TimeEstim:locate_results_files "

  end

  #timing prog :beast, :treepl
  def timing_prog=(timing_prog)
    #puts "called timing_prog= #{timing_prog}"
    #sleep 0.01
    @timing_prog=timing_prog

    @timing_criter_abrev = @timing_prog.to_s
    #too slow
    #@timing_criter_id = TimingCriter.find_by_abrev(@timing_criter_abrev).id
    
    @timing_criter_id = case(@timing_criter_abrev)
    when "beast" then 0
    when "treepl" then 1
    else raise "invalid value"
    end
    
    
    #puts "@timing_criter_id: #{@timing_criter_id}"
    
    #@beast_template_cfg_tree_f = "#{@timed_prog_d}/beast_template2.xml"
    
    extend TimeEstimBeast if @timing_prog == :beast
    extend TimeEstimTreePl if @timing_prog == :treepl

    
    

  end

  
  #floc = :jobs, :work, :res
  def rsync_folder(floc)

    case floc
    when :jobs, :work
      sys "rsync -avzx --del #{timed_tr_compart_d(floc)}/ #{AppConfig.remote_server}:#{remote_timed_tr_compart_d(floc)}/"
    when :res
      sys "rsync -avzx --del #{AppConfig.remote_server}:#{remote_timed_tr_compart_d(floc)}/ #{timed_tr_compart_d(floc)}/ "
    else
      raise "Please review rsync options !"
    end
    

  end

  def rsync_proc_hom_ex()
    sys "rsync -avzx --del #{AppConfig.proc_hom_ex}/  #{AppConfig.remote_server}:#{AppConfig.remote_proc_hom_ex}/"
  end


=begin
  def iterate_over_exec_elem(&aproc)
    cnt = 0

    #@genes[81..109].each { |gn|
    @genes.each { |gn|
      @gene = gn
      #debugging
      #172 = secE, the smallest gene, without transfers
      #132 = thrC, the second smallest gene, with transfers
      #152 = oppA, problem in window 10/12-275-313 with all gaps
      #next if @gene.id != 152
      #puts "cnt: #{cnt}, gn.id: #{@gene.id}, gn.name: #{@gene.name}, @genes[cnt]: #{@genes[cnt].id}"
      
      if @stage=="hgt-par"
        iterate_over_win() { |win|
          aproc.call "gn: #{@gene.id}, win: #{win}"
        }
      else
        aproc.call "gn: #{@gene.id}"
      end

      #index starts at 0, so incremented at the end
      cnt += 1
    }
    


  end

  #skip windows with no hgt results: output.txt
  def iterate_over_win(&aproc)
    
    [10,25,50].each { |win_size|
      @win_size = win_size

      File.open(hgt_valid_win_path,"r") { |vwf|

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

          #skip if no results in window
          next if not File.exists?(hgt_results_f)

          aproc.call "win_size: #{@win_size}, fen_no: #{@fen_no}, fen_idx_min: #{@fen_idx_min}, fen_idx_max: #{@fen_idx_max}"

        } #win_dir
      } #vwp

    } #win size

  end
=end

  

  #BAD contains constants 0..25 inside
  def load_mrcas

    @mrcas_active_ids = []

    @mrcas_hsh = {}

    #load original mrcas
    
    (0..25).each {|mrca_id|
       
     
      sql=<<-EOF
select gbs.NCBI_SEQ_ID
from gene_blo_seqs gbs
 join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
 join TAXON_GROUPS tg on tg.TAXON_ID = ns.TAXON_ID
where gene_id = #{@gene.id} and
      tg.PROK_GROUP_ID in (select mpg.PROK_GROUP_ID
                           from mrcas m
                            join MRCA_PROK_GROUPS mpg on mpg.MRCA_ID = m.id
                           where id = #{mrca_id}
                          )
      EOF
      ncbi_seqs = GeneBloSeq.find_by_sql(sql)
      @mrcas_hsh[mrca_id]= ncbi_seqs.collect{|seq| seq.ncbi_seq_id.to_s}
      @mrcas_active_ids << mrca_id if @mrcas_hsh[mrca_id].length != 0
      #puts "@mrcas_hsh[#{mrca_id}]: #{@mrcas_hsh[mrca_id]},#{@mrcas_hsh[mrca_id].length} "
    }
        
    
    #    if ncbi_seqs.length !=0
    #      mrca_str = "mrca = #{mr.abrev} #{ncbi_seqs.collect{|seq| seq.ncbi_seq_id}.to_s.gsub(/[\[\],]/,"")}\n"
    #      mrca_str+= "min = #{mr.abrev} #{mr.time_min}\n"
    #      mrca_str+= "max = #{mr.abrev} #{mr.time_max}\n"
    #      res += mrca_str
    #    end


    #puts "@mrcas_active_ids: #{@mrcas_active_ids.inspect}"


  end

  #
  def verify_mrcas

    @mrcas_deleted_ids = []
    @mrcas_affected_ids = []

    s = File.open(hgt_tr_rooted_f, 'rb') { |f| f.read }
    #puts "s: #{s}"

    tr1 = Bio::Newick.new(s).tree

    #
    @mrcas_active_ids.each { |ma|
      #next if ma !=0

      active_mrca = @mrcas_hsh[ma]

      #puts "len: #{active_mrca.length}, active_mrca: #{active_mrca}"

      #find mrca_node de active_mrca
      mrca_node = tr1.get_node_by_name(active_mrca.first);
      active_mrca.each {|rn|
        ntemp = tr1.get_node_by_name(rn);
        mrca_node = tr1.lowest_common_ancestor(mrca_node, ntemp)
      }
      #puts "mrca_node: #{mrca_node.inspect}"
      #puts "tr1.nodes #{tr1.nodes()}"

      #


      #puts "------------>"
      @cumul_trsf = @trsf_ids_arr.collect{|ti| @trsfs_hsh[ti]}.flatten.uniq
      #puts "@cumul_trsf: #{@cumul_trsf}"
      #puts "------------>"

      diff_mrca = active_mrca - @cumul_trsf
      #puts "len: #{diff_mrca.length}, diff_mrca: #{diff_mrca}"

      #find diff_node de diff_mrca
      diff_node = tr1.get_node_by_name(diff_mrca.first);
      diff_mrca.each {|rn|
        ntemp = tr1.get_node_by_name(rn);
        diff_node = tr1.lowest_common_ancestor(diff_node, ntemp)
      }
      #puts "diff_node: #{diff_node.inspect}"


      @mrcas_deleted_ids << ma if diff_node != mrca_node
      @mrcas_affected_ids << ma if diff_mrca != active_mrca
      #if diff_node == mrca_node
      #   puts "===============same node"
      # else
      #   puts "===============different node"
      # end

      #check if constraint is more than a leaf
      @mrcas_deleted_ids << ma if active_mrca.length < 2

      #check if each leave exists
      if not @mrcas_deleted_ids.include?(ma)
        active_mrca.each { |leaf|
          #puts "testing: #{leaf} == #{tr1.get_node_by_name(leaf)}"
          @mrcas_deleted_ids << ma if tr1.get_node_by_name(leaf).nil?
        }
      end

    }

    puts "gene: #{@gene.id}, #{@gene.name}"
    puts "@mrcas_original_ids: #{@mrcas_active_ids.length}, #{@mrcas_active_ids}"
    puts "@mrcas_affected_ids: #{@mrcas_affected_ids.length}, #{@mrcas_affected_ids}"
    puts "@mrcas_deleted_ids: #{@mrcas_deleted_ids.length}, #{@mrcas_deleted_ids}"
    @mrcas_active_ids = @mrcas_active_ids - @mrcas_deleted_ids
    puts "@mrcas_active_ids: #{@mrcas_active_ids.length}, #{@mrcas_active_ids}"
    #sleep 5
    


  end

  #remove multiple constraints to same tree nodes
  #let first = newer or let larger interval
  def comprim_mrcas

    #comprim ids for unique nodes
    @mrcas_unique_nodes_a = []
    @mrcas_node_constr_ids_h = {}
    #migrate timings on last constraint of the node
    @mrcas_comprim_ids_root_a = []
    @mrcas_comprim_ids_noroot_a = []

    tr_s = File.open(hgt_tr_rooted_f, 'rb') { |f| f.read }
    #puts "s: #{s}"

    tr1 = Bio::Newick.new(tr_s).tree


    #for all standing ids group by unique node
    @mrcas_active_ids.each_with_index {|id, idx|
      puts "idx: #{idx}, id: #{id}, min: #{@mrcas_timings[id].time_min}, max: #{@mrcas_timings[id].time_max}, med: #{@mrcas_timings[id].time_med}, calc_st: #{calc_stdev([id])}, old_st: #{@mrcas_timings[id].stdev}"

      #recalculate stdev
      @mrcas_timings[id].stdev = calc_stdev([id]) || 0.0

      #find node of active id
      active_mrca = @mrcas_hsh[id]

      mrca_node = tr1.get_node_by_name(active_mrca.first);
      active_mrca.each {|rn|
        ntemp = tr1.get_node_by_name(rn);
        mrca_node = tr1.lowest_common_ancestor(mrca_node, ntemp)
      }

      #new node, add it
      #create entry in constraints hash
      if @mrcas_unique_nodes_a.include? mrca_node.object_id
        @mrcas_node_constr_ids_h[mrca_node.object_id] << id
      else
        @mrcas_unique_nodes_a << mrca_node.object_id
        @mrcas_node_constr_ids_h[mrca_node.object_id] = [id]

      end
  
    }

    
    #calculate aggregate timings for each node
    @mrcas_unique_nodes_a.each_with_index {|nd, idx|
      cids = @mrcas_node_constr_ids_h[nd]
=begin
      time_min = calc_time_min(cids)
      time_max = calc_time_max(cids)
      time_med = calc_time_med(cids)
      stdev = calc_stdev(cids)
      puts "idx: #{idx}, nd: #{nd}, cids: #{cids.inspect}, time_min: #{time_min}, time_max: #{time_max}, time_med: #{time_med}, stdev: #{stdev} "


      #transfer timing on last element and create resulting ids
      @mrcas_timings[cids.last].time_min = time_min
      @mrcas_timings[cids.last].time_max = time_max
      @mrcas_timings[cids.last].time_med = time_med
      @mrcas_timings[cids.last].stdev = stdev

      #keep only last element
      @mrcas_comprim_ids_root_a << cids.last

      #exclude root mrca = 25
      @mrcas_comprim_ids_noroot_a << cids.last if not cids.include? 25
      
      
=end


      #=begin
      #keep timing of first element
      #already loaded

      #keep only first element
      @mrcas_comprim_ids_root_a << cids.first
      #exclude root mrca = 25
      @mrcas_comprim_ids_noroot_a << cids.first if not cids.include? 25
      #=end

    }

    #verify results
    puts "@mrcas_comprim_ids_root_a: #{@mrcas_comprim_ids_root_a.inspect}"
    puts "@mrcas_comprim_ids_noroot_a: #{@mrcas_comprim_ids_noroot_a.inspect}"

    #sleep 10
    #for treepl/r8s
    #@mrcas_comprim_ids_root_a.each_with_index {|mr, idx|
    #  abrev = @mrcas_timings[mr].abrev
    #  time_min = @mrcas_timings[mr].time_min
    #  time_max = @mrcas_timings[mr].time_max
    #  puts "idx: #{idx}, nd: #{mr}, abrev: #{abrev}, time_min: #{time_min}, time_max: #{time_max} "
    #}

    #puts
    #for BEAST
    # @mrcas_comprim_ids_noroot_a.each_with_index {|mr, idx|
    #  abrev = @mrcas_timings[mr].abrev
    #  time_med = @mrcas_timings[mr].time_med
    #  stdev = @mrcas_timings[mr].stdev
    #  puts "idx: #{idx}, nd: #{mr}, abrev: #{abrev}, time_med: #{time_med}, stdev: #{stdev} "
    #}

    
    
  end


  def calc_time_min(mrca_id_arr)

    sql_ids = mrca_id_arr.reduce("("){|memo, obj| memo + "#{obj},"}.chop.concat(")")
    sql=<<-EOF
select mr.time_min
from mrcas mr
where mr.id in #{sql_ids}
    EOF
    #puts "sql: #{sql}"

    mrcas = Mrca.find_by_sql(sql)

    mrcas.collect{ |e| e.time_min.to_f }.min


  end

  def calc_time_max(mrca_id_arr)

    sql_ids = mrca_id_arr.reduce("("){|memo, obj| memo + "#{obj},"}.chop.concat(")")
    sql=<<-EOF
select mr.time_max
from mrcas mr
where mr.id in #{sql_ids}
    EOF
    #puts "sql: #{sql}"

    mrcas = Mrca.find_by_sql(sql)

    mrcas.collect{ |e| e.time_max.to_f }.max


  end

  def calc_time_med(mrca_id_arr)

    sql_ids = mrca_id_arr.reduce("("){|memo, obj| memo + "#{obj},"}.chop.concat(")")
    sql=<<-EOF
select mr.time_med
from mrcas mr
where mr.id in #{sql_ids}
    EOF
    #puts "sql: #{sql}"

    mrcas = Mrca.find_by_sql(sql)

    vals = mrcas.collect{ |e| e.time_med.to_f }
    
    avg = vals.sum.to_f / vals.size

  end

  def calc_stdev(mrca_id_arr)

    sql_ids = mrca_id_arr.reduce("("){|memo, obj| memo + "#{obj},"}.chop.concat(")")
    sql=<<-EOF
select ms.STDEV
from MRCA_STDEVS ms
where ms.MRCA_ID in #{sql_ids}
    EOF
    #puts "sql: #{sql}"

    mrca_stdevs = MrcaStdev.find_by_sql(sql)

    vals = mrca_stdevs.collect{ |e| e.stdev.to_f * e.stdev.to_f }

    stdev = vals.sum.to_f/vals.size
    stdev = Math.sqrt(stdev)
    

  end

  
  #load timings
  #reorders active ids, newer first //older first
  #
  def load_mrcas_timings

    @mrcas_timings = {}

    #sql active_ids
    sql_active_ids = @mrcas_active_ids.reduce("("){|memo, obj| memo + "#{obj},"}.chop.concat(")")

    #reorder @mrcas_active_ids by age
    @mrcas_active_ids = []
    sql=<<-EOF
           select m.id,
                  m.abrev,
                  m.time_min,
                  m.time_max,
                  m.time_med,
                  m.stdev
           from mrcas m
           where m.mrca_criter_id = 0 and
                 m.ID in #{sql_active_ids}
           order by m.time_med asc
    EOF
    puts "sql: #{sql}"
   

    #
    #      order by m.time_max desc
      
    mrcas = Mrca.find_by_sql(sql)
      
    mrcas.each {|mr|

      puts "mr: #{mr.inspect}"
      puts "mr.id: #{mr.id}"
      #reorder same as sql
      @mrcas_active_ids << mr.id
      @mrcas_timings[mr.id] = OpenStruct.new(:abrev => mr.abrev,
        :time_min => mr.time_min,
        :time_max => mr.time_max,
        :time_med => mr.time_med,
        :stdev => mr.stdev)
       
      
    }
    puts "@mrcas_active_ids: #{@mrcas_active_ids}"
    puts "@mrcas_timings: #{@mrcas_timings}"
          


    #mrca_ids = mrcas.collect{|m| m.id}

    #puts mrcas.inspect
    #puts "length: #{mrcas.length}"
    #mrca_activ = Array.new(mrcas.length,false)
    #puts mrca_activ.inspect

    #puts "mrcas.length-1: #{(mrcas.length-1)}"
    #sleep 10

  end


  def prepare_all_input_trees(win_status = :result)
    iterate_over_exec_elem(self.prev_fen_stage,win_status){ |i|
      #debugging
      #172 = secE, the smallest gene, without transfers
      #132 = thrC, the second smallest gene, with transfers
      #152 = oppA, problem in window 10/12-275-313 with all gaps
      #next if @gene.name != "thrC"


      puts "active exec elem: #{i}"
      prepare_input_trees
    }

  end

  def prepare_all_input_files
    
    puts "in prepare_all_input_files.."
    iterate_over_exec_elem { |i|
      #debugging
      #172 = secE, the smallest gene, without transfers
      #132 = thrC, the second smallest gene, with transfers
      #152 = oppA, problem in window 10/12-275-313 with all gaps
      #next if @gene.name != "purB"

      puts "active exec elem: #{i}"

      #recreate = true
      #create_work_folder(true)
      
      #recreate = false
      create_work_folder(false)

      #order by m.time_max asc  /time_med
      filter_mrcas

      prepare_input_files

      

    }
    
  end

  #parse results annotations
  def parse_all_output_files

    iterate_over_exec_elem { |i|
      #debugging
      #next if @gene.name != 'fabG'
      #next if @win_size != 10
      #next if @fen_no != "7"
      #next if @gene.name != "thrC"


      puts "active exec elem: #{i}"

      puts "timed_tr_annot_f(:res): #{timed_tr_annot_f(:res)}"
      #do the work for existing files
      next if not File.exists? timed_tr_annot_f(:res)

      parse_output_files
    }

  end

  def create_hgt_unrooted_dir
    puts "hgt_unrooted_dir: #{hgt_unrooted_dir}"

    sys "rm -fr #{hgt_unrooted_dir}"
    #sleep 20
    Dir.mkdir(hgt_unrooted_dir, "755".to_i(8))
    Dir.chdir hgt_unrooted_dir

  end

  def prepare_root_part
    puts "in prepare_rooted_tree..."
    #sys "ls > ls.out"
   
    sys "#{hgt34_f} -inputfile=#{hgt_inpfile_f} -viewtree=yes > gene_root.log"

    puts "hgt_root_part_f #{hgt_root_part_f}"
    ["errorFile.txt","geneRoot.txt","input_.txt","results2.txt", "results.txt","speciesRootLeaves.txt","speciesRoot.txt"].each { |tmp|
    
      sys "rm -fr ./#{tmp}"
    }

  end



  #if transfers exist in window
  #if File.exists?(hgt_results_f)
  #needs hgt_unrooted_dir
  def prepare_input_tree

    #extract gene tree and make a local file with it


    #s = File.open(hgt_results_f, 'rb') { |f| f.read }
    tr_str = File.open(phylo_prog_best_tree_f, 'rb') { |f| f.read }

    puts "phylo_prog_best_tree_f: #{phylo_prog_best_tree_f}"
    puts "tr_str: #{tr_str}"

    #res =  /Gene\sTree\s\:\n(.+)\n+=+/.match(s)
    #puts res[1]

    #tree_str = res[1]
    #tree_str = tree_str.gsub("\n", "")
    #write tree file to disk
    File.open(hgt_tr_unrooted_f, "w+") do |f|
      f.puts tr_str
    end


  end


  def root_input_tree

    #input
    #inputTreeF = "/root/devel/proc_hom/files/hgt-com-110/hgt-com-raxml/secE/test/gene_tree.nwk"
    s = File.open(hgt_tr_unrooted_f, 'rb') { |f| f.read }

    #puts "s: #{s}"

    tr1 = Bio::Newick.new(s).tree
    #puts "tr1: #{tr1.inspect}"

    #geneRootLeavesF = "/root/devel/proc_hom/files/hgt-com-110/hgt-com-raxml/secE/test/root_part.txt"
    grl = File.open(hgt_root_part_f, 'rb') { |f| f.read }

    #puts "grl: #{grl}"
    grl_arr = grl.split("<>")
    grl_arr.collect! {|gr| gr.gsub("\n", "").chomp.rstrip!}
    grl_arr.collect! {|gr| gr.split(" ").sort}

    puts "--------------------->"
    #puts "grl_arr: #{grl_arr.inspect}"

    #calculations
    #leftS = "45656641,110681151,294675842,209964024,190891341,86357291,222085662,27380528,39936338,162448674,197117310,340785583,300309441,152980358,339327541,94312271,119899719,320449271,225874473";
    #rightS = "189218810,347535704,150025254,120436721,110640210,21672990,238903037,16131811,170083441,291285395,218692262,260870692,260846781,218702611,218707599,218697688,218561047,218556535,215489313,260858090,254795979,254163922,117626245,91212814,26250750,291615762,62182601,172035144,217076741,302036652,15607136";

    left_names = grl_arr[0].split(",").sort.flatten
    puts "left_names: #{left_names.inspect}"
    right_names = grl_arr[1].split(",").sort.flatten
    puts "right_names: #{right_names.inspect}"

    #puts "left_names: #{left_names.inspect}"
    #puts "grl_arr[0]: #{grl_arr[0].inspect}"

    #puts "left_names==grl_arr[0]: #{left_names==grl_arr[0]}"
    #puts "right_names==grl_arr[1]: #{right_names==grl_arr[1]}"
    #puts "diff: #{(right_names - grl_arr[1])}"


    #root to first of left
    puts "left_names.first: #{left_names.first}"
    n1 = tr1.get_node_by_name(left_names.first);

    
    #create new node for root
    a1 = Bio::Tree::Node.new("anchor_a1")
    tr1.add_node(a1)
    tr1.add_edge(n1,a1,1)
    tr1.root = a1


    right_mrca = tr1.get_node_by_name(right_names.first);
    #find mrca od left
    right_names.each {|rn|
      #puts "right_mrca: #{right_mrca.inspect}"
      ntemp = tr1.get_node_by_name(rn);
      right_mrca = tr1.lowest_common_ancestor(right_mrca, ntemp)
    }
    puts "right_mrca: #{right_mrca.name}"

    #right_mrca.name = "right_mrca " + right_mrca.name
    right_mrca_edge = tr1.get_edge(right_mrca,tr1.parent(right_mrca))
    puts "right_mrca_edge: #{right_mrca_edge.to_s}"

    tr1.root = n1
    tr1.remove_edge(n1,a1)
    tr1.remove_node a1


  
     
    #root right

    #root to first of right
    n2 = tr1.get_node_by_name(right_names.first);
    
    #create new node for root
    a2 = Bio::Tree::Node.new("anchor_a2")
    tr1.add_node(a2)
    tr1.add_edge(n2,a2,1)
    tr1.root = a2

   

    left_mrca = tr1.get_node_by_name(left_names.first);
    #find mrca od left
    left_names.each {|ln|
      ntemp = tr1.get_node_by_name(ln);
      left_mrca = tr1.lowest_common_ancestor(left_mrca, ntemp)
    }
    puts "left_mrca: #{left_mrca.name}"
    #left_mrca.name = "left_mrca" + left_mrca.name
    #
    left_mrca_edge = tr1.get_edge(left_mrca,tr1.parent(left_mrca))
    puts "left_mrca_edge: #{left_mrca_edge.to_s}"


    tr1.root = n2
    tr1.remove_edge(n2,a2)
    tr1.remove_node a2

    raise "Root branch should equal !" if left_mrca_edge.distance != right_mrca_edge.distance
    root_edge_dist = left_mrca_edge.distance
    #set epsilon
    root_edge_dist = [root_edge_dist,0.002].max

    puts "root_edge_dist: #{root_edge_dist}"
    #right_mrca = tr1.get_node_by_name(right_names.first);
    #find mrca od left
    #right_names.each {|rn|
    #  puts "right_mrca: #{right_mrca.inspect}"
    #  ntemp = tr1.get_node_by_name(rn);
    #  right_mrca = tr1.lowest_common_ancestor(right_mrca, ntemp)
    #}
    #puts "right_mrca: #{right_mrca.name}"

    #right_mrca.name = "right_mrca"

    #insert a new root
   
    new_root = Bio::Tree::Node.new 

    tr1.insert_node(left_mrca,right_mrca,new_root)
    tr1.root = new_root

    #resize branches as original branch/2
    lroot_edge = tr1.get_edge(left_mrca,new_root)
    lroot_edge.distance=root_edge_dist/2
    rroot_edge = tr1.get_edge(right_mrca,new_root)
    rroot_edge.distance=root_edge_dist/2

    puts "lroot_edge: #{lroot_edge.to_s}"
    puts "rroot_edge: #{rroot_edge.inspect}"


    #output
    #outputTreeF = "/root/devel/proc_hom/files/hgt-com-110/hgt-com-raxml/secE/test/gene_tst2.nwk";
    File.open(hgt_tr_rooted_f, "w+") do |f|
      f.puts tr1.output :newick
    end

  end

  

  def prepare_root_file

    puts "timed_tr_rooted_f(:work): #{timed_tr_rooted_f(:work)}"

    tree_str = File.open(hgt_tr_rooted_f, 'rb') { |f| f.read }

    #take out spaces
    #treepl blocks on them
    tree_str.gsub!(/\s/,'')
    #puts "@timed_tr_rooted_scaled_f: #{@timed_tr_rooted_scaled_f}"

    #write tree file to disk
    File.open(timed_tr_rooted_f(:work), "w") do |f|
      f.puts tree_str
    end

    #FileUtils.cp hgt_tr_rooted_f, timed_tr_rooted_f(:work)
    

  end


  def prepare_input_trees
    puts "in prepare_input_trees..."

    create_hgt_unrooted_dir

    prepare_root_part if @stage == "hgt-com"

    prepare_input_tree
    #
    root_input_tree

  end


  def filter_mrcas
    load_mrcas
    load_trsfs
    #
    verify_mrcas

    #order by m.time_max asc /time_med
    load_mrcas_timings

    #keep first or keep last and expand constraint
    comprim_mrcas

    #sleep 2


  end

  def prepare_input_files

    puts "in prepare_input_files..."

    prepare_root_file

    exp_mrcas_yaml if @timing_prog == :treepl
    #exp_treepl_cfg if @timing_prog == :treepl

    #exp_r8s_cfg if @timing_prog == :treepl

    prepare_exec_files if @timing_prog == :beast

  end




  def parse_output_files

    puts ""
    
    #only for beast parse annotations
    if @timing_prog == :beast
      [:med,:hpd5,:hpd95].each {|stat|
        #generate timed trees in nexus format
        parse_tree_annot(stat)
        
        #convert to newick
        frm_convert(timed_tr_dated_f(:res, stat, :nex), timed_tr_dated_f(:res, stat, :nwk), :nex, :nwk)
        #make root accessible to PAL
        remove_colons_nwk(timed_tr_dated_f(:res, stat, :nwk))

      }
      #original TreeAnnotator
      #remove annotations
      sys "cat #{timed_tr_annot_f(:res)} | perl -ne \"s/\\[.+?\\]//g; print;\" > #{timed_tr_dated_f(:res, :orig, :nex)}"
      #convert nexus to newick
      #sys "java -jar ~/local/phyutility/phyutility.jar -vert -in dated_tree.nex -out dated_tree.nwk"
      frm_convert(timed_tr_dated_f(:res, :orig, :nex), timed_tr_dated_f(:res, :orig, :nwk), :nex, :nwk)


    end
    

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

  #file is without extension
  #frm = :nex, :nwk
  def frm_convert(from_file, to_file, from_frm, to_frm)
    case [from_frm, to_frm]
    when [:nex,:nwk]
      sys "java -jar ~/local/phyutility/phyutility.jar -vert -in #{from_file} -out #{to_file}"
    else
      raise "Unimplemented conversion !"
    end


  end

  def remove_colons_nwk(file)
    puts "timed_tr_annot_f(:res): #{timed_tr_annot_f(:res)}"

    #read file
    s = File.open(file, 'rb') { |f| f.read }
    s = s.chomp

    rx = /\((.*)\);/
    #puts paranthesis around tree for figtree
    tree_str =  s.gsub(rx) { "#{$1};"}
    #no anymore for java PAL parsing
    #tree_str =  s.gsub(rx) { "tree TREE1 = [&R] #{parse_nexus_tree($1, stat)};\nEnd; "}

    puts "tree_str: #{tree_str}"

    #write corrected string on same file
    File.open( file, "w") { |f| f.puts tree_str }


  end
  
  #beast goes with absolute values
  #treepl with relative, aditive values
  #stat :orig is beast with additive(relative)
  def get_java_mrca_age(tree, mrca, stat)

    puts "tree: #{tree}"
    puts "mrca: #{mrca}"

    pt = JavaPalTiming.new
    pt.load_rooted_tree(tree)

    res = 0.0
    case @timing_prog
    when :treepl
      res = pt.get_relative_age_nd(mrca)
    when :beast
      res = pt.get_absolute_age_nd(mrca) if stat != :orig
      res = pt.get_relative_age_nd(mrca) if stat == :orig
    end

    puts "res: #{res}"
    return res
  end

  #return taxon array of active @gene.id mrca_id
  def mrca_ncbi_seqs(mrca_id)
    #puts "mrca string assemble..."

    res = []


    sql = "select gbs.NCBI_SEQ_ID
             from gene_blo_seqs gbs
              join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
              join TAXON_GROUPS tg on tg.TAXON_ID = ns.TAXON_ID
             where gene_id = #{@gene.id} and
                   tg.PROK_GROUP_ID in (select mpg.PROK_GROUP_ID
                                        from mrcas m
                                         join MRCA_PROK_GROUPS mpg on mpg.MRCA_ID = m.id
                                        where id = #{mrca_id}
                                        )"
    ncbi_seqs = GeneBloSeq.find_by_sql(sql)
    
    res = ncbi_seqs.collect{|seq| seq.ncbi_seq_id} || [] 

    return res

  end
  


  def exp_age_transfers_csv


    [:treepl,:beast].each { |tm|
      self.timing_prog = tm

      [:med,:hpd5,:hpd95, :orig].each {|stat|
        next if tm == :treepl and [:hpd5,:hpd95,:orig].include? stat

        csvf = File.new(tm_csv_f(:abs,stat,tm), "w")
        csvf.puts "#{stat.to_s}_wg_per_wg"
        wg_per_wg.each { |el|

          val = @tm_frm % el.md_wg_per_wg if stat == :med
          val = @tm_frm % el.md_hpd5_per_wg if stat == :hpd5
          val = @tm_frm % el.md_hpd95_per_wg if stat == :hpd95
          val = @tm_frm % el.md_orig_per_wg if stat == :orig

          csvf.puts "#{val}"
        }
        csvf.close

      }



    }


  end

  def exp_age_trsf_gr_csv
    puts "in exp_age_trsf_gr_csv"

      
    histogram_xvals = []
    histogram_yvals = {}
    

    #find maximum value for both :beast and :treepl
    val_max = 0.0
    [:treepl,:beast].each { |tm|
      self.timing_prog = tm
      #only :med values
      [:med].each {|stat|
        vals_arr = wg_per_wg.collect{|el|
          (@tm_frm % el.md_wg_per_wg).to_f if stat == :med
        }
        puts "tm: #{tm}, vals_arr.max: #{vals_arr.max}"
        val_max = ([val_max,vals_arr.max].max) 
      }
    }

    puts "val_max: #{val_max}"
    #
    [:treepl,:beast].each { |tm|
      self.timing_prog = tm


      #only :med values
      [:med].each {|stat|

        vals_arr = wg_per_wg.collect{|el|
          (@tm_frm % el.md_wg_per_wg).to_f if stat == :med

        }

        puts "vals_arr: #{vals_arr.inspect}"

        #connect to Rserve
        c=Rserve::Connection.new

        #assign name on server
        #for later manual reuse from statet
        vals_name = "#{stage.to_s}_#{tm.to_s}"
        c.assign(vals_name, vals_arr)

        puts "wg_per_wg_max: #{vals_arr.max}"
        val_max = (vals_arr.max) + + self.hg_step

        #calculate histograms
        str=<<-EOF
        #go to project
        setwd("/root/devel/proc_hom/r_lang")
        #save for reuse
        save(#{vals_name},file="#{vals_name}.RData")
        #breaks
        br = seq(0, #{val_max}, by=#{self.hg_step})
        #br = c(1,2,4,8,16,32,64,128,256,512,1024,2048,4096)
        hst = hist(#{vals_name}, br,plot=FALSE)
        hst_rel_freqs <- hst$counts/sum(hst$counts)
        #hst_rel_freqs <- hst$counts
        hst_mids <-hst$mids
        EOF

        print str
        #execute
        c.void_eval str
        #recuperate results
        #rewrite xvals, should be same for all timing methods
        histogram_xvals = c.eval("hst_mids").as_integers
        #y values should differ
        histogram_yvals[tm] = c.eval("hst_rel_freqs").as_floats




        #next if tm == :treepl and [:hpd5,:hpd95,:orig].include? stat



      }



    }

    #one single file for all
    csvf = File.new(tm_csv_f(:abs,:med), "w")
    #headers
    row = "mid_x,"
    [:treepl,:beast].each { |tm|
      row += "#{tm.to_s}_rfreq,"
    }
    row.chomp! ","
    csvf.puts row

    #values
    (0..histogram_xvals.length-1).each {|idx|
      row = ""
      row +=  @tm_frm % histogram_xvals[idx]
      row += ","
      [:treepl,:beast].each { |tm|
        row +=  @tm_freq_frm % histogram_yvals[tm][idx]
        row += ","

      }
      row.chomp! ","
      csvf.puts row
    }

    csvf.close

    #x = c.eval("R.version.string");
    #puts x.as_string
    #x= c.eval("getwd()")
    #puts x.as_string
  end

  def exp_age_transfers_hg

     ["png","emf","svg"].each { |frm|
    
      Dir.chdir (tm_base_d + "work")

      #gnuplot specific file
      gp_f = File.new("#{tm_hg_name}.gp", "w")

      #gnuplot template erb file
      hg_text = File.read("../erb/hg.#{frm}.gp.erb")
    
           
     #write gnuplot file from erb template
    b= binding

    hg_erb = ERB.new(hg_text)

    #uses @hm_base_name
    gp_f.puts hg_erb.result(b)

    gp_f.close

   
      #compile
      cmd = "gnuplot #{tm_hg_name}.gp"
      puts cmd; `#{cmd}`
      #sleep 5
      
      #convert
      #cmd = "convert -density 220 #{@hm_base_name}.pdf -antialias #{@hm_base_name}.png"
      #puts cmd; `#{cmd}`
      sys "mv #{tm_hg_name}.gp ../#{frm}/"
      sys "mv #{tm_hg_name}.#{frm} ../#{frm}/"
    
     }
    #cleanup
    #['gp','gp~'].each {|ext|
    #  cmd = "rm -fr #{@tm_kn_name}.#{ext}"
    #  puts cmd; `#{cmd}`

    #}

  end
  
  def exp_age_transfers_qq
["emf"].each { |frm|
    
      Dir.chdir (tm_base_d + "work")

      #gnuplot specific file
      qq_f = File.new("#{tm_qq_name}.R", "w")

      #gnuplot template erb file
      qq_text = File.read("../erb/qq.#{frm}.R.erb")
    
           
     #write gnuplot file from erb template
    b= binding

    qq_erb = ERB.new(qq_text)

    #uses @hm_base_name
    qq_f.puts qq_erb.result(b)

    qq_f.close

   
      #compile
      #cmd = "R --no-save --slave < #{tm_qq_name}.R"
      cmd = "R --no-save < #{tm_qq_name}.R"
      puts cmd; `#{cmd}`
      #sleep 5
      
      #convert
      #cmd = "convert -density 220 #{@hm_base_name}.pdf -antialias #{@hm_base_name}.png"
      #puts cmd; `#{cmd}`
      sys "mv #{tm_qq_name}.R ../#{frm}/"
      sys "mv #{tm_qq_name}.#{frm} ../#{frm}/"
    
     }
    #cleanup
    #['gp','gp~'].each {|ext|
    #  cmd = "rm -fr #{@tm_kn_name}.#{ext}"
    #  puts cmd; `#{cmd}`

    #}
 
  end

  def exp_age_transfers_bp
    
    ["png","emf","svg"].each { |frm|
    
      Dir.chdir (tm_base_d + "work")

      #gnuplot specific file
      gp_f = File.new("#{tm_bp_name}.gp", "w")

      #gnuplot template erb file
      bp_text = File.read("../erb/bp.#{frm}.gp.erb")



      #write gnuplot file from erb template
      b= binding

      gp_erb = ERB.new(bp_text)

      #uses @hm_base_name
      gp_f.puts gp_erb.result(b)

      gp_f.close

      #compile
      cmd = "gnuplot #{tm_bp_name}.gp"
      puts cmd; `#{cmd}`
      #convert
      #cmd = "convert -density 220 #{@hm_base_name}.pdf -antialias #{@hm_base_name}.png"
      #puts cmd; `#{cmd}`
      sys "mv #{tm_bp_name}.gp ../#{frm}/"
      sys "mv #{tm_bp_name}.#{frm} ../#{frm}/"
    
 
    }


    #cleanup
    #['gp','gp~'].each {|ext|
    #  cmd = "rm -fr #{@tm_bp_name}.#{ext}"
    #  puts cmd; `#{cmd}`

    #}
  end

  def exp_age_transfers_kn

  ["png","emf","svg"].each { |frm|
    
    Dir.chdir (tm_base_d + "work")
      
    #gnuplot specific file
    gp_f = File.new("#{tm_kn_name}.gp", "w")

    #gnuplot template erb file
    kn_text = File.read("../erb/kn.#{frm}.gp.erb")
      
   
    #write gnuplot file from erb template
    b= binding

    gp_erb = ERB.new(kn_text)

    #uses @hm_base_name
    gp_f.puts gp_erb.result(b)

    gp_f.close

    #compile
      cmd = "gnuplot #{tm_kn_name}.gp"
      puts cmd; `#{cmd}`
      #convert
      #cmd = "convert -density 220 #{@hm_base_name}.pdf -antialias #{@hm_base_name}.png"
      #puts cmd; `#{cmd}`
      sys "mv #{tm_kn_name}.gp ../#{frm}/"
      sys "mv #{tm_kn_name}.#{frm} ../#{frm}/"
      
  }

    #cleanup
    #['gp','gp~'].each {|ext|
    #  cmd = "rm -fr #{@tm_kn_name}.#{ext}"
    #  puts cmd; `#{cmd}`

    #}
  end




  def test_time_estim 
    puts "@arTransferGroup: #{@arTransferGroup.table_name}"
  end


end

