
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

require 'java'
require 'jgrapht-0.8.2.jar'
require 'commons-lang3-3.1.jar'

JavaRange = org.apache.commons.lang3.Range

java_import org.jgrapht.UndirectedGraph
java_import org.jgrapht.graph.DefaultEdge
java_import org.jgrapht.graph.SimpleGraph
java_import org.jgrapht.alg.ConnectivityInspector





class AssertError < StandardError
end

class HgtPar

 # attr_accessor :thres
  attr_accessor :hgt_type #Regular/Trivial/All
  
 def initialize(phylo_prog_p, thres, fragm_thres, epsilon_sim_frag, epsilon_dist_frag)
  @stage = "hgt-par"
  @ud = UqamDoc::Parsers.new
  @phylo_prog = phylo_prog_p
  @thres = thres
  @fragm_thres = fragm_thres
  @epsilon_sim_frag = epsilon_sim_frag
  @epsilon_dist_frag = epsilon_dist_frag
  
 end
 
  def import_fragms
   HgtParFragm.destroy_all
    puts "destroyed HgtParFragm"
    sleep(5)    
  
    cnt = 0
   
    #use file values.txt for gene extraction, not database as expected
    files = `cat #{AppConfig.hgt_par_dir}/values.txt`
    files = files.split("\n")
    #puts files.inspect

    files[1..1].each { |fl|
       cnt += 1
       fl = fl.split

      
      @gene_name=fl[1]

      puts "gene_name: #{@gene_name}"
      sleep(10)
      @gene = Gene.find_by_name(@gene_name)
      
      #import one gene
      import_fragms_one_gene()

    }

  end
 
  def import_fragms_one_gene()
    
   
    [10,25,50].each { |win_size|

     @genes_dir =  "#{AppConfig.hgt_par_dir}/hgt-par-#{@phylo_prog}-#{win_size}"

      #Dir.chdir @gene_dir 
    
        
  

       @valid_win_path = "#{@genes_dir}/#{@gene_name}/valid_win.idx"
       puts "valid_win_path: #{@valid_win_path}"
        #sys "cp #{@valid_win_path} results/#{@gene_dir}/"

        File.open(@valid_win_path,"r") { |vwf|

          puts "vwf: #{vwf}"
          vwf.each { |win_dir|
       win_dir.chomp!
       puts win_dir
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
              puts "------------#{$1}---------->#{ln}"
              @iter_no = $1
            elsif ln =~ /^\|\sHGT\s(\d+)\s\/\s(\d+)\s+Trivial\s+\(bootstrap\svalue\s=\s([\d|\.]+)\%\sinverse\s=\s([\d|\.]+)\%\)/
              puts "Trivial: ------#{$1}--#{$3}--#{$4}---------->#{ln}"
               @hgt_type="Trivial"
               @hgt_no= $1
               @bs_direct = $3.to_f 
               @bs_inverse = $4.to_f
            elsif ln =~ /^\|\sHGT\s(\d+)\s\/\s(\d+)\s+Regular\s+\(bootstrap\svalue\s=\s([\d|\.]+)\%\sinverse\s=\s([\d|\.]+)\%\)/
              puts "Regular: ------#{$1}--#{$3}--#{$4}---------->#{ln}"
               @hgt_type="Regular"
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
              if @bs_val >= @fragm_thres
                #insert direct transfer, with weight_inverse information for inverse weight
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

  def str_lin_arr (from_subtree, to_subtree) 
   
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
    
    first_arr  = str_lin_arr (u_from, u_to)
    second_arr = str_lin_arr (v_from, v_to)

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
      puts "rng_a: #{rng_a}, ----- intersection ---- #{rng_a.intersection_with(rng_b)} ----  rng_b: #{rng_b} "
    elsif rng_a.is_before_range(rng_b)
      #connect non-overlaping near fragments
      dist = rng_b.get_minimum() - rng_a.get_maximum()
      connect_frag = true if dist <= @epsilon_dist_frag
      puts "rng_a: #{rng_a}, ----before ---dist: #{dist} ----  rng_b: #{rng_b} "

    elsif rng_a.is_after_range(rng_b)
      #connect non-overlaping near fragments
      dist = rng_a.get_minimum() - rng_b.get_maximum()
      connect_frag = true if dist <= @epsilon_dist_frag
      puts "rng_a: #{rng_a}, ----after ---dist: #{dist} ----  rng_b: #{rng_b} "

    end

    puts "connected: #{connect_frag}"
    return connect_frag


  end



  def construct_graph
   
    #frgms = HgtParFragm.select(:id).order(:id).map { |f| f.id }
    frgms = HgtParFragm.all
    #frg = frgms[0..5].map { |f| f.id }
 
    #frg.each {|fr|
    # puts fr
     
    #}

    n= (frgms.length - 1)
    puts n

    set = n.integer? ? (0..n) : n

    #complete graph without self
    #puts "set: #{set.inspect}"
    g= RGL::ImplicitGraph.new
    g.directed = false
      g.vertex_iterator { |b| set.each(&b) }
      g.adjacent_iterator { |x, b|
        set.each { |y| b.call(y) unless x == y }
      }
    #puts g.vertices().inspect
    #puts g.edges().inspect
    puts "----------------------"
   
     #g.each_connected_component { |comp|  puts comp.length }

    puts "++++++++++++++++++++"
=begin
    gr = RGL::ImplicitGraph.new
    gr.vertex_iterator { |b| frg.each(&b)
        #6.upto(n,&b) 
 
    }

    gr.write_to_graphic_file('jpg')


    n= 10
    g = RGL::ImplicitGraph.new # { |g|
        g.vertex_iterator { |b| 6.upto(n,&b) }
        g.adjacent_iterator { |x, b|
          n.downto(x+1) { |y| b.call(y) if y % x == 0 }
           }
           g.directed = true
        #}
     #puts g.inspect
=end
    #g.vertices_filtered_by {|v| v != 4}.to_s #=> "(1=2)(1=3)(2=3)"
     
       

     g1 = g.edges_filtered_by {|u,v| 
      u_from = frgms[u].from_subtree
      u_to   = frgms[u].to_subtree

      v_from = frgms[v].from_subtree
      v_to   = frgms[v].to_subtree
      
      jac =  jaccard_sim_coef(u_from, u_to, v_from, v_to)

      #puts "u: #{frgms[u].id}, v: #{frgms[v].id}, src_from: #{src_from}, src_to: #{src_to}, jac: #{jac}"

      if jac >= 0.75
       true
      else
        false
      end
      
     }

     puts "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
     
     ccomp = [] 
     g1.each_connected_component { |comp| 
        ccomp << comp 
        }
     
     puts "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
     puts ccomp.length
    ccomp.each { |e|
      print "#{e.length} ,"
    }
     puts ccomp.inspect
     #g1.directed = true
     #
     #puts g1.to_s
     #puts g.edges().to_s
     #g1.write_to_graphic_file('jpg')


      gr = SimpleGraph.new(DefaultEdge.new.java_class)
  gr.add_vertex "v1"
  gr.add_vertex "v2"
  gr.add_vertex "v3"
  gr.add_vertex "v4"

  gr.add_edge "v1", "v2"
  gr.add_edge "v1", "v4"
  puts gr.to_string()

  ci = ConnectivityInspector.new(gr)
  cs = ci.connected_sets()

    cs.each { |el|
      el.each { |mini|
   puts mini
      }

  puts el.to_string()

    }
puts "ok"







  end  
   
  def construct_graph_java
    puts "Entering construct_graph_java..."   

    frgms = HgtParFragm.all

    n= (frgms.length - 1)
    puts n

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
      ((u+1)..n).each { |v|
        #puts "u: #{u}, v: #{v}"

        #add edges
         u_from = frgms[u].from_subtree
         u_to   = frgms[u].to_subtree

         v_from = frgms[v].from_subtree
         v_to   = frgms[v].to_subtree
        #calculate Jaccard similarity
        jac =  jaccard_sim_coef(u_from, u_to, v_from, v_to)

        #puts "u: #{frgms[u].id}, v: #{frgms[v].id}, src_from: #{u_from}, src_to: #{u_to}, jac: #{jac}"

        #connect similar and proximal components
        if jac >= @epsilon_sim_frag and is_fragm_conn(frgms[u].fen_idx_min, \
                                                      frgms[u].fen_idx_max, \
                                                      frgms[v].fen_idx_min, \
                                                      frgms[v].fen_idx_max)
            gr.add_edge(u, v)
        else
         nil
        end
 
      }

    }

  puts gr.to_string()

  #retrieve connected components
  ci = ConnectivityInspector.new(gr)
  cs = ci.connected_sets()

   
    cs.each { |el|
      #details 

      if el.length > 1
       el.each { |m|
          puts "mini: #{m}, #{frgms[m].fen_idx_min}, #{frgms[m].fen_idx_max}"
       }
       puts el.to_string() 
      end

    }

    puts "n: #{n}, cs.length: #{cs.length}"







  end  
  
  
  
  def contin_fragms
    puts "Continuing fragments..."

     #recreate list of transfers
     HgtComIntTransfer.destroy_all

    
     HgtComIntContin.destroy_all

    

    #insert first half (direct transfers)
    HgtComIntContin.connection.execute "insert into hgt_com_int_contins
                                        (gene_id,
                                         iter_no,
                                         hgt_no,
                                         hgt_type,
                                         hgt_com_int_fragm_id,
                                         from_subtree,
                                         to_subtree,
                                         bs_val,
                                         weight
                                        )
                                      select gene_id,
                                             iter_no, 
                                             hgt_no,
                                             hgt_type,
                                             id,
                                             from_subtree,
                                             to_subtree,
                                             bs_val,
                                             weight_direct
                                      from hgt_com_int_fragms"
    contin_half_fragms()

    linearize_fragms()



    #insert inverse transfer
     HgtComIntContin.destroy_all
  

    #insert first half (direct transfers)
    HgtComIntContin.connection.execute "insert into hgt_com_int_contins
                                        (gene_id,
                                         iter_no,
                                         hgt_no,
                                         hgt_type,
                                         hgt_com_int_fragm_id,
                                         from_subtree,
                                         to_subtree,
                                         bs_val,
                                         weight
                                        )
                                      select gene_id,
                                             iter_no, 
                                             hgt_no,
                                             hgt_type,
                                             id,
                                             to_subtree,
                                             from_subtree,
                                             bs_val,
                                             weight_inverse
                                      from hgt_com_int_fragms"
    contin_half_fragms()

    linearize_fragms()




    
  end  


  def contin_half_fragms

    
    genes = HgtComIntContin.select(:gene_id).order(:gene_id).map { |c| c.gene_id }.uniq
    genes.each { |gn|
      puts "gene: #{gn.inspect}"
     iterations = HgtComIntContin.select(:iter_no).where("gene_id = ?",gn).order(:iter_no).map { |c| c.iter_no }.uniq
      iterations.each { |it|
        puts it.inspect
        puts "read database fragments to update"
        current_fragms = HgtComIntContin.select("hgt_no,to_subtree").where("gene_id = ? and iter_no = ?", gn, it).order(:hgt_no)

        next_fragms = HgtComIntContin.select("id,hgt_no,from_subtree").where("gene_id = ? and iter_no > ?", gn, it).order("iter_no,hgt_no")
        
        #all taxons to remove in this iteration
          all_taxons_to_remove = []
        current_fragms.each { |cf|
          #puts "current fragment: #{cf.inspect}"
          taxons_to_remove = cf.to_subtree.split(",").collect{|x| x.lstrip}
          #accumulate all taxons for this iteration
          all_taxons_to_remove << taxons_to_remove
          all_taxons_to_remove.flatten!
          puts "taxons to remove: #{taxons_to_remove.inspect}"
       
          
          
     
        } #we know which taxons to remove

        puts "all taxons to remove: #{all_taxons_to_remove.inspect}"

        next_fragms.each { |nf|
          #puts "next fragment: #{nf.inspect}"
          taxons_to_update = nf.from_subtree.split(",").collect{|x| x.lstrip}
          puts "taxons to update: #{taxons_to_update.inspect}, taxons to erase: #{(taxons_to_update & all_taxons_to_remove).inspect}"
          taxons_remaining = (taxons_to_update - all_taxons_to_remove).sort.join(", ")
          puts "taxons_remaining: #{taxons_remaining}"
          
          #update database
          row = HgtComIntContin.find(nf.id)
          puts row.inspect
          row.from_subtree=taxons_remaining
          #update number
          row.from_cnt=taxons_remaining.split(",").length
          #persist to database
          row.save 
          
         
        } 
        puts "all fragments processed"

      }

    }
  end
 


  def elim_trivial_intra
     HgtComIntTransfer.connection.execute \
     "delete from HGT_COM_INT_TRANSFERS htx
      where htx.id in (select ht.id
                       from hgt_com_int_transfers ht
                        left join HGT_COM_INT_FRAGMS hf on hf.ID = ht.HGT_COM_INT_FRAGM_ID
                        left join NCBI_SEQS ns_src on ns_src.id = ht.SOURCE_ID
                        left join TAXON_GROUPS tg_src on tg_src.ID = ns_src.TAXON_ID
                        left join NCBI_SEQS ns_dest on ns_dest.id = ht.DEST_ID
                        left join TAXON_GROUPS tg_dest on tg_dest.ID = ns_dest.TAXON_ID
                       where tg_src.PROK_GROUP_ID = tg_dest.PROK_GROUP_ID and
                             hf.HGT_TYPE = 'Trivial')"
 
    
  end

  def transfer_groups
  
     #recreate recomb_transfer_groups   
     HgtComIntTransferGroup.destroy_all

     #process all transfers
    # recomb_transfers = RecombTransfer.find(:all)
    #recomb_transfers.each { |rt|
  
 #     rtg
 #     puts "rt.id: #{rt.id}, rt.source: #{rt.source.taxon_group.prok_group.inspect}"
  #     

   # }

     #insert all prokariotes groups
     HgtComIntTransferGroup.connection.execute "insert into hgt_com_int_transfer_groups
                                              (source_id,dest_id)
                                              select pg1.ID,pg2.id
                                              from PROK_GROUPS pg1
                                                cross join PROK_GROUPS pg2 
                                              order by pg1.id,
                                                       pg2.id"
    # transfers are already filtered by threshold  
    #where ht.confidence >= #{@thres} and
    #denormalize regular transfers as regular_cnt
     HgtComIntTransferGroup.connection.execute "update hgt_com_int_transfer_groups htg
                                               set htg.regular_cnt =  select sum(ht.weight)
                                               from hgt_com_int_transfers ht
                                                left join HGT_COM_INT_FRAGMS hf on hf.ID = ht.HGT_COM_INT_FRAGM_ID
                                                left join NCBI_SEQS ns_src on ns_src.id = ht.SOURCE_ID
                                                left join TAXON_GROUPS tg_src on tg_src.ID = ns_src.TAXON_ID  
                                                left join NCBI_SEQS ns_dest on ns_dest.id = ht.DEST_ID
                                                left join TAXON_GROUPS tg_dest on tg_dest.ID = ns_dest.TAXON_ID
                                               where tg_src.PROK_GROUP_ID = htg.source_id and
                                                     tg_dest.PROK_GROUP_ID = htg.dest_id and
                                                     hf.HGT_TYPE = 'Regular'
                                               group by tg_src.PROK_GROUP_ID,
                                                        tg_dest.PROK_GROUP_ID"
     
    #denormalize trivial transfers as trivial_cnt
     HgtComIntTransferGroup.connection.execute "update hgt_com_int_transfer_groups htg
                                               set htg.trivial_cnt =  select sum(ht.weight)
                                               from hgt_com_int_transfers ht
                                                left join HGT_COM_INT_FRAGMS hf on hf.ID = ht.HGT_COM_INT_FRAGM_ID
                                                left join NCBI_SEQS ns_src on ns_src.id = ht.SOURCE_ID
                                                left join TAXON_GROUPS tg_src on tg_src.ID = ns_src.TAXON_ID  
                                                left join NCBI_SEQS ns_dest on ns_dest.id = ht.DEST_ID
                                                left join TAXON_GROUPS tg_dest on tg_dest.ID = ns_dest.TAXON_ID
                                               where tg_src.PROK_GROUP_ID = htg.source_id and
                                                     tg_dest.PROK_GROUP_ID = htg.dest_id and
                                                     hf.HGT_TYPE = 'Trivial'
                                               group by tg_src.PROK_GROUP_ID,
                                                        tg_dest.PROK_GROUP_ID"
     
      
      RecombTransferGroup.connection.execute "update hgt_com_int_transfer_groups
                                               set regular_cnt=nvl(regular_cnt,0),
                                                   trivial_cnt=nvl(trivial_cnt,0)"

  end



   def export_transfer_groups_matrix

     FasterCSV.open("#{AppConfig.db_exports_dir}/#{@stage}/tr-gr-mat-#{@phylo_prog}-#{@thres}-#{hgt_type.to_s}.csv", "w", {:col_sep => "|"}) { |csv|
     row = []
      row << 'NAME'
      row << 'SRC_ID \ DEST_ID'
      (0..22).each { |x|
        row << x.to_s
      }

      csv << row  
      
      #debugging
      regular_tr_by_gene = HgtComIntTransferGroup.sum(:regular_cnt) / Gene.count
      trivial_tr_by_gene = HgtComIntTransferGroup.sum(:trivial_cnt) / Gene.count
      tr_by_gene =  case 
        when @hgt_type == :regular
         regular_tr_by_gene
        when @hgt_type == :all
         regular_tr_by_gene + trivial_tr_by_gene
        else
         raise AssertError.new "Not Implemented"
      end
     

      puts "Transfers by gene: #{tr_by_gene}, Gene count: #{Gene.count}"

           

      #for each row
      (0..22).each { |y|
        row = []
        #name of the group
        pg = ProkGroup.find(y)
        pgtn = TaxonGroup.joins(:ncbi_seqs => :gene_blo_seq) \
                         .where("prok_group_id=?",y) \
                         .group("prok_group_id") \
                         .select("count(distinct TAXON_ID) as cnt")[0]

        #select count(*)
        #from taxon_groups tg
        #join ncbi_seqs ns on ns.TAXON_ID = tg.ID
        #join GENE_BLO_SEQS gbs on gbs.NCBI_SEQ_ID = ns.ID
        #where tg.PROK_GROUP_ID=8

        #find nb of sequences in group
        pgsn = TaxonGroup.joins(:ncbi_seqs => :gene_blo_seq) \
                         .where("prok_group_id=?",y) \
                         .select("count(*) as cnt")[0]

         row << "#{pg.name}(#{pgtn.cnt}),[#{pgsn.cnt}]"

        row << y
         (0..22).each { |x|
          #recomb_transfer_groups
          htg = HgtComIntTransferGroup.find_by_source_id_and_dest_id(y,x)

          
          hgt_cnt =  case @hgt_type
          when :regular
           htg.regular_cnt           
          when :all
           htg.regular_cnt + htg.trivial_cnt
          else
           raise AssertError.new ""
          end
         
          row << [hgt_cnt== 0  ? nil : "%5.2f" % hgt_cnt ]


         #truncate output to one decimal

         
         }
        csv << row

       }

      #Global statistics
      regular_group_transf_cnt = HgtComIntContin \
                                 .joins(:hgt_com_int_fragm) \
                                .where("bs_val >= ? and hgt_type = ?", @thres, "Regular").count
       #puts "regular_group_transf_cnt: #{regular_group_transf_cnt}"
      regular_leaf_transf_cnt = HgtComIntTransfer.joins(:hgt_com_int_fragm) \
                                .where("confidence >= ? and hgt_type = ?", @thres, "Regular").count
      
      #Global statistics
      trivial_group_transf_cnt = HgtComIntContin \
                                 .joins(:hgt_com_int_fragm) \
                                .where("bs_val >= ? and hgt_type = ?", @thres, "Trivial").count
       #puts "regular_group_transf_cnt: #{regular_group_transf_cnt}"
      trivial_leaf_transf_cnt = HgtComIntTransfer \
                                .joins(:hgt_com_int_fragm) \
                                .where("confidence >= ? and hgt_type = ?", @thres, "Trivial").count
      
       case @hgt_type
          when :regular
           group_transf_cnt = regular_group_transf_cnt
           leaf_transf_cnt = regular_leaf_transf_cnt            
          when :all
           group_transf_cnt = regular_group_transf_cnt + trivial_group_transf_cnt
           leaf_transf_cnt = regular_leaf_transf_cnt + trivial_leaf_transf_cnt
          else
           raise AssertError.new ""
          end

       

      genes_cnt = Gene.count



      group_transf_cnt_per_gene = (group_transf_cnt.to_f/genes_cnt.to_f).to_f

       csv << ""
       csv << "-------------------------"       
       csv << "Phylogeny program: #{@phylo_prog}"
       csv << "Bootstrap values threshold: #{@thres}"
       csv << "-------------------------"
       csv << "Grouped transfers total: #{group_transf_cnt}"
       csv << "Leaf transfers: #{leaf_transf_cnt}"
       csv << "Genes: #{genes_cnt}"
       csv << "-------------------------"
       csv << "Grouped transfers per gene: #{"%5.2f" % group_transf_cnt_per_gene}"
       
       

     } #end csv

   end


   #calculate transfer group matrix data
   # &
   #export data file
   def calc_exp_transf_gr_mat_data 

     @tr_gr_mat = mat = Array.new(23) { Array.new(23) }

     #base name of heatmaps export files by parameter names
     @hm_base_name = "#{@phylo_prog}-#{@thres}-#{hgt_type.to_s}-#{@stage}-hm"

     #base name of matrix export files by parameter names
     @mt_base_name = "#{@phylo_prog}-#{@thres}-#{hgt_type.to_s}-#{@stage}-mt"
     

     #will export matrix core data file
     dat_f = File.new("#{AppConfig.db_exports_dir}/#{@stage}/#{@hm_base_name}.dat", "w")    
      

      #for each row
      (0..22).each { |s|

        y=ProkGroup.find_by_order_id(s).id
        
        #name of the group
        pgy = ProkGroup.find(y)
        pgtn = TaxonGroup.joins(:ncbi_seqs => :gene_blo_seq) \
                         .where("prok_group_id=?",y) \
                         .group("prok_group_id") \
                         .select("count(distinct TAXON_ID) as cnt")[0]


        #find nb of sequences in group
        pgsn = TaxonGroup.joins(:ncbi_seqs => :gene_blo_seq) \
                         .where("prok_group_id=?",y) \
                         .select("count(*) as cnt")[0]
                
       #puts "s: #{s}"

          (0..22).each { |d|
            x=ProkGroup.find_by_order_id(d).id
            pgx = ProkGroup.find(x)           

          #recomb_transfer_groups
          htg = HgtComIntTransferGroup.find_by_source_id_and_dest_id(y,x)

        # puts "d: #{d}"
          
         #puts "@hgt_type: #{@hgt_type}"

          hgt_cnt =  case @hgt_type
          when :regular
           htg.regular_cnt           
           
          when :all
           htg.regular_cnt + htg.trivial_cnt
          else
           raise AssertError.new ""
          end

         #puts "hgt_cnt: #{hgt_cnt}"

         #put cell value
         @tr_gr_mat[s][d] = hgt_cnt

         cell = "#{s.to_s}\t\"#{pgy.name}\"\t#{d.to_s}\t\"#{pgx.name}\"\t"
         cell += "%5.2f" % hgt_cnt
         dat_f.puts cell

         
         }
         
       }

    dat_f.close



   end

   #Global statistics
   def calc_transf_gr_mat_stats


      #regular_group_transf_cnt = HgtComIntContin \
      #                           .joins(:hgt_com_int_fragm) \
      #                          .where("bs_val >= ? and hgt_type = ?", @thres, "Regular").count
       #puts "regular_group_transf_cnt: #{regular_group_transf_cnt}"
      regular_leaf_transf_cnt = HgtComIntTransfer.joins(:hgt_com_int_fragm) \
                                .where("confidence >= ? and hgt_type = ?", @thres, "Regular").count
      
      #Global statistics
      #trivial_group_transf_cnt = HgtComIntContin \
      #                           .joins(:hgt_com_int_fragm) \
      #                          .where("bs_val >= ? and hgt_type = ?", @thres, "Trivial").count
       #puts "regular_group_transf_cnt: #{regular_group_transf_cnt}"
      trivial_leaf_transf_cnt = HgtComIntTransfer \
                                .joins(:hgt_com_int_fragm) \
                                .where("confidence >= ? and hgt_type = ?", @thres, "Trivial").count
      
       case @hgt_type
          when :regular
           #group_transf_cnt = regular_group_transf_cnt
           @leaf_transf_cnt = regular_leaf_transf_cnt            
          when :all
           #group_transf_cnt = regular_group_transf_cnt + trivial_group_transf_cnt
           @leaf_transf_cnt = regular_leaf_transf_cnt + trivial_leaf_transf_cnt
          else
           raise AssertError.new ""
          end

       

       @genes_cnt = Gene.count
      # group_transf_cnt_per_gene = (group_transf_cnt.to_f/genes_cnt.to_f).to_f
       @mt_all_cnt_per_gene = (@mt_all.to_f/@genes_cnt.to_f).to_f
        
       puts "@mt_all_cnt_per_gene: #{@mt_all_cnt_per_gene}"
       #cap = ""
     # cap += " \\large Complete gene transfers calculated with   \\textbf{#{@phylo_prog}}, "
     #cap += "with a bootstrap values threshold of \\textbf{#{@thres}}, "
     #cap += "for \\textbf{#{@hgt_type}} transfers. \n" 
     #cap += "Grouped transfers total: \\textbf{#{group_transf_cnt}}. \n"
     #cap += "Leaf transfers: \\textbf{#{leaf_transf_cnt}}. \n"
     #cap += "Genes: \\textbf{#{genes_cnt}}. \n"
     #cap += "Grouped transfers per gene: \\textbf{#{"%5.2f" % group_transf_cnt_per_gene}}. \n"
   
      #debugging
      #regular_tr_by_gene = HgtComIntTransferGroup.sum(:regular_cnt) / Gene.count
      #trivial_tr_by_gene = HgtComIntTransferGroup.sum(:trivial_cnt) / Gene.count
      #tr_by_gene =  case 
      #  when @hgt_type == :regular
      #   regular_tr_by_gene
     #   when @hgt_type == :all
     #    regular_tr_by_gene + trivial_tr_by_gene
     #   else
     #    raise AssertError.new "Not Implemented"
     # end
     

      #puts "Transfers by gene: #{tr_by_gene}, Gene count: #{Gene.count}"

   end

   def calc_transf_gr_mat_sums 
      
       #total of totals in matrix
       @mt_all = 0
       #used in gnuplot file for defining lateral graphics scale limit
       # @hgt_ymax_perc = 0
       # @hgt_xmax_perc = 0

       #used in matrix lateral columns
       @mt_ysums = []
       @mt_ysums_intra = []
       @mt_ysums_inter = []

       @mt_xsums = []
       @mt_xsums_intra = []
       @mt_xsums_inter = []

       #used in gnuplot lateral graphics
       @mt_yperc_1 = []
       @mt_yperc_2 = []

       @mt_xperc_1 = []
       @mt_xperc_2 = []     


     #calculate ysums and total of totals
     (0..22).each { |s|
       @mt_ysums[s] = 0
       @mt_ysums_inter[s] = 0
       @mt_ysums_intra[s] = 0
       (0..22).each { |d|
          @mt_ysums_inter[s] += @tr_gr_mat[s][d] if s != d
          @mt_ysums_intra[s] += @tr_gr_mat[s][d] if s == d
          @mt_ysums[s] += @tr_gr_mat[s][d]            
           
          @mt_all += @tr_gr_mat[s][d]
       }

       

 
      #puts "@mt_ysums[#{s}]: #{@mt_ysums[s]}"
       #puts "@mt_ysums_inter[#{s}]: #{@mt_ysums_inter[s]}"
       #puts "@mt_ysums_intra[#{s}]: #{@mt_ysums_intra[s]}"
   
     
        
     }



     #calculate xsums
     (0..22).each { |d|
       @mt_xsums[d] = 0
       @mt_xsums_inter[d] = 0
       @mt_xsums_intra[d] = 0
       (0..22).each { |s|
          @mt_xsums_inter[d] += @tr_gr_mat[s][d] if s != d
          @mt_xsums_intra[d] += @tr_gr_mat[s][d] if s == d
          @mt_xsums[d] += @tr_gr_mat[s][d]            
           
       }
 
      #puts "@mt_xsums[#{d}]: #{@mt_xsums[d]}"
       #puts "@mt_xsums_inter[#{d}]: #{@mt_xsums_inter[d]}"
       #puts "@mt_xsums_intra[#{d}]: #{@mt_xsums_intra[d]}"
   
     
        
     }


     #calculate lateral percentages

     (0..22).each { |i|
       #right values
       @mt_yperc_1[i] = @mt_ysums_inter[i] / (@mt_ysums_inter[i] + @mt_xsums_inter[i]) * 100
       @mt_yperc_2[i] = @mt_xsums_inter[i] / (@mt_ysums_inter[i] + @mt_xsums_inter[i]) * 100


       #bottom values
       @mt_xperc_1[i] = (@mt_ysums_intra[i] + @mt_xsums_intra[i]) / (@mt_ysums_intra[i] + @mt_xsums_intra[i] + @mt_ysums_inter[i] + @mt_xsums_inter[i]) * 100
       @mt_xperc_2[i] = (@mt_ysums_inter[i] + @mt_xsums_inter[i]) / (@mt_ysums_intra[i] + @mt_xsums_intra[i] + @mt_ysums_inter[i] + @mt_xsums_inter[i]) * 100

       
     }
     

     #right scale limit
     @mt_ymax_perc = 100
     #down scale limit
     @mt_xmax_perc = 100
     


     # hgt_yall = @hgt_ysums_inter + @hgt_ysums_intra
     # hgt_xall = @hgt_xsums_inter + @hgt_xsums_intra

     #puts "hgt_yall: #{hgt_yall.inspect}"
     #puts "hgt_xall: #{hgt_xall.inspect}"

     #hgt_ymax = hgt_yall.max
     #puts "hgt_ymax: #{hgt_ymax}"

     #hgt_xmax = hgt_xall.max
     #puts "hgt_xmax: #{hgt_xmax}"


     #puts "@hgt_all: #{@hgt_all}"

     # @hgt_ymax_perc = "%1.0f" % (hgt_ymax/@hgt_all*100)
     
     #puts "@hgt_ymax_perc: #{@hgt_ymax_perc}"

     # @hgt_xmax_perc = "%1.0f" % (hgt_xmax/@hgt_all*100)
     #puts "@hgt_xmax_perc: #{@hgt_xmax_perc}"

            
     # @hgt_yperc_inter = @hgt_ysums_inter.collect{ |e| "%1.0f" % (e/hgt_ymax*100)}
     # @hgt_yperc_intra = @hgt_ysums_intra.collect{ |e| "%1.0f" % (e/hgt_ymax*100)}
     #puts "@hgt_yperc_inter: #{@hgt_yperc_inter.inspect}"
     #puts "@hgt_yperc_intra: #{@hgt_yperc_intra.inspect}"
     
     # @hgt_xperc_inter = @hgt_xsums_inter.collect{ |e| "%1.0f" % (e/hgt_xmax*100)}
     # @hgt_xperc_intra = @hgt_xsums_intra.collect{ |e| "%1.0f" % (e/hgt_xmax*100)}
     #puts "@hgt_xperc_inter: #{@hgt_xperc_inter.inspect}"
     #puts "@hgt_xperc_intra: #{@hgt_xperc_intra.inspect}"

     #export lateral graphicdata        
     daty_f = File.new("#{AppConfig.db_exports_dir}/#{@stage}/#{@hm_base_name}.daty", "w")
     (0..22).each { |s|
     
       daty_f.puts "#{s}\t#{"%1.0f" % @mt_yperc_1[s]}\t#{ "%1.0f" % @mt_yperc_2[s]}"

     }
 
     daty_f.close

     #export bottom graphicdata
     datx_f = File.new("#{AppConfig.db_exports_dir}/#{@stage}/#{@hm_base_name}.datx", "w")

     (0..22).each { |d|

       datx_f.puts "#{d}\t#{"%1.0f" % @mt_xperc_1[d]}\t#{"%1.0f" % @mt_xperc_2[d]}"

     }

     datx_f.close
    

   end

   def export_transfer_groups_matrix_tex

     @highlight_thres = 0.75
     tex_fname = "#{AppConfig.db_exports_dir}/#{@stage}/#{@mt_base_name}.tex"
     tex = File.new(tex_fname, "w")

     tex.puts '\documentclass[]{article}'
     tex.puts '\usepackage[vcentering,dvips,top=5mm, bottom=5mm, left=5mm, right=5mm]{geometry}'
     tex.puts '\geometry{papersize={395mm,140mm}}'
     tex.puts '\pagestyle {empty}'
     tex.puts '\usepackage{graphicx}'
     tex.puts '\usepackage{subfig}'
     tex.puts '\usepackage{colortbl}'
     tex.puts '\usepackage{arydshln}'

     tex.puts '\captionsetup[table]{position=top, justification=centering}'

     tex.puts '\begin{document}'

     tex.puts '\begin{table}'

     
       cap = ""
     cap += " \\large Complete gene transfers calculated with   \\textbf{#{@phylo_prog}}, "
     cap += "with a bootstrap values threshold of \\textbf{#{@thres}}, "
     cap += "for \\textbf{#{@hgt_type}} transfers. \n"
     cap += "\\\\" 
     cap += "Average number of transfers total: \\textbf{#{"%5.2f" % @mt_all}}. \n"
     cap += "Leaf transfers: \\textbf{#{@leaf_transf_cnt}}. \n"
     cap += "Genes: \\textbf{#{@genes_cnt}}. \n"
     cap += "\\\\"
     cap += "Average number of transfers per gene: \\textbf{#{"%5.2f" % @mt_all_cnt_per_gene}}. \n"
     cap += "Intragroup transfers are underligned."
     cap += "\\\\"
     cap += "Values over \\textbf{#{"%3.0f" % (@highlight_thres *100)}\\%} of the average number of transfers per gene, are represented in boldface."


     tex.puts "\\caption{#{cap}}"  

      

   
     row = '\begin{tabular}{'
     row += 'l'
     (0..24).each { |x|  row += 'c' }
     row += '}'
     tex.puts row

     row = 'Name & Source$\backslash$Destination & '
      (0..22).each { |x|
        row += (x+1).to_s
        row += ' & '
      }
     row += 'Total \\\\'

     tex.puts row

           
      #for each row
      (0..22).each { |s|

        y=ProkGroup.find_by_order_id(s).id
        
        #name of the group
        pg = ProkGroup.find(y)
        pgtn = TaxonGroup.joins(:ncbi_seqs => :gene_blo_seq) \
                         .where("prok_group_id=?",y) \
                         .group("prok_group_id") \
                         .select("count(distinct TAXON_ID) as cnt")[0]

 
        #find nb of sequences in group
        pgsn = TaxonGroup.joins(:ncbi_seqs => :gene_blo_seq) \
                         .where("prok_group_id=?",y) \
                         .select("count(*) as cnt")[0]

        row = "#{pg.name}(#{pgtn.cnt}),[#{pgsn.cnt}] & "
        row += (s+1).to_s 
        row += ' & '

          (0..22).each { |d|
            x=ProkGroup.find_by_order_id(d).id
           
          hgt_cnt = @tr_gr_mat[s][d]
          #truncate output to one decimal         
          hgt_cnt== 0  ? cell = "" : cell = "%1.2f" % hgt_cnt 
           
          #italics on diagonal
          cell = '\underline{' + cell + '}' if s == d
          cell = '\textbf{' + cell + '}' if hgt_cnt >= (@highlight_thres * @mt_all_cnt_per_gene)
          row += cell
          row += ' & '
         
         }
         
         # y sums
         row += "%5.2f" % @mt_ysums[s]
         row += " \\\\"
        tex.puts row

       }
       
       #x totals
       row = ' & Total & '
      (0..22).each { |t|
          x=ProkGroup.find_by_order_id(t).id

         #xsums    
         row += "%5.2f" % @mt_xsums[t]
         row += ' & '
      }
        #Grand Total
        
       row += "%5.2f" % @mt_all
       row += ' \\\\'

       tex.puts row
       
   

     
     tex.puts '\end{tabular}'
     tex.puts '\end{table}'
     tex.puts '\end{document}'
     tex.close

     #compile pdfs
     Dir.chdir "#{AppConfig.db_exports_dir}/#{@stage}"
     cmd = "pdflatex #{tex_fname}"
     puts cmd
     `#{cmd}`



   end



    
   #heatmaps
   def exp_transf_gr_heatmap_gp

     #
     case @phylo_prog
       when "phyml"
        @phylo_prog_txt = "PhyML"
       when "raxml"
        @phylo_prog_txt = "RAxML"
     end


     case @stage 
       when "hgt-com"
        @stage_txt = "Complete HGT"
     end

     case @hgt_type
       when :regular
        @hgt_type_txt = "Regular"
       when :all
        @hgt_type_txt = "All"
     end

     #gnuplot template erb file  
     hm_text = File.read("#{AppConfig.db_exports_dir}/#{@stage}/hm-gp.erb")
     #gnuplot specific file
     gp_fname = "#{AppConfig.db_exports_dir}/#{@stage}/#{@hm_base_name}.gp" 
     gp_f = File.new(gp_fname, "w")


     #write gnuplot file from erb template
     b= binding

     gp_erb = ERB.new(hm_text)

     #uses @hm_base_name
     gp_f.puts gp_erb.result(b)

     gp_f.close

     #compile pdfs
     Dir.chdir "#{AppConfig.db_exports_dir}/#{@stage}"
     cmd = "gnuplot #{gp_fname}"
     puts cmd
     `#{cmd}`
   end


 
end
