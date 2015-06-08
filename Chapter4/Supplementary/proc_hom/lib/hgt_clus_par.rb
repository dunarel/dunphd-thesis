
require 'rubygems'
require 'pathname'


module HgtClusPar

  def init

    puts "in HgtParClus init"
    #active record object initialization

    super

  end


  def initialize()

    puts "in HgtParClus initialize"
    #initialize included modules



  end

  def scan_hgt_par_fens()

    puts "in scan_hgt_par_fens()..."

    sql=<<-EOF
    truncate table #{HgtParFen.table_name}
    EOF
    puts "#{sql}"
    @conn.execute sql
    #sleep 5

    @conn.execute <<-EOF
    truncate table #{HgtParFenStat.table_name}
    EOF

    @genes.each { |gn|
      @gene = gn
      #debugging

      #172 = secE, the smallest gene, without transfers
      #132 = thrC, the second smallest gene, with transfers
      #152 = oppA, problem in window 10/12-275-313 with all gaps
      #next if @gene.name != "thrC"





      #
      puts "gn.name: #{@gene.name}, gn.id: #{@gene.id}"

      [10,25,50].each { |win_size|
        @win_size = win_size

      puts "alix_gene_hgt_par_raxml: #{alix_gene_hgt_par_raxml}"

      alix_gene_hgt_par_raxml.children.each { |pn|
        if pn.directory?
          dir = pn.basename
          elems = dir.to_s.split("-")
          #puts elems.inspect
          @fen_no = elems[0]
          @fen_idx_min = elems[1]
          @fen_idx_max = elems[2]

           #puts "fen_no: #{fen_no}, idx_min: #{idx_min}, idx_max: #{idx_max}"

          treat_window
        end

      }


      #  

          #next
      }
    }

  end

  def gen_hgt_par_fens()
    puts "in gen_hgt_par_fens()..."

    sql=<<-EOF
    truncate table #{HgtParFen.table_name}
    EOF
    puts "#{sql}"
    @conn.execute sql
    #sleep 5

    @genes.each { |gn|
      @gene = gn
      #debugging

      #172 = secE, the smallest gene, without transfers
      #132 = thrC, the second smallest gene, with transfers
      #152 = oppA, problem in window 10/12-275-313 with all gaps
      #next if @gene.name != "thrC"
      
      



      #
      #get whole alignment
      oa = @ud.fastafile_to_original_alignment fasta_align_f(:orig)

      oa_len=oa.alignment_length
      puts "gn.name: #{@gene.name}, gn.id: #{@gene.id}, oa.length: #{oa_len}"

      [10,25,50].each { |win_size|
        @win_size = win_size

        win_wide = (oa_len * win_size / 100).to_i
        @win_wide = win_wide
        win_step = [25,15,10,5,1].select{|v|  v < win_wide}.max
        @win_step = win_step


        fen_no = 0
        idx_min = 0
        idx_max = idx_min + win_wide - 1
        idx_max = [idx_max,oa_len -1].min


        while idx_max <= oa_len -1

          fen_no += 1
          treat_window(fen_no,idx_min,idx_max)

          #next
          idx_min += win_step
          idx_max += win_step
        
        end

        #last window right aligned
        if oa_len -1
          idx_max = oa_len -1
          idx_min = idx_max - win_wide + 1
          fen_no += 1
          treat_window(fen_no,idx_min,idx_max)
        end
        #puts "------------------------"
        #sleep 2
      }
    }

   

   
  end

  def test_fen_over_thr
    
   max_hgt_bs = 0

   if alix_output_fen_hgt_par_raxml.exist?
           alix_output_fen_hgt_par_raxml.open("r") { |hci|
              #parse results file
              hci.each { |ln|
                #puts ln
                if ln =~ /^\|\sIteration\s\#(\d+)\s:/
                  #puts "------------#{$1}---------->#{ln}"
                  @iter_no = $1
                elsif ln =~ /^\|\sHGT\s(\d+)\s\/\s(\d+)\s+Trivial\s+\(bootstrap\svalue\s=\s([\d|\.]+)\%\sinverse\s=\s([\d|\.]+)\%\)/
                  #puts "Trivial: ------#{$1}--#{$3}--#{$4}---------->#{ln}"
                  @hgt_fragm_type = "Trivial"
                  @hgt_no= $1
                  @bs_direct = $3.to_f
                  @bs_inverse = $4.to_f
                elsif ln =~ /^\|\sHGT\s(\d+)\s\/\s(\d+)\s+Regular\s+\(bootstrap\svalue\s=\s([\d|\.]+)\%\sinverse\s=\s([\d|\.]+)\%\)/
                  #puts "Regular: ------#{$1}--#{$3}--#{$4}---------->#{ln}"
                  @hgt_fragm_type = "Regular"
                  @hgt_no= $1
                  @bs_direct = $3.to_f
                  @bs_inverse = $4.to_f


                elsif ln =~ /^\|\sFrom\ssubtree\s\(([\d|\,|\s]+)\)\sto\ssubtree\s\(([\d|\,|\s]+)\)/
                  #puts "------#{$1}---#{$2}----------->#{ln}"
                  @from_subtree=$1
                  @to_subtree = $2
                  #insert row in interior loop
                  #calculate weights
                  @bs_val=@bs_direct+@bs_inverse
                  @weight_direct=@bs_direct/@bs_val
                  @weight_inverse=@bs_inverse/@bs_val

                  


                  #if tranfer is worthy, boostrap value better than threshold
                  #also if hgt_type is included in selected @hgt_type_avail_db
                  if hgt_type_avail_db.include? @hgt_fragm_type
                   #puts "@bs_val: #{@bs_val}"
                   max_hgt_bs = [max_hgt_bs,@bs_val].max

                    #insert direct transfer, with weight_inverse information for inverse weight

                    #@hpf_ins_pstmt.set_int(1,@gene.id)
                    #@hpf_ins_pstmt.set_int(2,@fen_no.to_i)
                    #@hpf_ins_pstmt.set_int(3,@fen_idx_min.to_i)
                    #@hpf_ins_pstmt.set_int(4,@fen_idx_max.to_i)
                    #@hpf_ins_pstmt.set_int(5,@iter_no.to_i)
                    #@hpf_ins_pstmt.set_int(6,@hgt_no.to_i)
                    #@hpf_ins_pstmt.set_string(7,@hgt_fragm_type)
                    #@hpf_ins_pstmt.set_string(8,@from_subtree)
                    #@hpf_ins_pstmt.set_int(9,@from_subtree.split(",").length)
                    #@hpf_ins_pstmt.set_string(10,@to_subtree)
                    #@hpf_ins_pstmt.set_int(11,@to_subtree.split(",").length)
                    #@hpf_ins_pstmt.set_double(12,@bs_val.to_f)
                    #@hpf_ins_pstmt.set_double(13,@bs_direct)
                    #@hpf_ins_pstmt.set_double(14,@bs_inverse)
                    #@hpf_ins_pstmt.set_int(15,win_size)


                    #@hpf_ins_pstmt.add_batch()


                  end

                else
                  #puts ln
                end #end if ln

              } # each ln


            } #each hci

   else
    max_hgt_bs = 0
   end
   #puts "max_hgt_bs: #{max_hgt_bs}, over: #{max_hgt_bs >= self.thres}"

   return (max_hgt_bs >= self.thres)

  end


  #win_status phylo_design
  def treat_window
    
    #puts "gene_id: #{@gene.id}, win_step: #{@win_step}, win_size: #{@win_size}, win_wide: #{@win_wide}, fen_no: #{@fen_no}, @fen_idx_min: #{@fen_idx_min}, @fen_idx_max: #{@fen_idx_max}"

    win_status = case test_fen_over_thr
    when true then "alix_design"
    else 
      "alix_err_th50all"
    end
    

    fen = HgtParFen.new
    fen.gene_id = @gene.id
    fen.win_size = @win_size
    fen.fen_no = @fen_no
    fen.fen_idx_min = @fen_idx_min
    fen.fen_idx_max = @fen_idx_max
    #fen.win_wide = @win_wide
     #fen.win_step = @win_step
    #fen.win_status = "phylo_design"
    fen.save

    #update status based on self.thres
    hpfs = HgtParFenStat.new
    hpfs.hgt_par_fen_id = fen.id
    hpfs.win_status = win_status
    hpfs.save

  end


  #skip windows with no hgt results: output.txt
  def iterate_over_win(fen_stage,win_status,&aproc)

    [10,25,50].each { |win_size|
      @win_size = win_size

      sql=<<-EOF
 select hpf.id,
        hpf.fen_no,
        hpf.fen_idx_min,
        hpf.fen_idx_max
 from hgt_par_fens hpf
  join HGT_PAR_FEN_STATS hpfs on hpfs.HGT_PAR_FEN_ID = hpf.id
 where hpfs.fen_stage_id = #{fen_stage} and
       hpfs.WIN_STATUS = '#{win_status.to_s}' and
       hpf.gene_id = #{@gene.id} and
       hpf.win_size = #{win_size}
 order by hpf.fen_no
      EOF

      #puts "sql: #{sql}"


      fens = HgtParFen.find_by_sql(sql)
      #puts "fens: #{fens.length}"
      #sleep 2

      fens.each {|fen|
        @fen_id = fen.id
        @fen_no = fen.fen_no
        @fen_idx_min = fen.fen_idx_min
        @fen_idx_max = fen.fen_idx_max
        @win_dir = "#{@fen_no}-#{@fen_idx_min}-#{@fen_idx_max}"

        #puts "fen_no: #{@fen_no}, fen_idx_min: #{@fen_idx_min}, fen_idx_max: #{@fen_idx_max}"

        #skip if no results in window
        #next if not File.exists?(hgt_results_f)

        aproc.call "win_size: #{@win_size}, fen_no: #{@fen_no}, fen_idx_min: #{@fen_idx_min}, fen_idx_max: #{@fen_idx_max}"

      }

      
    } #win size

  end

  #takes a pathway
  #returns the medium bootstrap
  def med_nwk_bootstrap(nwk_tree)

    s = nwk_tree.read #File.open(_tr_unrooted_f, 'rb') { |f| f.read }
    puts "s: #{s}"

    tr1 = Bio::Newick.new(s).tree
    #bs_arr = tr1.nodes.select {|nd| nd.bootstrap_string.nil? }
    bs_arr = tr1.nodes.select{|nd| !nd.bootstrap_string.nil? }.compact.collect{|nd| nd.bootstrap_string.to_f}
    #puts "name: #{nd.name}, bootstrap_string: >#{nd.bootstrap_string}<"
    bs_val = bs_arr.sum / bs_arr.length

    puts "bs_arr: #{bs_arr.inspect}, bs_val: #{bs_val}"

    bs_val
    
  end


  def section_create_work_folder(recreate = false)

    #puts "fen_d(:work): #{fen_d(:work)}"


    
    #first time
    #sys "mkdir -p #{fen_d(:work)}"

    #thereafter

    #create folder if non existant

    #puts "fen_d(:work): #{fen_d(:work)}"
    #puts "fen_d(:work).exist?: #{fen_d(:work).exist?}"

    #recreate work folder
    fen_d(:work).rmtree if recreate == true and fen_d(:work).exist?
    #create on first use
    FileUtils.mkdir_p fen_d(:work) unless fen_d(:work).exist?
    fen_d(:work).chmod "755".to_i(8)


    #sys "rm -fr #{fen_d(:work)}" if recreate == true
  
  end

  def merge_fen_stat(fen_stage, win_status)
    #equivalent of merge
    #delete status
    sql=<<-EOF
delete from hgt_par_fen_stats hpfs
where hpfs.id = #{@fen_id} and
      hpfs.fen_stage_id = #{fen_stage} and
      hpfs.win_status = '#{win_status}'
    EOF

    puts "sql: #{sql}"

    #sleep 5
    @conn.execute sql
    #insert status

    sql=<<-EOF
insert into hgt_par_fen_stats hpfs
 (hgt_par_fen_id,fen_stage_id,win_status,created_at,updated_at)
values
 (#{@fen_id},#{fen_stage},'#{win_status}',current_timestamp,current_timestamp)
    EOF

    puts "sql: #{sql}"

    #sleep 5
    @conn.execute sql

  end

  #update selector(for jobs) based on fen_stage and status
  def update_sel_from_status(fen_stage, status)

    @conn.execute <<-EOF
update HGT_PAR_FENS hpf
set hpf.WIN_SEL = '#{status}'
where id in (select hpfs.HGT_PAR_FEN_ID
             from HGT_PAR_FEN_STATS hpfs
             where hpfs.FEN_STAGE_ID = #{fen_stage} and
                   hpfs.WIN_STATUS = '#{status}')
    EOF


  end


  def update_fen_win_section_phylo_result
    status_s = nil
    #@fen_bootstrap_limit = 50.0
    #discard windows with insufficient bootstrap

    #if fen_nwk_re(:res).exist?
    #  bs_val =  med_nwk_bootstrap(fen_nwk_re(:res))
    #  puts "bs_val: #{bs_val}"
    #end

    #if fen_nwk_re(:res).exist? and bs_val >= @fen_bootstrap_limit
    #  status_s = "phylo_result"
    #elsif fen_nwk_re(:res).exist? and bs_val < @fen_bootstrap_limit
    #  status_s = "phylo_err_lowbs"
    #else
    #  status_s = "phylo_err_nocalc"
    #end

    if fen_nwk_re(:res).exist?
      status_s = "phylo_result"
    else
      status_s = "phylo_err_nocalc"
    end

    merge_fen_stat(status_s)
    

  end

  #update current fen_stage window status
  def update_fen_win_section_hgt_result
    status_s = nil

    if fen_hgt_output(:res).exist?
      status_s = "result"
    else
      status_s = "err_nocalc"
    end

    #update current fen_stage
    merge_fen_stat(self.fen_stage,status_s)

  end
  
  def section_prep_inp_files

    puts "in section_prep_inp_files..."

    section_prep_phylo_phy_align if calc_section == :phylo
    section_prep_timing_files if calc_section == :timing
      

  end

  def section_parse_out_files

    puts "in section_parse_out_files..."

    update_fen_win_section_phylo_result if calc_section == :phylo
    update_fen_win_section_hgt_result if calc_section == :hgt
    # for beast & treepl
    parse_output_files if calc_section == :timing
    

  end


  
  def section_prep_all_inp_files(win_status = :result)

    iterate_over_exec_elem(self.prev_fen_stage,win_status){ |i|
      #debugging
      #172 = secE, the smallest gene, without transfers
      #132 = thrC, the second smallest gene, with transfers
      #152 = oppA, problem in window 10/12-275-313 with all gaps
      #next if @gene.name != "dnaK"
      #next if @win_size == 10
      #next if @win_size == 25
      

      puts "active exec elem: #{i}"

      #recreate = true
      section_create_work_folder(true)

      #recreate = false
      #section_create_work_folder(true)

      #order by m.time_max asc  /time_med
      filter_mrcas

      section_prep_inp_files



    }

  end

  #parse results annotations
  def section_parse_all_out_files(win_status = :result)

    iterate_over_exec_elem(self.prev_fen_stage,win_status){ |i|
      #debugging
      #next if @gene.name != 'fabG'
      #next if @win_size != 50
      #next if @fen_no != "7"
      #next if @gene.name != "thrC"


      puts "active exec elem: #{i}"

      #puts "timed_tr_annot_f(:res): #{timed_tr_annot_f(:res)}"
      #do the work for existing files
      #next if not File.exists? timed_tr_annot_f(:res)

      section_parse_out_files
    }

  end


  #load alignment in memory for constraints checking as @win_seq_hsh
  #also write it to file
  def  section_prep_phylo_phy_align

    #get original whole alignment
    #puts "fasta_align_f(:orig): #{fasta_align_f(:orig)}"
    oa = @ud.fastafile_to_original_alignment fasta_align_f(:orig)
    #slice
    @win_seq_hsh = oa.alignment_collect() { |str|
      str[self.fen_idx_min..self.fen_idx_max]
    }
    #save
    #puts "fen_phy_align_f(:work): #{fen_phy_align_f(:work)}"
    @ud.seqshash_to_phylipfile(@win_seq_hsh,fen_phy_align_f(:work))

  end

  def section_prep_timing_files

    puts "in section_prep_timing_files..."

    prepare_root_file

    exp_mrcas_yaml if @timing_prog == :treepl

    prepare_exec_files if @timing_prog == :beast


  end

  #export genes by nb_contins by window
  def section_exp_tasks_yaml(tasks_page_dim, task_start_nb, win_sel)

    #tasks = tasks_already_worked_out

    #contr = ""
    #tasks.each {|tsk|
    #  contr += "(#{tsk[0]},#{tsk[1]},#{tsk[2]}),"
    #}
    #contr.chomp! ","
    #puts contr

    sql=<<-EOF
select hpf.GENE_ID,
       gn.NAME,
       hpf.WIN_SIZE,
       hpf.FEN_NO,
       hpf.FEN_IDX_MIN,
       hpf.FEN_IDX_MAX
from hgt_par_fens hpf
 join genes gn on gn.id = hpf.gene_id
where hpf.win_sel = '#{win_sel}'
    EOF

    #puts "sql: #{sql}"
    #sleep 5
    
    #add limit 20
    tasks = HgtParFen.find_by_sql(sql)

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
      File.open("#{compart_d(:jobs)}/job-tasks-#{job_s}.yaml", "w+") do |f|
        f.puts job_tasks.to_yaml()
      end


    }


  end

  #floc = :exec, :jobs, :work, :res
  def section_rsync_folder(floc)

    case floc
    when :exec, :jobs, :work
      sys "rsync -avzx --del #{compart_d(floc)}/ #{AppConfig.remote_server}:#{remote_compart_d(floc)}/"
      #puts "rsync -avzx --del #{compart_d(floc)}/ #{AppConfig.remote_server}:#{remote_compart_d(floc)}/"
    when :res
      sys "rsync -avzx --del #{AppConfig.remote_server}:#{remote_compart_d(floc)}/ #{compart_d(floc)}/ "
      #puts "rsync -avzx --del #{AppConfig.remote_server}:#{remote_compart_d(floc)}/ #{compart_d(floc)}/ "
    else
      raise "Please review rsync options !"
    end


  end


end


