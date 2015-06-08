
require 'rubygems'
require 'bio' 
require 'msa_tools'
require 'faster_csv'
require 'erb'
require 'matrix'
require 'rgl/adjacency'
require 'rgl/implicit'
require 'rgl/traversal'
require 'rgl/dot'
require 'rgl/connected_components'
require 'rgl/topsort'
require 'rgl/bidirectional'
require 'base_transfer'
require 'time_estim'


require 'java'
#require 'jgrapht-0.8.2.jar'
#require 'commons-lang3-3.1.jar'
require '/root/devel/db_srv/sp_projects/proc-hom-sp/dist/proc-hom-sp.jar'

#JavaRange = org.apache.commons.lang3.Range

#java_import org.jgrapht.UndirectedGraph
#java_import org.jgrapht.graph.DefaultEdge
#java_import org.jgrapht.graph.SimpleGraph
#java_import org.jgrapht.alg.ConnectivityInspector

JavaHgtParConnCompMed = org.uqam.doct.proc.hom.sp.HgtParConnCompMed
JavaHgtParConnCompBest = org.uqam.doct.proc.hom.sp.HgtParConnCompBest
JavaHgtPar = org.uqam.doct.proc.hom.sp.HgtPar


class AssertError < StandardError
end

module HgtPar
  
  
    
  #include BaseTransfer
  #include TimeEstim

  attr_accessor :fragm_thres,
                :epsilon_sim_frag,
                :epsilon_dist_frag


  #the setter is individualized
  #king of constructor of @fname
  #attr_reader :calc_type # :rel / :abs
  #attr_reader :hgt_type # :regular / :all
  
  def init

    puts "in HgtPar init"
     #active record object initialization
     #active record object initialization
    self.arTrsfTaxon = HgtParTrsfTaxon
    self.arTrsfPrkgr = HgtParTrsfPrkgr
    self.arTrsfTiming = HgtParTrsfTiming

    self.arTransferGroup =  HgtParTransferGroup
    self.arGeneGroupCnt = GeneGroupCnt
    self.arGeneGroupsVal = HgtParGeneGroupsVal

    super

  end


  def initialize()

    puts "in HgtPar initialize"
    #initialize included modules
    
 
    
  end

  #hgt_type is global
  #all calculations are interdependent
 #def init_base_transfer(hgt_type, thres, one_dim_op)
 
  # base_transfer_init(hgt_type, thres, one_dim_op,
  #    HgtParTransferGroup, GeneGroupCnt , HgtParGeneGroupsVal )

  #end



   def import_fragms_one_gene()

    [10,25,50].each { |win_size|



      @genes_dir =  "#{AppConfig.hgt_par_dir}/hgt-par-#{@phylo_prog}-#{win_size}"

      #Dir.chdir @gene_dir




      @valid_win_path = "#{@genes_dir}/#{@gene_name}/valid_win.idx"
      #puts "valid_win_path: #{@valid_win_path}"
      #sys "cp #{@valid_win_path} results/#{@gene_dir}/"

      File.open(@valid_win_path,"r") { |vwf|

        #puts "vwf: #{vwf}"
        vwf.each { |win_dir|
          win_dir.chomp!
          #puts win_dir
          win_dir_comp = win_dir.split("-")
          @fen_no = win_dir_comp[0]
          @fen_idx_min = win_dir_comp[1]
          @fen_idx_max = win_dir_comp[2]

          #puts "fen_no: #{@fen_no}, fen_idx_min: #{@fen_idx_min}, fen_idx_max: #{@fen_idx_max}"

          @win_path = "#{@genes_dir}/#{@gene_name}/#{win_dir}"
          #puts "win_dir: #{win_dir}, win_path: #{@win_path}"

          @output_path = "#{@win_path}/output.txt"
          #sys "cat #{@output_path} | wc "


          if File.exists?(@output_path)
            File.open(@output_path,"r") { |hci|
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
                  if @bs_val >= fragm_thres and hgt_type_avail_db.include? @hgt_fragm_type
                    #insert direct transfer, with weight_inverse information for inverse weight

                    @hpf_ins_pstmt.set_int(1,@gene.id)
                    @hpf_ins_pstmt.set_int(2,@fen_no.to_i)
                    @hpf_ins_pstmt.set_int(3,@fen_idx_min.to_i)
                    @hpf_ins_pstmt.set_int(4,@fen_idx_max.to_i)
                    @hpf_ins_pstmt.set_int(5,@iter_no.to_i)
                    @hpf_ins_pstmt.set_int(6,@hgt_no.to_i)
                    @hpf_ins_pstmt.set_string(7,@hgt_fragm_type)
                    @hpf_ins_pstmt.set_string(8,@from_subtree)
                    @hpf_ins_pstmt.set_int(9,@from_subtree.split(",").length)
                    @hpf_ins_pstmt.set_string(10,@to_subtree)
                    @hpf_ins_pstmt.set_int(11,@to_subtree.split(",").length)
                    @hpf_ins_pstmt.set_double(12,@bs_val.to_f)
                    @hpf_ins_pstmt.set_double(13,@bs_direct)
                    @hpf_ins_pstmt.set_double(14,@bs_inverse)
                    @hpf_ins_pstmt.set_int(15,win_size)


                    @hpf_ins_pstmt.add_batch()


=begin
                    frgm = HgtParFragm.new
                    #puts "#{@iter_no},#{@hgt_no},#{@from_subtree},#{@to_subtree},#{@bs_val}"
                    frgm.gene = @gene #Gene.find_by_name(@gene)
                    frgm.fen_no = @fen_no.to_i
                    frgm.fen_idx_min = @fen_idx_min.to_i
                    frgm.fen_idx_max = @fen_idx_max.to_i
                    frgm.iter_no=@iter_no.to_i
                    frgm.hgt_no=@hgt_no.to_i
                    frgm.hgt_type=@hgt_type

                    frgm.from_subtree=@from_subtree
                    #update nb of source gi-s
                    frgm.from_cnt = @from_subtree.split(",").length

                    frgm.to_subtree=@to_subtree
                    frgm.to_cnt = @to_subtree.split(",").length
                    frgm.bs_val=@bs_val.to_f
                    frgm.bs_direct=@bs_direct
                    frgm.bs_inverse=@bs_inverse

                    frgm.save
=end
                  end

                else
                  #puts ln
                end #end if ln

              } # each ln


            } #each hci


          end #end if @output_path



        } #win_dir
      } #vwp

    } #win size

  end


  def import_fragms_one_fen()


      File.open( fen_hgt_output(:res),"r") { |hci|
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
                  if @bs_val >= fragm_thres and hgt_type_avail_db.include? @hgt_fragm_type
                    #insert direct transfer, with weight_inverse information for inverse weight

                    @hpf_ins_pstmt.set_int(1,@gene.id)
                    @hpf_ins_pstmt.set_int(2,@fen_no.to_i)
                    @hpf_ins_pstmt.set_int(3,@fen_idx_min.to_i)
                    @hpf_ins_pstmt.set_int(4,@fen_idx_max.to_i)
                    @hpf_ins_pstmt.set_int(5,@iter_no.to_i)
                    @hpf_ins_pstmt.set_int(6,@hgt_no.to_i)
                    @hpf_ins_pstmt.set_string(7,@hgt_fragm_type)
                    @hpf_ins_pstmt.set_string(8,@from_subtree)
                    @hpf_ins_pstmt.set_int(9,@from_subtree.split(",").length)
                    @hpf_ins_pstmt.set_string(10,@to_subtree)
                    @hpf_ins_pstmt.set_int(11,@to_subtree.split(",").length)
                    @hpf_ins_pstmt.set_double(12,@bs_val.to_f)
                    @hpf_ins_pstmt.set_double(13,@bs_direct)
                    @hpf_ins_pstmt.set_double(14,@bs_inverse)
                    @hpf_ins_pstmt.set_int(15,@win_size)


                    @hpf_ins_pstmt.add_batch()


                  end

                else
                  #puts ln
                end #end if ln

              } # each ln


            } #each hci


   


  end


  #modify fragms, contins
  def import_fragms_by_gene()

    puts "in import_fragms()...."
    HgtParFragm.delete_all
    puts "deleted HgtParFragm"
    

    hpf_ins_sql = \
      "insert into hgt_par_fragms
       (gene_id,
        fen_no,
        fen_idx_min,
        fen_idx_max,
        iter_no,
        hgt_no,
        hgt_type,
        from_subtree,
        from_cnt,
        to_subtree,
        to_cnt,
        bs_val,
        bs_direct,
        bs_inverse,
        win_size)
       values
        (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);"
    
    @hpf_ins_pstmt = @jdbc_conn.prepare_statement(hpf_ins_sql);
    #prepare statements
    @jdbc_conn.set_auto_commit(false)

    cnt = 0
   
    #@genes[62..62].each { |gn|
    @genes.each { |gn|
      #next if gn.name != "secE"
      cnt += 1
      #fl = fl.split

      
      #@gene_name=fl[1]
      @gene = gn
      @gene_name=gn.name

      puts "gene_id: #{@gene.id}, gene_name: #{@gene_name}"
      
      
      #@gene = Gene.find_by_name(@gene_name)
      
      #import one gene
      import_fragms_one_gene()
      @hpf_ins_pstmt.execute_batch()
      @jdbc_conn.commit
      
   }
    
    @jdbc_conn.set_auto_commit(true)
    
    
    

  end

  def import_fragms_by_fens()

    puts "in import_fragms()...."
    HgtParFragm.delete_all
    puts "deleted HgtParFragm"

    hpf_ins_sql = \
      "insert into hgt_par_fragms
       (gene_id,
        fen_no,
        fen_idx_min,
        fen_idx_max,
        iter_no,
        hgt_no,
        hgt_type,
        from_subtree,
        from_cnt,
        to_subtree,
        to_cnt,
        bs_val,
        bs_direct,
        bs_inverse,
        win_size)
       values
        (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?);"

    @hpf_ins_pstmt = @jdbc_conn.prepare_statement(hpf_ins_sql);
    #prepare statements
    @jdbc_conn.set_auto_commit(false)

    cnt = 0


    iterate_over_exec_elem(self.fen_stage,:result){ |i|
      #debugging
      #next if @gene.name != 'fabG'
      #next if @win_size != 50
      #next if @fen_no != "7"
      #next if @gene.name != "thrC"


      puts "active exec elem: #{i}"

      #puts "timed_tr_annot_f(:res): #{timed_tr_annot_f(:res)}"
      #do the work for existing files
      #next if not File.exists? timed_tr_annot_f(:res)

      import_fragms_one_fen()
      @hpf_ins_pstmt.execute_batch()
      @jdbc_conn.commit
    }

    @jdbc_conn.set_auto_commit(true)
    

  end



  def contin_fragms()
    
    HgtParContin.delete_all
    puts "deleted HgtParContin"
   

    cnt = 0
   
    @genes.each { |gn|
      cnt += 1

      @gene = gn
      @gene_name=gn.name

      puts "gene_id: #{@gene.id}, gene_name: #{@gene_name}"
      
      #go with efficient stored procedure
      #sp_calculate_graph_java()
      
      #construct_graph_java()

      #hp = JavaHgtParConnComp.new @jdbc_conn, @gene.id, @thres
      #JavaHgtParConnComp.initJavacl
      #hp.load_ncbi_seqs
      #hp.load_fragments
      #hp.constructGraphJava @epsilon_sim_frag, @epsilon_dist_frag
      
      JavaHgtPar.construct_graph_java(@jdbc_conn, @gene.id, @epsilon_sim_frag, @epsilon_dist_frag);
      
      
      
    }
    
    
    
    
  end

  def  delete_useless_fragms()

   puts "in delete_useless_fragms()..."

   sql=<<-END
    delete from HGT_PAR_FRAGMS hpf4
    where hpf4.gene_id = #{@gene.id} and
          hpf4.id not in
     (
     select hpf3.id
     from HGT_PAR_FRAGMS hpf3
     where  hpf3.gene_id = #{@gene.id} and
           (hpf3.HGT_PAR_CONTIN_ID, hpf3.ID) in
      (
       select hpf2.HGT_PAR_CONTIN_ID,
              min(hpf2.ID) as min_frag_id
              --max(hpf2.FEN_NO) as max_fen,
              --count(hpf2.ID) as cnt_fen
       from hgt_par_fragms hpf2
       where  hpf2.gene_id = #{@gene.id} and
             (hpf2.HGT_PAR_CONTIN_ID,hpf2.BS_VAL) in
        (select hpc.id,
                max(hpf.BS_VAL) as max_bs
         from HGT_PAR_CONTINS hpc
          join HGT_PAR_FRAGMS hpf on hpf.HGT_PAR_CONTIN_ID = hpc.ID
         where hpf.gene_id = #{@gene.id} and 
               hpf.BS_VAL >= #{@thres}
         group by hpc.ID
        )
       group by hpf2.HGT_PAR_CONTIN_ID
      )
     )
    END
    
    @conn.execute sql


  end

  def contin_realign_fragms_javacl_med()

    HgtParContin.delete_all
    puts "deleted HgtParContin"

    HgtParTransfer.delete_all
    puts "deleted HgtParTansfer"
    sleep(5)


    cnt = 0

   #@genes[80..80].each { |gn|
   @genes.each { |gn|
      cnt += 1

      @gene = gn
      @gene_name=gn.name

      puts "gene_id: #{@gene.id}, gene_name: #{@gene_name}"

      #go with efficient stored procedure
      #sp_calculate_graph_java()

      #construct_graph_java()




      hp = JavaHgtParConnCompMed.new @jdbc_conn, @gene.id, @thres
      JavaHgtParConnCompMed.init_javacl();

      hp.update_genes_ncbi_seqs_arr()
      hp.load_ncbi_seqs_from_genes_arr()
      #fragments need ncbiSeqs
      hp.load_fragments()
      hp.construct_graph_open_cl(0.75, SqlInfin)
      hp.connect_compon_open_cl()
      hp.insertContinsUpdateFragms()
      hp.update_contins()
      #should delete useless fragms
      #do not generate useless coresponding transfers
      #delete_useless_fragms()

      hp.insertTrsfs()

      hp.cleanupJavacl
      hp = nil
      JavaHgtParConnCompMed.staticCleanupJavacl
      
      
      


    }




  end

def contin_realign_fragms_javacl_max()

    HgtParContin.delete_all
    puts "deleted HgtParContin"

    HgtParTransfer.delete_all
    puts "deleted HgtParTansfer"
    sleep(5)


    cnt = 0

   #@genes[80..80].each { |gn|
   @genes.each { |gn|
      cnt += 1

      @gene = gn
      @gene_name=gn.name
      
    #
    next if @gene.name == "rbcL"

      puts "gene_id: #{@gene.id}, gene_name: #{@gene_name}"

      #go with efficient stored procedure
      #sp_calculate_graph_java()

      #construct_graph_java()




      hp = JavaHgtParConnCompBest.new @jdbc_conn, @gene.id, @thres
      JavaHgtParConnCompBest.init_javacl();

      hp.update_genes_ncbi_seqs_arr()
      hp.load_ncbi_seqs_from_genes_arr()
      #fragments need ncbiSeqs
      hp.load_fragments()
      hp.construct_graph_open_cl(0.75, SqlInfin)
      hp.connect_compon_open_cl()
      hp.insertContinsUpdateFragms()
      hp.update_contins()
      #should delete useless fragms
      #do not generate useless coresponding transfers
      #delete_useless_fragms()

      hp.insertTrsfs()

         
      hp.cleanupJavacl
      hp = nil
      JavaHgtParConnCompBest.staticCleanupJavacl

      #sleep 1




    }




  end


  
  def realign_fragms()
    HgtParTransfer.delete_all
    puts "deleted HgtParTansfer"
    sleep(5)

    cnt = 0    
    @genes.each { |gn|
      cnt += 1

      @gene = gn
      @gene_name=gn.name

      puts "gene_name: #{@gene_name}"
      
      
      realign_fragms_in_contins_transfers()

    }
    
    
    
    
  end
 
 
  def str_lin_arr(from_subtree, to_subtree) 
   
    #lin_arr
    lin_arr = []
    #decompose
    farr = from_subtree.split(",").collect{|x| x.lstrip}
    tarr = to_subtree.split(",").collect{|x| x.lstrip}
    #puts "#{farr.inspect},#{tarr.inspect}"

    tr_nb = (farr.size * tarr.size).to_f

    farr.each {|src|
      tarr.each {|dst|
        lin_arr << [src,dst]
         
      }
    }
       
    return lin_arr
    
  end

  #input first_arr = ["1, 5", "7, 9, 12"]
  #input firs_arr = [from_string, to_string]
  def jaccard_sim_coef( u_from, u_to , v_from, v_to )
    
    first_arr  = str_lin_arr(u_from, u_to)
    second_arr = str_lin_arr(v_from, v_to)
    
    #puts first_arr.inspect
    #puts second_arr.inspect
      
    inter = first_arr & second_arr
    union = first_arr | second_arr
     
    jacc = inter.length.to_f / union.length.to_f
     
        
    #puts "inter: #{inter.inspect}, #{inter.length}, #{union.length}, #{jacc}"
     
    return jacc
      
  end
  
  
  # a [i..f]
  # b [i..f]
  def is_fragm_conn(ai, af, bi, bf)

    #using java range objects from appache commmons
    rng_a = JavaRange.between(ai.to_java,af.to_java)
    rng_b = JavaRange.between(bi.to_java,bf.to_java)

    connect_frag = false
   
    if rng_a.is_overlapped_by(rng_b)
      #connect overlapping fragments
      connect_frag = true
      #puts "rng_a: #{rng_a}, ----- intersection ---- #{rng_a.intersection_with(rng_b)} ----  rng_b: #{rng_b} "
    elsif rng_a.is_before_range(rng_b)
      #connect non-overlaping near fragments
      dist = rng_b.get_minimum() - rng_a.get_maximum()
      connect_frag = true if dist <= @epsilon_dist_frag
      #puts "rng_a: #{rng_a}, ----before ---dist: #{dist} ----  rng_b: #{rng_b} "

    elsif rng_a.is_after_range(rng_b)
      #connect non-overlaping near fragments
      dist = rng_a.get_minimum() - rng_b.get_maximum()
      connect_frag = true if dist <= @epsilon_dist_frag
      #puts "rng_a: #{rng_a}, ----after ---dist: #{dist} ----  rng_b: #{rng_b} "

    end

    #puts "connected: #{connect_frag}"
    return connect_frag


  end



   
  def construct_graph_java
    puts "Entering construct_graph_java..."   
    puts "Selecting @gene.hgt_par_fragms"
    #frgms = @gene.hgt_par_fragms    #HgtParFragm.find_by_gene_id
    
    #img_tot_cnt
    frgms_arr = @gene.hgt_par_fragms \
      .each_with_object( [ ] ){ |c, arr| arr << {:fen_idx_min => c.fen_idx_min,
        :fen_idx_max => c.fen_idx_max,
        :from_subtree => c.from_subtree,
        :to_subtree => c.to_subtree} }
    
    #puts frgms_arr.inspect
    
    #n= (frgms.length - 1)
    n= (frgms_arr.length - 1)
    puts "fragments number: #{n}"
    sleep 5

    #n = 50

    #undirected, no cycles
    gr = SimpleGraph.new(DefaultEdge.new.java_class)


    #add vertices
    (0..n).each { |v|

      gr.add_vertex v
    }

    #enumerate only once each edge
    #asymetric
    (0..n).each { |u|
      puts "u: #{u}" if u % 100 == 0

      ((u+1)..n).each { |v|
        #puts "u: #{u}, v: #{v}"

        #add edges
        #u_from = frgms[u].from_subtree
        u_from = frgms_arr[u][:from_subtree]
        
        
        #u_to   = frgms[u].to_subtree
        u_to   = frgms_arr[u][:to_subtree]

        #v_from = frgms[v].from_subtree
        v_from = frgms_arr[v][:from_subtree]
        #v_to   = frgms[v].to_subtree
        v_to = frgms_arr[v][:to_subtree]
        #
        #calculate Jaccard similarity
        jac_dir =  jaccard_sim_coef(u_from, u_to, v_from, v_to) 
        jac_inv =  jaccard_sim_coef(u_from, u_to, v_to, v_from) 

        #puts "u: #{frgms[u].id}, v: #{frgms[v].id}, src_from: #{u_from}, src_to: #{u_to}, jac: #{jac}"

        #connect similar and proximal components
        #if [jac_dir,jac_inv].max >= @epsilon_sim_frag and 
        #    is_fragm_conn(frgms[u].fen_idx_min, \
        #      frgms[u].fen_idx_max, \
        #      frgms[v].fen_idx_min, \
        #      frgms[v].fen_idx_max)
        
          
        if [jac_dir,jac_inv].max >= @epsilon_sim_frag and 
            is_fragm_conn(frgms_arr[u][:fen_idx_min], \
              frgms_arr[u][:fen_idx_max], \
              frgms_arr[v][:fen_idx_min], \
              frgms_arr[v][:fen_idx_max])
        
            
          gr.add_edge(u, v)

        else
          nil
        end
         
      }
        
    }

    #puts gr.to_string()

    #retrieve connected components <=> contins
    ci = ConnectivityInspector.new(gr)
    cs = ci.connected_sets()
  
    #create contins 
    #HgtParContin.destroy_all
    #
    cs.each { |el|
      #insert new contin 
      contin = HgtParContin.new  
      #need an id
      contin.gene = @gene      
      contin.save    
      #update fragment contin_id
      el.each { |m|
     
        #update contin_id
        #ci = HgtParFragm.find_by_gene_id
        
        @gene.hgt_par_fragms[m].hgt_par_contin_id = contin.id
        @gene.hgt_par_fragms[m].save
        #puts "mini: #{m}, #{frgms[m].fen_idx_min}, #{frgms[m].fen_idx_max}, contin_id: #{frgms[m].hgt_par_contin_id }"
      } #el
    } #cs
  
  end    

  #works on one gene
  def realign_fragms_in_contins_transfers() 

    #test_pair = ["190891355","222085675"] 
    #test_pair = [test_pair, test_pair.reverse]
    #puts "test_pair: #{test_pair.inspect}"
 
    #contins = @gene.hgt_par_contins.where("id = ?",3515).order("id")
    contins = @gene.hgt_par_contins.order("id")
    contins.each { |con|
      #puts "con id: #{con.id}"
    
   
      frgms = con.hgt_par_fragms.order("fen_idx_min ASC, fen_idx_max ASC")

      #first one is reference
      frgms[0].contin_realign_status = "Reference"
      #check for inversions
      (0..frgms.length-2).each { |i|
        u = frgms[i]
        v = frgms[i+1] 

        #jac_dir =  jaccard_sim_coef(u.from_subtree, u.to_subtree, v.from_subtree, v.to_subtree)
        jac_dir =  JavaHgtPar.jaccard_sim_coef(u.from_subtree, u.to_subtree, v.from_subtree, v.to_subtree)
        #jac_inv =  jaccard_sim_coef(u.from_subtree, u.to_subtree, v.to_subtree, v.from_subtree)
        jac_inv =  JavaHgtPar.jaccard_sim_coef(u.from_subtree, u.to_subtree, v.to_subtree, v.from_subtree)

        if jac_inv > jac_dir 
          #swap from and to subfields
          v.from_subtree, v.to_subtree =  v.to_subtree, v.from_subtree
          v.from_cnt, v.to_cnt = v.to_cnt, v.from_cnt
          v.bs_direct, v.bs_inverse = v.bs_inverse, v.bs_direct
          #mention change
          v.contin_realign_status = "Realigned"

        else
          #mention original
          v.contin_realign_status = "Original"
        end
     
     
        #puts "u.fen_idx_min: #{u.fen_idx_min}, jac_dir: #{jac_dir}, jac_inv: #{jac_inv}"
      

      }    

 
      frgms.each { |fr|

        #save changes on fragments of same contin
        fr.save
        #next unless test_pair.include? [fr.from_subtree, fr.to_subtree]

        #puts "#{fr.hgt_par_contin_id}, #{fr.fen_idx_min}, #{fr.fen_idx_max}, #{fr.from_subtree}, #{fr.to_subtree}, #{fr.from_cnt}, #{fr.to_cnt}, #{fr.bs_val}, #{fr.bs_direct}, #{fr.bs_inverse}, #{fr.contin_realign_status}"
        #fr.contin_realign_status = "Original"
        #fr.save

      }

      #calculate contins aggregate values
      con.fen_idx_min = frgms.collect{|e| e.fen_idx_min }.min
      con.fen_idx_max = frgms.collect{|e| e.fen_idx_max }.max
      con.length = con.fen_idx_max - con.fen_idx_min
      #bootstrap average values 
      #useless for maximum
      #bs_direct_a = frgms.collect{|e| e.bs_direct }
      #bs_inverse_a = frgms.collect{|e| e.bs_inverse }
      #average
      #con.bs_direct = bs_direct_a.sum.to_f / bs_direct_a.size.to_f
      #con.bs_inverse = bs_inverse_a.sum.to_f / bs_inverse_a.size.to_f
      #replaced by maximum
      con.bs_direct = frgms.collect{|e| e.bs_direct }.max
      con.bs_inverse = frgms.collect{|e| e.bs_inverse }.max
      #
      con.bs_val = con.bs_direct + con.bs_inverse
      #save contin
      con.save

      #calculate individual transfer components
      transfers_count = frgms.collect{|e| str_lin_arr(e.from_subtree, e.to_subtree)  }.flatten(1).size.to_f
      transfers_h =  frgms.inject({}) { |h,e| h[ e.id ]= str_lin_arr(e.from_subtree, e.to_subtree); h}
      #

      #puts "contin id: #{con.id}, #{con.fen_idx_min}, #{con.fen_idx_max}, #{con.length}, #{con.bs_val}, #{con.bs_direct}, #{con.bs_inverse}"
      #puts "transfers_count: #{transfers_count}"
      #puts "transfers_h: #{transfers_h.inspect}"

      #if contin is worthy
      #insert transfers
      if con.bs_val >= @thres
        #now check direction
        transfers_h.each_pair { |k,v| 
          #k is hgt_par_fragm_id
          #v is array [source,dest]
          v.each { |tr|
            trsf = HgtParTransfer.new
            #check direction
            if con.bs_direct >= con.bs_inverse
              #direct transfer
              trsf.ncbi_seq_source_id = tr[0].to_i
              trsf.ncbi_seq_dest_id = tr[1].to_i
            else
              #inverse transfer
              trsf.ncbi_seq_source_id = tr[1].to_i
              trsf.ncbi_seq_dest_id = tr[0].to_i
            end

            trsf.weight = 1 / transfers_count
            trsf.hgt_par_fragm_id = k
            trsf.hgt_par_contin = con
            trsf.save
          
          } #v
         
            
        } #transfers_h



      end #end if con.bs_val 



    }
   
  end

   
   
  def elim_trivial_intra
    @conn.execute \
      "delete from HGT_PAR_TRANSFERS htx
      where htx.id in (select ht.id
                       from hgt_par_transfers ht
                        left join HGT_PAR_FRAGMS hf on hf.ID = ht.HGT_PAR_FRAGM_ID
                        left join NCBI_SEQS ns_src on ns_src.id = ht.NCBI_SEQ_SOURCE_ID
                        left join TAXON_GROUPS tg_src on tg_src.ID = ns_src.TAXON_ID
                        left join NCBI_SEQS ns_dest on ns_dest.id = ht.NCBI_SEQ_DEST_ID
                        left join TAXON_GROUPS tg_dest on tg_dest.ID = ns_dest.TAXON_ID
                       where tg_src.PROK_GROUP_ID = tg_dest.PROK_GROUP_ID and
                             hf.HGT_TYPE = 'Trivial')"
    @conn.execute <<-EOF
delete from HGT_PAR_FRAGMS
where id not in (
 select distinct hpf.ID
 from HGT_PAR_FRAGMS hpf
 join HGT_PAR_TRANSFERS hpt on hpt.HGT_PAR_FRAGM_ID = hpf.ID
 )
EOF
 
    
  end
  
  def prepare_hgt_par_trsf_taxons()
    
    @conn.execute \
      "truncate table hgt_par_trsf_taxons"
    
    puts "hgt_par_trsf_taxons table truncated..."
    
    
    @conn.execute \
    "insert into HGT_PAR_TRSF_TAXONS
      (gene_id,txsrc_id,txdst_id,weight_tr_tx)
     select hpf.gene_id,
       ns_src.TAXON_ID,
       ns_dest.TAXON_ID,
       sum(ht.WEIGHT)       
     from HGT_PAR_TRANSFERS ht
     join HGT_PAR_FRAGMS hpf on hpf.ID = ht.HGT_PAR_FRAGM_ID
     join NCBI_SEQS ns_src on ns_src.id = ht.NCBI_SEQ_SOURCE_ID
     join NCBI_SEQS ns_dest on ns_dest.id = ht.NCBI_SEQ_DEST_ID
     group by hpf.gene_id,
              ns_src.TAXON_ID,
              ns_dest.TAXON_ID
     order by hpf.gene_id,
              ns_src.TAXON_ID,
              ns_dest.TAXON_ID"
     
     
    puts "hgt_par_trsf_taxons table inserted..."
    
    
  end
  
 
  
  
  
  
  
  
  
  
  
  #specific sql
  def prepare_hgt_par_gene_groups_vals()
    
    arGeneGroupsVal.delete_all
    puts "#{arGeneGroupsVal.table_name} deleted..."
    
    @conn.execute \
      "insert into hgt_par_gene_groups_vals 
      (gene_id,PROK_GROUP_source_id,prok_group_dest_id,val)
      select  hpf.GENE_ID,
              tg_src.PROK_GROUP_ID,
              tg_dest.PROK_GROUP_ID,
              sum(ht.weight) as weight
      from hgt_par_transfers ht
        join HGT_PAR_FRAGMS hpf on hpf.ID = ht.HGT_PAR_FRAGM_ID
        join NCBI_SEQS ns_src on ns_src.id = ht.NCBI_SEQ_SOURCE_ID
        join TAXON_GROUPS tg_src on tg_src.TAXON_ID = ns_src.TAXON_ID
        join NCBI_SEQS ns_dest on ns_dest.id = ht.NCBI_SEQ_DEST_ID
        join TAXON_GROUPS tg_dest on tg_dest.TAXON_ID = ns_dest.TAXON_ID
      group by tg_src.PROK_GROUP_ID,
               tg_dest.PROK_GROUP_ID,
               hpf.GENE_ID
      order by tg_src.PROK_GROUP_ID,
               tg_dest.PROK_GROUP_ID,
               hpf.GENE_ID"
  
     
    puts "#{arGeneGroupsVal.name} inserted..."
  
    
  end
  

  def transfer_groups

    #HgtParTransferGroup.destroy_all
    HgtParTransferGroup.delete_all
    puts "destroyed HgtParTransferGroup..."
      
  
    #insert all prokariotes groups
    @conn.execute "insert into hgt_par_transfer_groups
                   (prok_group_source_id,prok_group_dest_id)
                    select pg1.ID,pg2.id
                    from PROK_GROUPS pg1
                     cross join PROK_GROUPS pg2
                    order by pg1.id,
                             pg2.id"

    puts "inserted all prokariotes groups..."

    @conn.execute "update hgt_par_transfer_groups htg
                   set htg.cnt =  select sum(ht.weight)
                   from hgt_par_transfers ht
                    left join NCBI_SEQS ns_src on ns_src.id = ht.NCBI_SEQ_SOURCE_ID
                    left join TAXON_GROUPS tg_src on tg_src.TAXON_ID = ns_src.TAXON_ID
                    left join NCBI_SEQS ns_dest on ns_dest.id = ht.NCBI_SEQ_DEST_ID
                    left join TAXON_GROUPS tg_dest on tg_dest.TAXON_ID = ns_dest.TAXON_ID
                   where tg_src.PROK_GROUP_ID = htg.prok_group_source_id and
                         tg_dest.PROK_GROUP_ID = htg.prok_group_dest_id 
                   group by tg_src.PROK_GROUP_ID,
                            tg_dest.PROK_GROUP_ID"
     
     
    puts "updated hgt_par_transfer_groups"
     
    
    HgtParTransferGroup.connection.execute "update hgt_par_transfer_groups
                                            set cnt=nvl(cnt,0)"
    
    puts "updated null hgt_par_transfer_groups..."


  end
  
   #load all group combinations
  #from all criteria
  def calc_transf_stats()
    
    @hpggv_hsh = arGeneGroupsVal.find(:all) \
      .each_with_object({ }){ |c, hsh| hsh[[c.gene_id,
          c.prok_group_source_id,
          c.prok_group_dest_id]
      ] = c.val }
    
    #puts "@hpggv_hsh: #{@hpggv_hsh.inspect}"
    #sleep 20
                                        
    @sg_hsh = arGeneGroupCnt.find(:all) \
      .each_with_object({ }){ |c, hsh| hsh[[c.gene_id,
          c.prok_group_id]
      ] = c.cnt }
  
     
    
  end
  
  
  #works only combined with base_transfer
  def calc_custom_config()
    
    @custom_configs = {}
    #hgt-par
    case @crit 
    when :family
      @custom_configs[[:all,"raxml",50, :abs]] = [410 + 15 ,140] #
      @custom_configs[[:all,"raxml",50, :rel]] = [410 + 30 ,140] #
    
      @custom_configs[[:all,"raxml",75, :abs]] = [410 - 20 + 15 ,140] #
      @custom_configs[[:all,"raxml",75, :rel]] = [410 + 22 ,140] #
    
    
      @custom_configs[[:regular,"raxml",50, :abs]] = [410 - 10 + 15,140] #
      @custom_configs[[:regular,"raxml",50, :rel]] = [410 + 20 ,140] #
    
      #most conservative
      @custom_configs[[:regular,"raxml",75, :abs]] = [410 - 30 + 15 +2, 140] #370
      
      @custom_configs[[:regular,"raxml",75, :rel]] = [430 ,130, 100] #
  
      
    when :habitat
      @custom_configs[[:all,"raxml",50, :abs]] = [210 ,80]
      @custom_configs[[:all,"raxml",50, :rel]] = [210 ,80]
    
      @custom_configs[[:all,"raxml",75, :abs]] = [210 ,80]
      @custom_configs[[:all,"raxml",75, :rel]] = [210 ,80]
    
    
      @custom_configs[[:regular,"raxml",50, :abs]] = [210 ,80]
      @custom_configs[[:regular,"raxml",50, :rel]] = [210 ,80]
    
      #most conservative
      @custom_configs[[:regular,"raxml",75, :abs]] = [225 ,80, 550]
      
      @custom_configs[[:regular,"raxml",75, :rel]] = [215 , 70, 2]
    end
    
    querry_arr = [@hgt_type, @phylo_prog, @thres, @calc_type] 
    puts "qer_arr: #{querry_arr.inspect}"
    puts "@custom_configs: #{@custom_configs.inspect}"
    @config = @custom_configs[querry_arr]
    
    
    
  end
  
  def leaf_transf_cnt()
    
    return HgtParTransfer.count
    
  end 
   
 
  #database sp
  def test_sp1()
    
    puts "test_sp1()"
    
    stmt = @jdbc_conn.create_statement

    # Define the query
    selectquery = %q{SELECT col1,col2
          FROM mytable}

    # Execute the query
    rs = stmt.execute_query(selectquery)
    
    
    # For each row returned do some stuff
    while (rs.next) do
      resa = Hash.new
      resa["col1"] = rs.getObject("col1")
      resa["col2"] = rs.getObject("col2")
      puts resa.inspect
    end
    # Close off the connection
    stmt.close
  
  end

  def test_sp2()
    
    puts "test_sp2()"
    
    call = @jdbc_conn.prepare_call("call proc1(1,2,?)")
    call.execute()
    
    value = call.get_int(1)

    puts "output: #{value}"
    
    #        c.close();
      
     
    # Close off the connection
    call.close
  
  end
  
  def test_sp3()
    
    puts "test_sp3()"
    
    call = @jdbc_conn.prepare_call("call size_by_group_gene(1)")
    call.execute()
    
    rs = call.getResultSet();
    
    
    # For each row returned do some stuff
    while (rs.next) do
      puts rs.inspect
      resa = Hash.new
      #resa["col1"] = rs.getObject("col1")
      #resa["col2"] = rs.getObject("col2")
      puts resa.inspect
    end
    # Close off the connection
    stmt.close
  
  end
    
  def sp_calculate_graph_java()
    
=begin

CREATE PROCEDURE construct_graph_java(IN GENE_ID INT, IN  EPSILON_SIM_FRAG DOUBLE, IN EPSILON_DIST_FRAG INT)
LANGUAGE JAVA DETERMINISTIC MODIFIES SQL DATA EXTERNAL NAME 'CLASSPATH:org.uqam.doct.proc.hom.sp.HgtPar.constructGraphJava'


{call CONSTRUCT_GRAPH_JAVA(167, 0.75, 10) }

=end    
    
    puts "sp_calculate_graph_java(#{@gene.id}, #{@epsilon_sim_frag}, #{@epsilon_dist_frag})"
    
    call = @jdbc_conn.prepare_call("{call CONSTRUCT_GRAPH_JAVA(#{@gene.id}, #{@epsilon_sim_frag}, #{@epsilon_dist_frag}) }")
    call.execute()
    
    puts "executed"
    call.close
    
  end
  
  def test_hgt_par_v1
    jdist = JavaHgtPar.jaccard_sim_coef("1,2","1,3","1,2","1,4")
    puts "jdist: #{jdist}"
    
  end
  
  def calc_global_hgt_rate
    
    trsf_all_sum = 0.0
    trsf_all_cnt = 0.0
    trsf_all_rate = 0.0
    
    @genes.each { |gn|
      #next if gn.id != 174
      
      #fetch nb of transfers
      sql = "select sum(ht.weight) as weight
             from hgt_par_transfers ht
               join HGT_PAR_FRAGMS hpf on hpf.ID = ht.HGT_PAR_FRAGM_ID
             where gene_id = #{gn.id}"
   
      trsfs = @conn.select_all sql
       
      
      trsf_cnt = trsfs.first["weight"].to_f
      
      
      #fetch nb of ncbi_seqs
      sql = "select count(*) as cnt
             from GENE_BLO_SEQS
             where gene_id = #{gn.id}"
   
      seqs_cnt = @conn.select_all(sql).first["cnt"].to_f
     
      val_one = trsf_cnt * seqs_cnt 
      trsf_all_cnt += seqs_cnt
      trsf_all_sum += val_one
      
      
      puts "trsf_cnt: #{trsf_cnt}, seqs_cnt: #{seqs_cnt}, rap: #{val_one}, trsf_all_cnt: #{trsf_all_cnt}, trsf_all_sum: #{trsf_all_sum}"
      
      
    }
    
    trsf_all_rate = trsf_all_sum / trsf_all_cnt
    puts "trsf_all_cnt: #{trsf_all_cnt}, trsf_all_sum: #{trsf_all_sum}, trsf_all_rate: #{trsf_all_rate}"
    trsf_all_rate /= 110
    #
    puts "trsf_all_cnt: #{trsf_all_cnt}, trsf_all_sum: #{trsf_all_sum}, trsf_all_rate: #{trsf_all_rate}"
    
      
  end
  
  


  
end
 

