require 'rubygems'
require 'msa_tools'
require "active_support/all"
require 'csv'

require 'java'
require '/root/devel/proc_hom/lib/poi-3.9/poi-3.9-20121203.jar'

JavaHSSFWorkbook = org.apache.poi.hssf.usermodel.HSSFWorkbook
JavaHSSFRichTextString = org.apache.poi.hssf.usermodel.HSSFRichTextString
JavaWorkbookUtil = org.apache.poi.ss.util.WorkbookUtil
JavaCellStyle = org.apache.poi.ss.usermodel.CellStyle
JavaFont = org.apache.poi.ss.usermodel.Font
JavaHSSFColor = org.apache.poi.hssf.util.HSSFColor

JavaFileOutputStream = java.io.FileOutputStream

require 'rserve'


#open Matrix
class Matrix
  def dump(firstLine = "")
    str = ""
    if firstLine != ""
      str << firstLine << "\n"
    end
    for i in 0...self.row_size
      space = ""
      for j in 0...self.column_size
        str << space << self[i,j].to_s
        space = " "
      end
      str << "\n"
    end
    return str
  end
  # La classe Matrix est immutable, or je veux pouvoir écrire :
  #   m[i,j] = v
  #
  def []=(i, j, v)
    @rows[i][j] = v
  end
  # Il n'y a même pas de constructeur pour une matrice rectangulaire : bouhhh
  # Le prefixe "self." permet de déclarer une méthode de classe
  def self.create(nbRows, nbCols, value)
    return Matrix.rows(Array.new(nbRows, Array.new(nbCols,value)))
  end
end



module BaseTransfer
  
  attr_accessor :gn_mt_min_th,:gn_tt_min_th
  
  def rl_tr_mat
    @rl_tr_mat
  end
  
  
  # Initialize module.
  def self.included(base)
  
    #puts "BaseTransfer.base: #{base.inspect}"
    
  end


  def initialize()
    puts "in BaseTransfer initialize"
    
  end

  def init()
    puts "in BaseTransfer.init"
    
    load_format_options()

    #continue chain of extend
    super
  end
  
  #formatting function
  def cell_frm_f(factor)
    return Proc.new {|n| 
      str =  "%5.3f" % ( (n * 10 ** factor).ceil.to_f / 10 ** factor ) 
      str.strip()
    }
  end
  
  #distributes transfers according to taxon_group classification
  #only inter group transfers for each group criter are taken into account
  #
  def prepare_hgt_trsf_prkgrs()
    
    #missing truncate
    @conn.execute \
      "truncate table #{@arTrsfPrkgr.table_name}"
    
    puts "#{@arTrsfPrkgr.table_name} table truncated..."
    
     
    tr_taxons = @arTrsfTaxon.select("id,gene_id,txsrc_id,txdst_id,weight_tr_tx,age_md_wg_tr_tx")

    puts "tr_taxons.inspect: #{tr_taxons.inspect}"

    tr_taxons.each {|tr|
     
      puts "tr.id: #{tr.id}" if tr.id % 1000 == 0

      #debugging
      #next unless tr.gene_id == 111 and tr.txsrc_id == 768679 and tr.txdst_id == 374847
          
      #puts "tr: #{tr.inspect}"
      #puts "tr.id: #{tr.id}, #{tr.gene_id}"
     
      #for each chiteria
      (0..1).each {|crit|
        
        #prok_group_id and weight
        pg_id_weight = Proc.new{|txid, crit|
          sql = "select tg.PROK_GROUP_ID,
                        tg.WEIGHT_PG
                 from TAXON_GROUPS tg
                  join PROK_GROUPS pg on pg.id = tg.PROK_GROUP_ID
                 where tg.TAXON_ID = #{txid} and
                       pg.GROUP_CRITER_ID = #{crit}"
          TaxonGroup.find_by_sql(sql)
        }
        
       
     
        pg_src = pg_id_weight.call(tr.txsrc_id,crit)
      
        pg_dst = pg_id_weight.call(tr.txdst_id,crit)
      
        pg_src.each {|src|
          pg_dst.each {|dst|
            
            #puts "src: #{src.inspect}"
            #puts "dst: #{dst.inspect}"
            
            #insert alternative
            prkg = @arTrsfPrkgr.new 
            prkg.gene_id = tr.gene_id
            prkg.trsf_taxon_id = tr.id
            prkg.pgsrc_id = src.prok_group_id
            prkg.pgdst_id = dst.prok_group_id
            prkg.weight_tr_pg = tr.weight_tr_tx * src.weight_pg * dst.weight_pg
            #prkg.age_md_wg_tr_pg = tr.age_md_wg_tr_tx * src.weight_pg * dst.weight_pg
            prkg.save
          }
        }
      }  
    }
  end
  
  def prepare_qfunc_hgt_trsf_prkgrs()
    
    #missing truncate
    @conn.execute \
      "truncate table #{@arTrsfPrkgr.table_name}"
    
    puts "#{@arTrsfPrkgr.table_name} table truncated..."
    
    
     
    tr_taxons = @arTrsfTaxon.select("id,gene_id,txsrc_id,txdst_id,weight_tr_tx")
    
    
    #puts "tr_taxons.inspect: #{tr_taxons.inspect}"

    tr_taxons.each {|tr|
     
      puts "tr.id: #{tr.id}" if tr.id % 1000 == 0

      #debugging
      #next unless tr.gene_id == 111 and tr.txsrc_id == 768679 and tr.txdst_id == 374847
          
      #puts "tr: #{tr.inspect}"
      #puts "tr.id: #{tr.id}, #{tr.gene_id}"
     
      #for each chiteria
      (0..1).each {|crit|
        
        #prok_group_id and weight
        pg_id_weight = Proc.new{|txid, crit|
          sql = "select tg.PROK_GROUP_ID,
                        tg.WEIGHT_PG
                 from TAXON_GROUPS tg
                  join PROK_GROUPS pg on pg.id = tg.PROK_GROUP_ID
                 where tg.TAXON_ID = #{txid} and
                       pg.GROUP_CRITER_ID = #{crit}"
          TaxonGroup.find_by_sql(sql)
        }
        
       
     
        pg_src = pg_id_weight.call(tr.txsrc_id,crit)
      
        pg_dst = pg_id_weight.call(tr.txdst_id,crit)
      
        pg_src.each {|src|
          pg_dst.each {|dst|
            
            #puts "src: #{src.inspect}"
            #puts "dst: #{dst.inspect}"
            
            #insert alternative
            prkg = @arTrsfPrkgr.new 
            prkg.gene_id = tr.gene_id
            prkg.trsf_taxon_id = tr.id
            prkg.pgsrc_id = src.prok_group_id
            prkg.pgdst_id = dst.prok_group_id
            prkg.weight_tr_pg = tr.weight_tr_tx * src.weight_pg * dst.weight_pg
            #prkg.age_md_wg_tr_pg = tr.age_md_wg_tr_tx * src.weight_pg * dst.weight_pg
            prkg.save
          }
        }
      }  
    }
  end
  
  
  def prepare_gene_groups_vals
    
    
    @conn.execute \
      "truncate table #{@arGeneGroupsVal.table_name}"
    
    puts "#{@arGeneGroupsVal.table_name} table truncated..."
    
    
    @conn.execute \
      "insert into  #{@arGeneGroupsVal.table_name} 
      (gene_id,PROK_GROUP_source_id,prok_group_dest_id,val)
      select  prkg.GENE_ID,
           prkg.PGSRC_ID,
           prkg.PGDST_ID,
           sum(prkg.WEIGHT_TR_PG) 
     from #{@arTrsfPrkgr.table_name} prkg
     group by prkg.PGSRC_ID,
              prkg.PGDST_ID,
              prkg.GENE_ID
      order by prkg.PGSRC_ID,
               prkg.PGDST_ID,
               prkg.GENE_ID"
     
     
    puts "#{@arGeneGroupsVal.table_name} inserted..."
    
    
  end
  
    
  #formating options
  def load_format_options()
    @matr_format = {}
    @matr_format[[:abs]] = ["%1.2f",2]
    @matr_format[[:rel]] = ["%1.3f",3] 
    
    @tt_frm = "%1.6f"

    @tm_frm = "%1.0f"
    @tm_freq_frm = "%1.3f"


    
    
  end
  
  
 
  
 
  #Global statistics
  def calc_mat_stats()
    
     
    @mat_arr_ids = ProkGroup::ids_for_crit(@crit)
    @mat_arr_len = @mat_arr_ids.length
    
    #puts "@mat_arr_ids: #{@mat_arr_ids}, @mat_arr_len: #{@mat_arr_len}"
    

     
     
  end
  
  
  #Local statistics
  def calc_mat_local_stats


    #regular_group_transf_cnt = HgtComIntContin \
    #                           .joins(:hgt_com_int_fragm) \
    #                          .where("bs_val >= ? and hgt_type = ?", @thres, "Regular").count
    #puts "regular_group_transf_cnt: #{regular_group_transf_cnt}"
    
    #use included class provided function
    @leaf_transf_cnt = leaf_transf_cnt()
      
    #Global statistics
    #trivial_group_transf_cnt = HgtComIntContin \
    #                           .joins(:hgt_com_int_fragm) \
    #                          .where("bs_val >= ? and hgt_type = ?", @thres, "Trivial").count
    #puts "regular_group_transf_cnt: #{regular_group_transf_cnt}"
     
             
   
    # group_transf_cnt_per_gene = (group_transf_cnt.to_f/genes_cnt.to_f).to_f
    @mt_all_cnt_per_gene = (@mt_all.to_f/@genes.length.to_f).to_f
        
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

  #calculate value for prok group ids 
  #input in prok group pairs
  #returns also the nb_of genes on which it was calculated
  #         [abs, rel, nb_genes]
  def k_div_nm(prokid_src, prokid_dst)
    
    cor_perc = 100.0
    
    abs = 0.0
    rel = 0.0
    nb_genes = 0.0
    #nb_genes_test = 0.0
    
    
    
    abs_sum = 0.0
    rel_sum = 0.0
    
        
    @genes.each { |gn|
      #init case values
      val_elem = 0.0
      #den = 0.0
          
      #value for gene
      vfg = @hpggv_hsh[[gn.id, prokid_src, prokid_dst]] || 0.0
      
      #x = @hpggv_hsh[[gn.id, prokid_src, prokid_dst]]
      
      #puts "#{gn.id}, #{prokid_src}, #{prokid_dst}, x: #{x}"
      #size of gene source
      sgs = @sg_hsh[[gn.id, prokid_src]] || 0.0
      #size of gene dest
      sgd = @sg_hsh[[gn.id, prokid_dst]] || 0.0
      
      den = (prokid_src == prokid_dst) ? (sgs * (sgd-1) ) / 2 : (sgs * sgd) 
      
      #nb_genes +=1 
      
      if den == 0 
        #puts " null ------------- prokid_src: #{prokid_src}, prokid_dst: #{prokid_dst}, sgs: #{sgs}, sgd: #{sgd}"
        #puts "NULL:  sgs: #{sgs}, sgd: #{sgd} vfg: #{vfg}"
      else
        
        nb_genes +=1 
        
        #for diagonal n * (n-1)
      
        #local variables
        abs_elem =  vfg
        rel_elem = (vfg / den)
        #cummulative
        abs_sum += abs_elem 
        rel_sum += rel_elem
        
        
        #puts "prokid_src: #{prokid_src}, prokid_dst: #{prokid_dst}, gene: #{gn.id},vfg: #{vfg}, sgs: #{sgs}, sgd: #{sgd}, den: #{den}, val_elem: #{val_elem}, val: #{val}"
        if vfg == 0 
          #puts "  vfg #{"%5.2f" % vfg},sgs #{sgs},sgd #{sgd},den #{den},rel_elem #{"%5.2f" % rel_elem.to_s},rel_sum #{"%5.2f" % rel_sum}"
           
          
        else
          #nb_genes_test +=1 
          #puts "! vfg #{"%5.2f" % vfg},sgs #{sgs},sgd #{sgd},den #{den},rel_elem #{"%5.2f" % rel_elem.to_s},rel_sum #{"%5.2f" % rel_sum}"
           
        end
               
        
      end
      
     
          
    }
    
    
    #puts "nb_genes: #{nb_genes} , nb_genes_test: #{nb_genes_test}, 110"
    #puts "nb_genes: #{nb_genes}"
    
    #cnt is the agregate of val over multiple genes
    abs = abs_sum
    rel = (rel_sum * cor_perc ) /  nb_genes unless nb_genes == 0
    #valt = (val * cor_perc ) /  nb_genes_test unless nb_genes_test == 0
    #valr = (val * cor_perc ) /  110
    
    #puts "compare: #{val}, valt: #{valt}, valr: #{valr}"
    
        
    return [abs, rel, nb_genes]
    
  end
  
  #calculate value for prok_groups pair
  #input in prok group ids
  def kN_div_mh(prokid_src, prokid_dst)
    

    nb_genes = 0
    val = 0
        
    @genes.each { |gn|
      #init case values
      val_elem = 0.0
      #den = 0.0
          
      #value for gene
      vfg = @hpggv_hsh[[gn.id, prokid_src, prokid_dst]] || 0.0
      #size of gene dest
      sgd = @sg_hsh[[gn.id, prokid_dst]]
      
      if sgd.nil? 
        #puts " null ------------- prokid_src: #{prokid_src}, prokid_dst: #{prokid_dst}, sgs: #{sgs}, sgd: #{sgd}"
        puts "NULL:  sgd: #{sgd} vfg: #{vfg}"
      else
        
        nb_genes +=1
        val += (vfg / sgd)
           
      end
      
      
          
      #puts "vfg: #{vfg}, sgs: #{sgs}, sgd: #{sgd}, den: #{den}, val_elem: #{val_elem}, val: #{val}"
          
    }
    
    
    puts "nb_genes: #{nb_genes} "
    
    
    #val = (val * @itc_hsh[prokid_src] ) / (@pgtn_hsh[prokid_src] * nb_genes) unless nb_genes == 0
    val = (val * @itc_hsh[prokid_src] ) / (@pgtn_hsh[prokid_src] * 110) unless nb_genes == 0
       
        
    return val
    
    
    
  end
  
  
  #normalizes data for criterium
  def calc_exp_relative_values_for_crit()
    
    #build a Matrix from tabulated data
    @ab_tr_mtx = Matrix.create(@mat_arr_len, @mat_arr_len, 0.0)
    @rl_tr_mtx = Matrix.create(@mat_arr_len, @mat_arr_len, 0.0)
    @gn_tr_mtx = Matrix.create(@mat_arr_len, @mat_arr_len, 0.0)
    
    
    #open output file
    #puts "data_d: #{data_d}, trgr_base_name: #{trgr_base_name}"
 
    Dir.chdir data_d
    csvf_f = data_d + "#{tr_base_name}-all-tab.csv"
     
    csvf = File.new(csvf_f, "w")
    #headers
    csvf.puts "PROK_GROUP_SOURCE_ID,PROK_GROUP_DEST_ID,CNT,CNT_REL,NB_GENES_REL"
    
    
    #arTransferGroup.delete_all
    #puts "#{arTransferGroup.table_name} deleted..."
    
    #insert all prokariotes groups
    # @conn.execute "insert into #{arTransferGroup.table_name}
    #                (prok_group_source_id,prok_group_dest_id,cnt,cnt_rel)
    #                 select pg1.ID,pg2.id,0,0
    #                 from PROK_GROUPS pg1
    #                  cross join PROK_GROUPS pg2
    #                 order by pg1.id,
    #                          pg2.id"

    #puts "inserted all prokariotes groups..."
    
    
    #index all graphics [0.22] or [0..7]
    (0..@mat_arr_len-1).each { |s|
    #(2..2).each { |s|
      #find source prok id 
      prokid_src = @mat_arr_ids[s]
      
      #debugging
     (0..@mat_arr_len-1).each { |d|
      #(0..0).each { |d|
        #(3..3).each { |d|
        prokid_dst = @mat_arr_ids[d]
        
        #puts "src_prok_id:  #{prokid_src}, dst_prok_id: #{prokid_dst}"
        
            
        #cnt = cnt_rel, val = val_rel, nb_genes = nb_genes_rel
        abs, rel, nb_genes =  case @crit 
        when :family
          k_div_nm(prokid_src, prokid_dst) 
          #kN_div_mh(prokid_src,prokid_dst)
        when :habitat
          k_div_nm(prokid_src, prokid_dst)
        end
        
        #debugging
        #puts "#{prokid_src} -> #{prokid_dst}, TOTAL: #{"%5.3f" % rel}, nb_genes #{nb_genes}" #if val !=0
        #puts "Total src: #{prokid_src}, dst: #{prokid_dst}, val: #{val}, nb_genes: #{nb_genes}" #if val !=0
        #puts 
                
        
        #update hgt_par_transfer_groups
        #hptg = arTransferGroup.find_by_prok_group_source_id_and_prok_group_dest_id(prokid_src,prokid_dst)
        #hptg.cnt = abs
        #hptg.cnt_rel = rel
        #hptg.nb_genes_rel = nb_genes
        
        #hptg.save
        
        csvf.puts "#{prokid_src},#{prokid_dst},#{abs},#{rel},#{nb_genes}"
        
        #add data to matrix
        @ab_tr_mtx[s, d] = abs
        @rl_tr_mtx[s, d] = rel
        @gn_tr_mtx[s, d] = nb_genes
     
        
      }
      
    }
    
    csvf.close
    
    
    #export matrices using R
    #connect to Rserve
    c=Rserve::Connection.new

    #assign name on server
    #for later manual reuse from statet
    c.assign("ab_tr_mtx", @ab_tr_mtx)
    c.assign("rl_tr_mtx", @rl_tr_mtx)
    c.assign("gn_tr_mtx", @gn_tr_mtx)

    #export matrices
    str=<<-EOF
library(MASS)

#go to project
setwd("#{data_d}")

#export matrices
write.matrix(format(ab_tr_mtx, scientific=FALSE), file = "#{tr_base_name}-ab-mtx.csv", sep = ",")
write.matrix(format(rl_tr_mtx, scientific=FALSE), file = "#{tr_base_name}-rl-mtx.csv", sep = ",")
write.matrix(format(gn_tr_mtx, scientific=FALSE), file = "#{tr_base_name}-gn-mtx.csv", sep = ",")
    EOF

    print str
    #execute
    c.void_eval str
    c.close
        
    # clear matrix objects
    #they have to be reloaded
    @ab_tr_mtx = nil
    @rl_tr_mtx = nil
    @gn_tr_mtx = nil
    
  end
  
  def load_tr_mtx_for_crit()
      
    #import matrices using R
    #connect to Rserve
    c=Rserve::Connection.new

    
    
    #assign name on server
    #for later manual reuse from statet
    c.assign("ab_tr_mtx", @ab_tr_mtx)
    c.assign("rl_tr_mtx", @rl_tr_mtx)
    c.assign("gn_tr_mtx", @gn_tr_mtx)

    #export matrices
    str=<<-EOF
library(MASS)

#go to project
setwd("#{data_d}")

ab_tr_mtx <- as.matrix(read.csv(file = "#{tr_base_name}-ab-mtx.csv", sep=",", header=FALSE))
rl_tr_mtx <- as.matrix(read.csv(file = "#{tr_base_name}-rl-mtx.csv", sep=",", header=FALSE))
gn_tr_mtx <- as.matrix(read.csv(file = "#{tr_base_name}-gn-mtx.csv", sep=",", header=FALSE))

    EOF
    print str
    #execute
    c.void_eval str

    #recuperate results

    @ab_tr_mtx  = c.eval("ab_tr_mtx").as_matrix
    @rl_tr_mtx  = c.eval("rl_tr_mtx").as_matrix
    @gn_tr_mtx  = c.eval("gn_tr_mtx").as_matrix
        
    puts "@rl_tr_mtx: #{@rl_tr_mtx.inspect}"

  end
  
  
  #disfunctional
  def load_trgr_for_crit_from_csv()
      
    
    
    Dir.chdir data_d
    csvf_f = data_d + "#{trgr_base_name}.csv"
    
    trgr_a = CSV.read(csvf_f)
    heads = trgr_a.shift
    puts "trgr_a: #{trgr_a.inspect}"
    
    #build a Matrix from tabulated data
    @ab_gr_mtx = Matrix.create(@mat_arr_len, @mat_arr_len, 0)
    @tr_gr_mtx = Matrix.create(@mat_arr_len, @mat_arr_len, 0)
    @gn_gr_mtx = Matrix.create(@mat_arr_len, @mat_arr_len, 0)
    
    puts "@ab_gr_mtx: #{@ab_gr_mtx}"
    
    trgr_a.each {|tr|
      
      puts "tr: #{tr}"
      
      @ab_gr_mtx[tr[0].to_i, tr[1].to_i] = tr[2].to_f
      @tr_gr_mtx[tr[0].to_i, tr[1].to_i] = tr[3].to_f
      @gn_gr_mtx[tr[0].to_i, tr[1].to_i] = tr[4].to_f
      
    }
    
    
  end

  
  def calc_rel_values_micro_for_crit
    
    @tr_alt_hsh = {}
    @tr_grp_hsh = {}
    
    #initialize
    #for all genes
        
    @genes.each { |gn|
      #next if gn.id != 174
      
      #initialize versions
      (0..@mat_arr_len-1).each { |s|
        #find source prok id 
        prokid_src = @mat_arr_ids[s]
      
        (0..@mat_arr_len-1).each { |d|
          prokid_dst = @mat_arr_ids[d]
        
          @tr_alt_hsh[[gn.id,prokid_src,prokid_dst]] = 0.0
          #puts "src_prok_id:  #{prokid_src}, dst_prok_id: #{prokid_dst}"
        
        }
      }


      prokid_min = @mat_arr_ids.min
      prokid_max = @mat_arr_ids.max
    
      puts "prokid_min: #{prokid_min}, prokid_max: #{prokid_max}"
      

      
      puts gn.inspect
      
 
      #calculate transfer probabilities
      
      #fetch all transfers for gene
      sql = "select ns_src.TAXON_ID || '' as tid_src,
                  ns_dst.taxon_id || '' as tid_dst,
                  ht.WEIGHT
           from HGT_COM_INT_TRANSFERS ht
            join HGT_COM_INT_FRAGMS hcf on hcf.ID = ht.HGT_COM_INT_FRAGM_ID  
            join NCBI_SEQS ns_src on ns_src.id = ht.SOURCE_ID
            join NCBI_SEQS ns_dst on ns_dst.id = ht.DEST_ID
           where gene_id = #{gn.id}"
   
      trsfs = @conn.select_all sql
      
  
      trsfs.each {|tr|
        
        tid_src = tr["tid_src"]
        tid_dst = tr["tid_dst"]
        wght_tr = tr["weight"].to_f
     
        puts "tid_src: #{tid_src}, tid_dst: #{tid_dst}, wght_tr: #{wght_tr}"
        
        #fetch proc_groups

        pgids_src = TaxonGroup.select("prok_group_id") \
          .where("prok_group_id between ? and ? and taxon_id = ?", prokid_min, prokid_max, tid_src.to_i) \
          .collect{|x| x.prok_group_id}
             
        pgids_dst = TaxonGroup.select("prok_group_id") \
          .where("prok_group_id between ? and ? and taxon_id = ?", prokid_min, prokid_max, tid_dst.to_i) \
          .collect{|x| x.prok_group_id}
        
        #puts "pgids_src: #{pgids_src.inspect}, pgids_dst: #{pgids_dst.inspect} "
        
        
        #linearize transfer
        #gives alternatives
        tr_nb = pgids_src.size * pgids_dst.size
        pgids_src.each {|src|
          pgids_dst.each {|dst|

            val_one_alt = 0.0
            wght_alt = 1/tr_nb.to_f
            #puts "src: #{src}, dst: #{dst}, wght_tr: #{wght_alt}"
         
            #for each src dst pair calculate number of ncbi_seq_id
            #for each prok_group and the difference
          
            #source members
            sql = "select gbs.NCBI_SEQ_ID
                 from GENE_BLO_SEQS gbs
                  join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
                  join TAXON_GROUPS tg on tg.TAXON_ID = ns.TAXON_ID
                  join PROK_GROUPS pg on pg.ID = tg.PROK_GROUP_ID
                 where gbs.GENE_ID = #{gn.id} and
                       pg.ID = #{src}"
   
            ncbi_seqs_src_arr = @conn.select_all(sql).collect{|x| x["ncbi_seq_id"]}
            ncbi_seqs_src_cnt = ncbi_seqs_src_arr.length().to_f
            #puts "ncbi_seqs_src_arr: #{ncbi_seqs_src_arr.inspect}, ncbi_seqs_src_cnt: #{ncbi_seqs_src_cnt}"

            #dest members
            sql = "select gbs.NCBI_SEQ_ID
                 from GENE_BLO_SEQS gbs
                  join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
                  join TAXON_GROUPS tg on tg.TAXON_ID = ns.TAXON_ID
                  join PROK_GROUPS pg on pg.ID = tg.PROK_GROUP_ID
                 where gbs.GENE_ID = #{gn.id} and
                       pg.ID = #{dst}"
   
            ncbi_seqs_dst_arr = @conn.select_all(sql).collect{|x| x["ncbi_seq_id"]}
            ncbi_seqs_dst_cnt = ncbi_seqs_dst_arr.length().to_f
            #puts "ncbi_seqs_dst_arr: #{ncbi_seqs_dst_arr.inspect}, ncbi_seqs_dst_cnt: #{ncbi_seqs_dst_cnt}"

            #intersect members
            
            ncbi_seqs_isc_arr = ncbi_seqs_src_arr & ncbi_seqs_dst_arr
            ncbi_seqs_isc_cnt = ncbi_seqs_isc_arr.length().to_f
            #puts "ncbi_seqs_isc_arr: #{ncbi_seqs_isc_arr.inspect}, ncbi_seqs_isc_cnt: #{ncbi_seqs_isc_cnt}"

            #count only one
            #val_one_alt = (wght_tr * wght_alt) / ((ncbi_seqs_src_cnt * ncbi_seqs_dst_cnt) - ncbi_seqs_isc_cnt)
            
            #count multiple times
            val_one_alt = (wght_tr ) / ((ncbi_seqs_src_cnt * ncbi_seqs_dst_cnt) - ncbi_seqs_isc_cnt)
            val_one_alt *=2 if src == dst
            
            #puts "val_one_alt: #{val_one_alt}"
            
            @tr_alt_hsh[[gn.id,src,dst]] += val_one_alt
            
          }
        }
        #puts "@tr_alt_hsh[[gn.id,src,dst]]: #{@tr_alt_hsh.inspect}" 
      
      
     
          
      }
    
    } 
    

    #for all genes
        
      
    #initialize versions
    (0..@mat_arr_len-1).each { |s|
      #find source prok id 
      prokid_src = @mat_arr_ids[s]
      
      (0..@mat_arr_len-1).each { |d|
        prokid_dst = @mat_arr_ids[d]
        
        
        @tr_grp_hsh[[prokid_src,prokid_dst]] = 0.0
         
        nb_genes = 0.0
        @genes.each { |gn|
          #next if gn.id != 174
          val = @tr_alt_hsh[[gn.id,prokid_src,prokid_dst]]
          nb_genes +=1 if val != 0
          @tr_grp_hsh[[prokid_src,prokid_dst]] += val  
                
        }
         
         
        #normalize dynamic
        #puts "dynamic nb_genes: #{nb_genes}"
        @tr_grp_hsh[[prokid_src,prokid_dst]] *= (100 / nb_genes) if nb_genes != 0
         
          
        #normalize static
        #nb_genes=110.0
        #puts "static nb_genes: #{nb_genes}"
        #@tr_grp_hsh[[prokid_src,prokid_dst]] *= (100 / nb_genes)
          
         
         
         
         
         
         
         
        
      }
   
    }
      
    puts "@tr_grp_hsh: #{@tr_grp_hsh.inspect}"
    
    #average
    avg_grp_arr = @tr_grp_hsh.values.collect! { |x| x if x != 0 }.compact
    puts "avg_grp_arr: #{avg_grp_arr.inspect}"
     
    avg_grp_sum = avg_grp_arr.sum
    #normalize dynamic
    avg_grp_cnt = avg_grp_arr.length.to_f
      
    #normalize static
    avg_grp_cnt = @mat_arr_ids.length.to_f
      
      
    avg_grp_val = avg_grp_sum / avg_grp_cnt
    puts "avg_grp_sum: #{avg_grp_sum}, avg_grp_cnt: #{avg_grp_cnt}, avg_grp_val: #{avg_grp_val}"
      
    #update hgt_par_transfer_groups
    (0..@mat_arr_len-1).each { |s|
      #find source prok id 
      prokid_src = @mat_arr_ids[s]
      
      (0..@mat_arr_len-1).each { |d|
        prokid_dst = @mat_arr_ids[d]
        
        hptg = arTransferGroup.find_by_prok_group_source_id_and_prok_group_dest_id(prokid_src,prokid_dst)
        hptg.cnt_rel = @tr_grp_hsh[[prokid_src,prokid_dst]]  
        hptg.save
     
        
      }
    }
    
      
    
    
    
  end
  

   
  #central values
  def calc_exp_transf_gr_mat_data 

    @ab_tr_mat = Array.new(@mat_arr_len) { Array.new(@mat_arr_len) }
    @rl_tr_mat = Array.new(@mat_arr_len) { Array.new(@mat_arr_len) }
    @gn_tr_mat = Array.new(@mat_arr_len) { Array.new(@mat_arr_len) }
    

    #will export matrix core data file
    dat_f = File.new("#{exp_d(:dat)}/#{hm_base_name}.dat", "w")    
    
    #for each row
    (0..@mat_arr_len-1).each { |s|

      #y=ProkGroup.find_by_order_id(s).id
      y = @mat_arr_ids[s]
        
      #puts "y: #{y}"
      
      #name of the group
      pgy = ProkGroup.find(y)
      

      #puts "s: #{s}"

      (0..@mat_arr_len-1).each { |d|
        #x=ProkGroup.find_by_order_id(d).id
        x=@mat_arr_ids[d]
        
        pgx = ProkGroup.find(x)           

        #recomb_transfer_groups
        #htg = arTransferGroup.find_by_prok_group_source_id_and_prok_group_dest_id(y,x)

        # puts "d: #{d}"
          
        #puts "htg: #{htg.inspect}"

        hgt_cnt = case @calc_type
        when :abs 
          @ab_tr_mtx[s,d]    
        when :rel 
          @rl_tr_mtx[s,d]
          
        end
               
         
        #puts "hgt_cnt: #{hgt_cnt}"

        #put cell value
        @rl_tr_mat[s][d] = hgt_cnt
        #@tr_gr_mat[s][d] = htg.cnt
        #@tr_gr_mat[s][d] = htg.nb_genes_rel
        
        #absolute
        @ab_tr_mat[s][d] = @ab_tr_mtx[s,d]
        #put nb_genes value
        @gn_tr_mat[s][d] = @gn_tr_mtx[s,d]

        cell = "#{s.to_s}\t\"#{pgy.name}\"\t#{d.to_s}\t\"#{pgx.name}\"\t"
        cell += "%5.4f" % hgt_cnt
        dat_f.puts cell

         
      }
         
    }

    dat_f.close

    #puts "@tr_gr_mat: #{@tr_gr_mat.inspect}"
    
    


  end
  
 

  #sums for border graphics
  def calc_transf_gr_mat_sums 
      
    puts "in calc_transf_gr_mat_sums...."
    sleep 5
    
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
    (0..@mat_arr_len-1).each do |s|

      @mt_ysums_inter[s] = 0
      @mt_ysums_intra[s] = 0
      
      #sum rows
      @mt_ysums[s] = 0.0
      ab_tot = 0.0
      gn_tot = 0.0
      
      (0..@mat_arr_len-1).each do |d|
        @mt_ysums_inter[s] += @rl_tr_mat[s][d] if s != d
        @mt_ysums_intra[s] += @rl_tr_mat[s][d] if s == d
        #
        ab_tot += @ab_tr_mat[s][d]
        gn_tot += @gn_tr_mat[s][d]
        @mt_ysums[s] += @ab_tr_mat[s][d] * @gn_tr_mat[s][d]
        
        @mt_all += @rl_tr_mat[s][d]
      end
      #normalize
      @mt_ysums[s] *= 100/(ab_tot*gn_tot) if (ab_tot*gn_tot) !=0
             
      #puts "@mt_ysums[#{s}]: #{@mt_ysums[s]}"
      #puts "@mt_ysums_inter[#{s}]: #{@mt_ysums_inter[s]}"
      #puts "@mt_ysums_intra[#{s}]: #{@mt_ysums_intra[s]}"
    end

  

    #calculate xsums
    (0..@mat_arr_len-1).each do |d|
      @mt_xsums_inter[d] = 0
      @mt_xsums_intra[d] = 0
      
      #sum columns
      @mt_xsums[d] = 0.0
      ab_tot = 0.0
      gn_tot = 0.0
      #
      (0..@mat_arr_len-1).each do |s|
        @mt_xsums_inter[d] += @rl_tr_mat[s][d] if s != d
        @mt_xsums_intra[d] += @rl_tr_mat[s][d] if s == d
        #
        ab_tot += @ab_tr_mat[s][d]
        gn_tot += @gn_tr_mat[s][d]
        @mt_xsums[d] += @ab_tr_mat[s][d] * @gn_tr_mat[s][d]
      
      end
      #normalize
      @mt_xsums[d] *= 100/(ab_tot*gn_tot) if (ab_tot*gn_tot) !=0
      
     
            
      #
      
 
      #puts "@mt_xsums[#{d}]: #{@mt_xsums[d]}"
      #puts "@mt_xsums_inter[#{d}]: #{@mt_xsums_inter[d]}"
      #puts "@mt_xsums_intra[#{d}]: #{@mt_xsums_intra[d]}"
   
     
        
    end

    #calculate maximum value of the relative matrix 
    # for underligning values in xls.
    mt_max_arr = []
    idx_high_support_arr = []
    idx_low_support_arr = []
    
    (0..@mat_arr_len-1).each do |d|
     (0..@mat_arr_len-1).each do |s|
       if @gn_tr_mat[s][d] > 6
         idx_high_support_arr << [s,d,@rl_tr_mat[s][d]]
       else
         idx_low_support_arr << [s,d,@rl_tr_mat[s][d]]
       end
       
       mt_max_arr << @rl_tr_mat[s][d]
      end
    end
    
    #keep in mind the indexes of the top 10 heigh support and all the low support indexes and values
    @high_supp_arr= idx_high_support_arr.sort { |a, b| a[2] <=> b[2] }.map { |i| [i[0],i[1],i[2]] }.last(10)
    @low_supp_arr = idx_low_support_arr.select { |a| a[2] != 0.0 }.sort { |a, b| a[2] <=> b[2] }.map { |i| [i[0],i[1],i[2]] }.last(10)
    #puts "idx_high_support_arr: #{idx_high_support_arr}"
    #puts "idx_low_support_arr: #{idx_low_support_arr}"
    #puts "high_supp_arr: #{high_supp_arr}"
    #puts "low_supp_arr: #{low_supp_arr}"
    
      
    
    
    #puts "mt_max_arr: #{mt_max_arr}"

    #first values will be underlined in xls tables
    @highlight_thres = mt_max_arr.sort.last(10).min

    
    
    #exit(0)
    
    #calculate lateral percentages
    #
    (0..@mat_arr_len-1).each do |i|
      #right values
      @mt_yperc_1[i] = @mt_ysums_inter[i] / (@mt_ysums_inter[i] + @mt_xsums_inter[i]) * 100
      @mt_yperc_2[i] = @mt_xsums_inter[i] / (@mt_ysums_inter[i] + @mt_xsums_inter[i]) * 100


      #bottom values * 2 intragroup sums
      #@mt_xperc_1[i] = (@mt_ysums_intra[i] + @mt_xsums_intra[i]) / (@mt_ysums_intra[i] + @mt_xsums_intra[i] + @mt_ysums_inter[i] + @mt_xsums_inter[i]) * 100
      #@mt_xperc_2[i] = (@mt_ysums_inter[i] + @mt_xsums_inter[i]) / (@mt_ysums_intra[i] + @mt_xsums_intra[i] + @mt_ysums_inter[i] + @mt_xsums_inter[i]) * 100
      
      # only one time intragroup sums
      #@mt_ysums_intra[i] = @mt_xsums_intra[i]
      @mt_xperc_1[i] = (@mt_ysums_intra[i] ) / (@mt_ysums_intra[i] + @mt_ysums_inter[i] + @mt_xsums_inter[i]) * 100
      @mt_xperc_2[i] = (@mt_ysums_inter[i] + @mt_xsums_inter[i]) / (@mt_ysums_intra[i] + @mt_ysums_inter[i] + @mt_xsums_inter[i]) * 100

      
    end
     

    #right scale limit
    @mt_ymax_perc = 100
    #down scale limit
    @mt_xmax_perc = 100
     


  

    #export lateral graphicdata        
    daty_f = File.new("#{exp_d(:dat)}/#{hm_base_name}.daty", "w")
    (0..@mat_arr_len-1).each { |s|
     
      daty_f.puts "#{s}\t#{"%1.0f" % @mt_yperc_1[s]}\t#{ "%1.0f" % @mt_yperc_2[s]}"

    }
 
    daty_f.close

    #export bottom graphicdata
    datx_f = File.new("#{exp_d(:dat)}/#{hm_base_name}.datx", "w")

    (0..@mat_arr_len-1).each { |d|

      datx_f.puts "#{d}\t#{"%1.0f" % @mt_xperc_1[d]}\t#{"%1.0f" % @mt_xperc_2[d]}"

    }

    datx_f.close
    

  end
  
  
 
  #tex table 
  def export_transfer_groups_matrix_tex
    
    #extract papersize
    #from including class procedure
    calc_custom_config()
    
    puts "@config: #{@config.inspect}"
    
     
    @matr_format = {}
    @matr_format[[:abs]] = ["%1.2f",2]
    @matr_format[[:rel]] = ["%1.3f",3] 
    
    def cell_frm_f(factor)
      return Proc.new {|n| 
        str =  "%5.3f" % ( (n * 10 ** factor).ceil.to_f / 10 ** factor ) 
        str.strip()
      }
    end
 
    mat_frm = @matr_format[[@calc_type]]
    cell_frm = mat_frm[0]
    cell_lambda = cell_frm_f(mat_frm[1])
      
    
    
    mt_frm = @matr_format[[@calc_type]]
    
    #puts "dims: #{dims}, #{dims.nil?}"
    
    dims = (@config.nil?) ? [410,140] : [@config[0],@config[1]]
    
    dim_min = dims[0]
    dim_max = dims[1]
    
    #puts "min: #{dim_min}, max: #{dim_max}"
    
    
    
    
    Dir.chdir exp_d
   
    
    #clean old
    ['tex','log','out','aux','pdf'].each {|ext|
      cmd = "rm -fr #{mt_base_name}.#{ext}"
      puts cmd; `#{cmd}`
      
    }
    
    
    #some texts
    
    case @stage 
    when "hgt-par"
      #@stage_txt = "\\textbf{Partial} gene transfers"
      @stage_txt = "Partial gene transfers"
    when "hgt-com"
      @stage_txt = "Complete gene transfers"
    when "recomb"
      @stage_txt = "Recombinations"
    end
    
    case @phylo_prog
    when "phyml"
      #@phylo_prog_txt = ", calculated with \\textbf{HGT Transfer} using \\textbf{PhyML}"
      @phylo_prog_txt = ", inferred using HGT-Detection algorithm"
      @gene_trees_txt = " Gene trees were inferred using PhyML"
      
      @thres_txt = ", with a bootstrap threshold of #{@thres} \\%"
    when "raxml"
      @phylo_prog_txt = ", inferred using HGT-Detection algorithm"
      @gene_trees_txt = " Gene trees were inferred using RAxML"
      
      @thres_txt = ", with a bootstrap threshold of #{@thres} \\%"
    when "geneconv"
      @phylo_prog_txt = ", inferred by RDP4 using Geneconv algorithm"
      @gene_trees_txt = ""
      @thres_txt = ""
    end
    
  
    tex = File.new("#{mt_base_name}.tex", "w")

    
    tex.puts '\documentclass[]{article}'
    tex.puts '\usepackage[vcentering,dvips,top=5mm, bottom=5mm, left=5mm, right=5mm]{geometry}'
    #double escape char on this line with parameters
    tex.puts "\\geometry{papersize={#{dim_min}mm,#{dim_max}mm}}"
    tex.puts '\pagestyle {empty}'
    tex.puts '\usepackage{graphicx}'
    tex.puts '\usepackage{subfig}'
    tex.puts '\usepackage{colortbl}'
    tex.puts '\usepackage{arydshln}'
    tex.puts '\usepackage{caption}'

    tex.puts '\captionsetup[table]{position=top, justification=justified, labelformat=empty}'

    tex.puts '\begin{document}'

    tex.puts '\begin{table}'

     
    cap = ""
    cap += "#{@stage_txt}#{@phylo_prog_txt}#{@thres_txt}."
    #cap += "\\\\" 
    cap += "#{@gene_trees_txt}."
    #cap += "\\\\" 
    #cap += "Average number of transfers total: \\textbf{#{"%5.2f" % @mt_all}}."
    #cap += "Leaf transfers: \\textbf{#{@leaf_transf_cnt}}. \n"
    cap += " Number of multiple sequence alignments (MSA) analyzed: #{@genes_cnt}."
    cap += " Number of species analyzed: #{@taxons_cnt}."
    #cap += "\\\\"
    #cap += "Average number of transfers per gene: \\textbf{#{"%5.2f" % @mt_all_cnt_per_gene}}. \n"
    cap += " Intragroup transfers are underligned."
    #cap += "\\\\"
    #cap += "Values over \\textbf{#{"%3.0f" % (@highlight_thres *100)}\\%} of the average number of transfers per gene, are represented in boldface."
    cap += " The most frequent HGTs are represented in bold."


    tex.puts "\\caption{#{cap}}"  

      

   
    row = '\begin{tabular}{'
    row += 'l'
    
    (0..@mat_arr_len-1 + 2).each { |x|  row += 'c' }
    row += '}'
    tex.puts row

    row = 'Group Name & Source$\backslash$Destination & '
    (0..@mat_arr_len-1).each { |x|
      row += (x+1).to_s
      row += ' & '
    }
    row += 'Total \\\\'

    tex.puts row

           
    #for each row
    (0..@mat_arr_len-1).each { |s|

      y = @mat_arr_ids[s]
        
      #name of the group
      pg = ProkGroup.find(y)
      
     
      
      #find nb of taxons in group
      #pgtn = TaxonGroup.joins(:ncbi_seqs => :gene_blo_seq) \
      #  .where("prok_group_id=?",y) \
      #  .group("prok_group_id") \
      #  .select("count(distinct TAXON_ID) as cnt")[0]
      pgtn = pgtn_hsh[y]
        
      #:debug, :info, :warn, :error, and :fatal,
      #0 to 4
 
      #find nb of sequences in group
      pgsn = pgsn_hsh[y]

      row = "#{pg.name}(#{pgtn}),[#{pgsn}] & "
      row += (s+1).to_s 
      row += ' & '

      (0..@mat_arr_len-1).each { |d|
        
        x = @mat_arr_ids[d]
                   
        hgt_cnt = case @calc_type
        when :abs
          @rl_tr_mat[s][d]
        when :rel
          @rl_tr_mat[s][d] 
        end
          
        #truncate output to one decimal         
        #hgt_cnt== 0  ? cell = "" : cell = mt_frm % hgt_cnt 
        x = cell_frm % cell_lambda.call(hgt_cnt)
        #puts "x: #{x.inspect}, hgt_cnt: #{hgt_cnt}"
        hgt_cnt== 0  ? cell = "" : cell = cell_frm % cell_lambda.call(hgt_cnt)
         
  
      
        #italics on diagonal
        cell = '\underline{' + cell + '}' if s == d
        cell = '\textbf{' + cell + '}' if hgt_cnt >= (@highlight_thres)
        row += cell
        row += ' & '
         
      }
         
      # y sums
      #row += mt_frm % @mt_ysums[s]
      row += cell_frm % cell_lambda.call(@mt_ysums[s])
      
      row += " \\\\"
      tex.puts row

    }
       
    #x totals
    row = ' & Total & '
    (0..@mat_arr_len-1).each { |t|
      x = @mat_arr_ids[t]
      
      #xsums    
      #row += "%5.4f" % @mt_xsums[t]
      row += cell_frm % cell_lambda.call(@mt_xsums[t])
      row += ' & '
    }
    #Grand Total
        
    #row += mt_frm % @mt_all
    
    #we do not show it anymore
    #row += cell_frm % cell_lambda.call(@mt_all)
    row += ' \\\\'

    tex.puts row
       
   

     
    tex.puts '\end{tabular}'
    tex.puts '\end{table}'
    tex.puts '\end{document}'
    tex.close

    #compile pdfs
    cmd = "pdflatex #{mt_base_name}.tex"
    puts cmd; `#{cmd}`
    #convert
    cmd = "convert -density 300 #{mt_base_name}.pdf -antialias #{mt_base_name}.png"
    puts cmd; `#{cmd}`

    ['pdf','png'].each {|ext|
      cmd = "mv #{mt_base_name}.#{ext} ./#{ext}/"
      puts cmd; `#{cmd}`

    }

    #cleanup    
    ['tex','log','out','aux'].each {|ext|
      cmd = "rm -fr #{mt_base_name}.#{ext}"
      puts cmd; `#{cmd}`
    }
    
   


  end
  
  #initialize cache
  def xls_cached_style_ini
    #local fonts and style cache
    @xls_ca_un_cl = {}  
  end
  
  def xls_cached_style_fin
    @xls_ca_un_cl = nil
  end
  
  #2 underlines, 3 colors
  #fixed font,size,alignment
  def xls_cached_style(workbook, underline, color)
    
    #uses class cache @xls_ca_un_cl
    
    key = [underline,color]
    if @xls_ca_un_cl.key?(key)
      #get font and style from cache
      fn_dyn,cs_dyn = @xls_ca_un_cl[key]
    else
      #create new font and style
      fn_dyn = workbook.createFont()
      fn_dyn.setFontHeightInPoints(6)
      fn_dyn.setFontName("Times New Roman")
      #
      fn_dyn.setUnderline(underline)
      fn_dyn.setColor(color)
      #styles
      cs_dyn = workbook.createCellStyle()
      cs_dyn.setAlignment(JavaCellStyle::ALIGN_RIGHT)
      cs_dyn.setFont(fn_dyn)
      #set font and style to cache
      @xls_ca_un_cl[key] = [fn_dyn,cs_dyn]
    end
    
    #puts "cache length: #{@xls_ca_un_cl.length}"
    [fn_dyn,cs_dyn]   
    
  end

  
  #xls table
  def export_transfer_groups_matrix_xls

    #extract papersize
    #from including class procedure
    calc_custom_config()

    puts "@config: #{@config.inspect}"


    @matr_format = {}
    @matr_format[[:abs]] = ["%1.2f",2]
    @matr_format[[:rel]] = ["%1.3f",3]


    def cell_frm_f(factor)
      Proc.new {|n|
         
        #puts "n: #{n}, factor: #{factor}"
        if n.nan?
          val = 0.0
        else           
          val = ((n * 10 ** factor).ceil.to_f / 10 ** factor)
        end
        
        #puts "val: #{val}"
        
        str = "%5.3f" % val
        str = str.strip()
        
      }  
      
      
    end

    mat_frm = @matr_format[[@calc_type]]
    cell_frm = mat_frm[0]
    cell_lambda = cell_frm_f(mat_frm[1])

    mt_frm = @matr_format[[@calc_type]]

    Dir.chdir exp_d()
    puts "pwd #{Dir.pwd}"

      
    wb_fname = exp_d(:xls) + "#{mt_base_name}.xls"
    puts "wb_fname: #{wb_fname}"
    
   
    wb = JavaHSSFWorkbook.new
    xls_cached_style_ini
    
    fileOut = JavaFileOutputStream.new(wb_fname.to_s)

    #
    sheet = wb.createSheet("mt")

    ymin = 0

    #row
    rw_height = 12
    fn_height = 6
    cl_width_fact = 22

    

    #fonts
    fn_reg = wb.createFont()
    fn_reg.setFontHeightInPoints(fn_height)
    fn_reg.setFontName("Times New Roman");
    #fn_tnr.setItalic(true);
    #fn_tnr.setStrikeout(true);

    fn_name = wb.createFont()
    fn_name.setFontHeightInPoints(fn_reg.getFontHeightInPoints())
    fn_name.setFontName(fn_reg.getFontName)
    fn_name.setItalic(true)
    fn_name.setBoldweight(JavaFont::BOLDWEIGHT_BOLD)
     
    #
    #fn_bld.setBoldweight(fn_reg.getBoldweight)

    #Fonts are set into a style so create a new one to use.
    #CellStyle style = wb.createCellStyle();
    #style.setFont(font);

    #styles
    cs_names = wb.createCellStyle()
    cs_names.setAlignment(JavaCellStyle::ALIGN_LEFT)
    cs_names.setFont(fn_reg)
    #cellStyle.setVerticalAlignment(valign);
    cs_index = wb.createCellStyle()
    cs_index.setAlignment(JavaCellStyle::ALIGN_CENTER)
    cs_index.setFont(fn_reg)

    cs_tot = wb.createCellStyle()
    cs_tot.setAlignment(JavaCellStyle::ALIGN_RIGHT)
    cs_tot.setFont(fn_reg)

    #header (first row)
    row = sheet.createRow(ymin)
    row.setHeightInPoints(rw_height)

    cel = row.createCell(0)
    cel.setCellValue("Group Name")
    cel.setCellStyle(cs_index)

    cel = row.createCell(1)
    cel.setCellValue("\\")
    cel.setCellStyle(cs_index)

    (0..@mat_arr_len-1).each { |x|
      cel = row.createCell(x+2)
      cel.setCellValue(x+1)
      cel.setCellStyle(cs_index)

    }
    
    cel = row.createCell(@mat_arr_len-1+2 +1 )
    cel.setCellValue("Out")
    cel.setCellStyle(cs_index)

    

    # row by row
    (0..@mat_arr_len-1).each { |s|

      row = sheet.createRow(ymin+1+s)
      row.setHeightInPoints(rw_height)

    


      y = @mat_arr_ids[s]

      #name of the group
      pg = ProkGroup.find(y)

      pgtn = pgtn_hsh[y]

      #find nb of sequences in group
      pgsn = pgsn_hsh[y]

      #names
      #create a cell style and assign the first font to it
      cl_name = row.createCell(0)
      cl_name.setCellStyle(cs_names);
      

      #rich text consists of one run overriding the cell style
      name_group = "#{pg.name}(#{pgtn.round()}),[#{pgsn.round()}]"
    
      richString = JavaHSSFRichTextString.new(name_group)
      richString.applyFont( 0, pg.name.length, fn_name );
      richString.applyFont( pg.name.length(), name_group.length(), fn_reg );
      cl_name.setCellValue( richString );
      
      #cl_name.setCellStyle(cs_names)
      
      #index
      cel = row.createCell(1)
      cel.setCellValue((s+1).to_f)
      cel.setCellStyle(cs_index)

      (0..@mat_arr_len-1).each { |d|


        x = @mat_arr_ids[d]

        hgt_cnt = case @calc_type
        when :abs
          @ab_tr_mat[s][d]
        when :rel
          @rl_tr_mat[s][d]
          #@ab_tr_mat[s][d]
          #@gn_tr_mat[s][d]
        end

        #truncate output to one decimal
        #hgt_cnt== 0  ? cell = "" : cell = mt_frm % hgt_cnt
        x = cell_frm % cell_lambda.call(hgt_cnt)
        #puts "x: #{x.inspect}, hgt_cnt: #{hgt_cnt}"
        #if hgt_cnt == 0
        
        #if @gn_tr_mat[s][d] == 0
        if true
        #empty cells 
          #cell = ""
          #cel_val = cell_frm % cell_lambda.call(0.0)
          #cel = row.createCell(2+d)
          #cel.setCellValue(cel_val.to_f)

        #else
          cel_val = cell_frm % cell_lambda.call(hgt_cnt)
          cel = row.createCell(2+d)
          cel.setCellValue(cel_val.to_f)

          #fn_dyn = wb.createFont()
          #fn_dyn.setFontHeightInPoints(fn_reg.getFontHeightInPoints())
          #fn_dyn.setFontName(fn_reg.getFontName)

          #underline diagonal
          if s == d
            #fn_dyn.setUnderline(JavaFont::U_SINGLE)
            fn_underline = JavaFont::U_SINGLE
          else
            #fn_dyn.setUnderline(JavaFont::U_NONE)
            fn_underline = JavaFont::U_NONE
          end

          #red color for heigh values
          #if hgt_cnt >= (@highlight_thres) # @mt_all_cnt_per_gene
          if @high_supp_arr.find{|a| a[0] == s and a[1] == d}
          
            #fn_dyn.setBoldweight(JavaFont::BOLDWEIGHT_BOLD)

            #blue_idx = JavaHSSFColor::BLUE.index
            #fn_dyn.setColor(JavaHSSFColor::RED.index)
            fn_color = JavaHSSFColor::RED.index
          elsif @low_supp_arr.find{|a| a[0] == s and a[1] == d}
            fn_color = JavaHSSFColor::GREY_50_PERCENT.index
          else
            #fn_dyn.setBoldweight(JavaFont::BOLDWEIGHT_NORMAL)
            #fn_dyn.setColor(JavaHSSFColor::BLUE.index)
            fn_color = JavaHSSFColor::BLUE.index 
          end
         
          #if @gn_tr_mat[s][d] < self.gn_mt_min_th
            #fn_dyn.setColor(JavaHSSFColor::GREY_40_PERCENT.index)
            #fn_color = JavaHSSFColor::GREY_40_PERCENT.index
          #end

          #cs_dyn = wb.createCellStyle();
          #cs_dyn.setAlignment(JavaCellStyle::ALIGN_RIGHT)
          #cs_dyn.setFont(fn_dyn)
          fn_dyn, cs_dyn = xls_cached_style(wb,fn_underline,fn_color)
          cel.setCellStyle(cs_dyn)
          

        end
        
      }


      # y sums
      #cel_val = cell_frm % cell_lambda.call(@mt_xsums[s]) 
      cel_val = cell_frm % cell_lambda.call(@tt_xsums_cond[s]) 
      cel = row.createCell(2+ @mat_arr_len-1 +1)
      cel.setCellValue(cel_val.to_f)
      #cel.setCellStyle(cs_tot)
      fn_underline = JavaFont::U_NONE
      fn_color = JavaHSSFColor::GREEN.index
      fn_dyn, cs_dyn = xls_cached_style(wb,fn_underline,fn_color)
      cel.setCellStyle(cs_dyn)

      
    }

    #x totals
    #footer (last row)
    row = sheet.createRow(ymin + @mat_arr_len-1 +2)
    row.setHeightInPoints(rw_height)

    cel = row.createCell(1)
    cel.setCellValue("Inc")
    cel.setCellStyle(cs_index)

    
    (0..@mat_arr_len-1).each { |t|
      x = @mat_arr_ids[t]
      #x sums
      #cel_val = cell_frm % cell_lambda.call(@mt_ysums[t])
      cel_val = cell_frm % cell_lambda.call(@tt_ysums_cond[t])
      cel = row.createCell(2 + t)
      cel.setCellValue(cel_val.to_f)
      #cel.setCellStyle(cs_tot)
      
      fn_underline = JavaFont::U_NONE
      fn_color = JavaHSSFColor::DARK_GREEN.index
      fn_dyn, cs_dyn = xls_cached_style(wb,fn_underline,fn_color)
      cel.setCellStyle(cs_dyn)


    }
    #grand total 
    cel_val = cell_frm % cell_lambda.call(@mt_all)
    cel = row.createCell(2 + @mat_arr_len)
    cel.setCellValue(cel_val.to_f)
    #cel.setCellStyle(cs_tot)
    fn_underline = JavaFont::U_NONE
    fn_color = JavaHSSFColor::VIOLET.index
    fn_dyn, cs_dyn = xls_cached_style(wb,fn_underline,fn_color)
    cel.setCellStyle(cs_dyn)

    
    

    #width
    sheet.setColumnWidth(0, cl_width_fact * 40 * fn_height)
    sheet.setColumnWidth(1, cl_width_fact * 5 * fn_height)

    (0..@mat_arr_len).each { |t|
      #+1 for bold
      sheet.setColumnWidth(2+t, cl_width_fact * 7 * fn_height)

    }

    
    

    #row.createCell(1).setCellValue(new Date());
    #row.createCell(2).setCellValue(Calendar.getInstance());
    
    #row.createCell(4).setCellValue(true)
    #row.createCell(5).setCellType(Cell.CELL_TYPE_ERROR);

    # Write the output to a file
      

    #
    wb.write(fileOut)
    fileOut.close()
    xls_cached_style_fin
     
  end

  
  #tex table 
  def export_transfer_groups_totals_csv
    
    #extract papersize
    #from including class procedure
    calc_custom_config()
    
    puts "@config: #{@config.inspect}"
    
     
    @matr_format = {}
    @matr_format[[:abs]] = ["%1.2f",2]
    @matr_format[[:rel]] = ["%1.3f",3] 
    
    def cell_frm_f(factor)
      return Proc.new {|n| 
        str =  "%5.3f" % ( (n * 10 ** factor).ceil.to_f / 10 ** factor ) 
        str.strip()
      }
    end
 
    mat_frm = @matr_format[[@calc_type]]
    cell_frm = mat_frm[0]
    cell_lambda = cell_frm_f(mat_frm[1])
      
    

    
   
    
    mt_frm = @matr_format[[@calc_type]]
    

    
    #puts "min: #{dim_min}, max: #{dim_max}"
    
    
    

    Dir.chdir "#{AppConfig.db_exports_dir}/#{@stage}/#{@crit}/#{@calc_type}"
    
    
    
    #clean old
    #['tex','log','out','aux','pdf'].each {|ext|
    #  cmd = "rm -fr #{@tt_base_name}.#{ext}"
    #  puts cmd; `#{cmd}`
    #  
    #}
    
    
    
    puts "@tt_base_name: #{tt_base_name}"
    csvf = File.new("#{tt_base_name}.csv", "w")
    
    #headers
    csvf.puts "NAME,XTOT,YTOT"
           
    #for each row
    (0..@mat_arr_len-1).each { |a|
      
      b = @mat_arr_ids[a]
        
      #name of the group
      pg = ProkGroup.find(b)

       
      valx = cell_frm % cell_lambda.call(@mt_xsums[a])
      valy = cell_frm % cell_lambda.call(@mt_ysums[a])
      csvf.puts "#{pg.name},#{valx},#{valy}"
      

    }
   
    
    csvf.close

    #compile pdfs
    #cmd = "pdflatex #{@mt_base_name}.tex"
    #puts cmd; `#{cmd}`
    #convert
    #cmd = "convert -density 300 #{@mt_base_name}.pdf -antialias #{@mt_base_name}.png"
    #puts cmd; `#{cmd}`
    
    #cleanup    
    # ['tex','log','out','aux'].each {|ext|
    #   cmd = "rm -fr #{@mt_base_name}.#{ext}"
    #   puts cmd; `#{cmd}`
    # }
    
   


  end
  
  
  def calc_transf_gr_total_one_dim_csv_old
    puts "old method now: ---------------------------------"
    puts "source-------------------------------------------"
    

    #source
    @tt_ysums = []
    
    #for each row
    (0..@mat_arr_len-1).each { |s|

      #y=ProkGroup.find_by_order_id(s).id
      y = @mat_arr_ids[s]
        
      #puts "y: #{y}"
      
      #name of the group
      pgx = ProkGroup.find(y)
      

      #puts "s: #{s}"

      grp_seqs_sum = 0.0
      grp_seqs_cnt = 0.0
      grp_seqs_rate = 0.0
      
              
      @genes.each { |gn|
        
        
        res_src, res_dst =   
          #fetch nb of source id
        sql = "select count(distinct ht.source_id) as nb
             from HGT_COM_INT_TRANSFERS ht
              join HGT_COM_INT_FRAGMS hcf on hcf.ID = ht.HGT_COM_INT_FRAGM_ID
              join NCBI_SEQS ns_src on ns_src.id = ht.SOURCE_ID
              join TAXON_GROUPS tg_src on tg_src.TAXON_ID = ns_src.TAXON_ID
              join NCBI_SEQS ns_dest on ns_dest.id = ht.DEST_ID
              join TAXON_GROUPS tg_dest on tg_dest.TAXON_ID = ns_dest.TAXON_ID
             where hcf.GENE_ID = #{gn.id} and
                   tg_dest.PROK_GROUP_ID = #{y}"
   
        gn_seqs_nb = @conn.select_all(sql).first["nb"].to_f
          
        #fetch nb of source id
        sql = "select count(distinct gbs.NCBI_SEQ_ID) as cnt
                 from GENE_BLO_SEQS gbs 
                  join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
                  join TAXON_GROUPS tg on tg.TAXON_ID = ns.TAXON_ID
                 where gbs.GENE_ID = #{gn.id} and 
                       tg.PROK_GROUP_ID = #{y}"
        
        gn_seqs_cnt = @conn.select_all(sql).first["cnt"].to_f
          
        grp_seqs_sum +=  gn_seqs_nb
        grp_seqs_cnt +=  gn_seqs_cnt
          
      }
        
      
      #
      grp_seqs_rate = grp_seqs_sum / grp_seqs_cnt
      #normalize to number of genes
      
      #give percent values
      #grp_seqs_rate /= 110
      
      @tt_ysums[s] =  grp_seqs_rate
      
      
    }
 
    
    
    puts "@tt_ysums: #{@tt_ysums.inspect}"
    
    puts 
    
    #destination
    @tt_xsums = []
    
    #for each row
    (0..@mat_arr_len-1).each { |d|

      #y=ProkGroup.find_by_order_id(d).id
      x = @mat_arr_ids[d]
        
      #puts "x: #{x}"
      
      #name of the group
      pgx = ProkGroup.find(x)
      

      #puts "d: #{d}"

      grp_seqs_sum = 0.0
      grp_seqs_cnt = 0.0
      grp_seqs_rate = 0.0
      
              
      @genes.each { |gn|
        
        
        #fetch nb of source id
        sql = "select count(distinct ht.dest_id) as nb
             from HGT_COM_INT_TRANSFERS ht
              join HGT_COM_INT_FRAGMS hcf on hcf.ID = ht.HGT_COM_INT_FRAGM_ID
              join NCBI_SEQS ns_src on ns_src.id = ht.SOURCE_ID
              join TAXON_GROUPS tg_src on tg_src.TAXON_ID = ns_src.TAXON_ID
              join NCBI_SEQS ns_dest on ns_dest.id = ht.DEST_ID
              join TAXON_GROUPS tg_dest on tg_dest.TAXON_ID = ns_dest.TAXON_ID
             where hcf.GENE_ID = #{gn.id} and
                   tg_dest.PROK_GROUP_ID = #{x}"
   
        gn_seqs_nb = @conn.select_all(sql).first["nb"].to_f
          
        #fetch nb of source id
        sql = "select count(distinct gbs.NCBI_SEQ_ID) as cnt
                 from GENE_BLO_SEQS gbs 
                  join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
                  join TAXON_GROUPS tg on tg.TAXON_ID = ns.TAXON_ID
                 where gbs.GENE_ID = #{gn.id} and 
                       tg.PROK_GROUP_ID = #{x}"
        
        gn_seqs_cnt = @conn.select_all(sql).first["cnt"].to_f
          
        grp_seqs_sum +=  gn_seqs_nb
        grp_seqs_cnt +=  gn_seqs_cnt
          
      }
        
      
      #
      grp_seqs_rate = grp_seqs_sum / grp_seqs_cnt
      #normalize to number of genes
      
      #give percent values
      #grp_seqs_rate /= 110
      
      @tt_xsums[d] =  grp_seqs_rate
      
      
    }
 
    
    
    puts "@tt_xsums: #{@tt_xsums.inspect}"
    
  end
  
  
  #return number of affected ncbi_seqs from tranfer table [source, dest] 
  #scope between groups is already limited in table hgt_com_trsf_prkgrs
  def ncbi_seqs_sum_weight_old(gene_id, prok_group_id)
   
    res = []
  
    #compare destination with destination
    #source column with source table
    ["pgsrc_id","pgdst_id"].each { |col|
      #match column to related table
     
      sql = "select sum(prkg.WEIGHT_TR_PG) as nb
            from #{@arTrsfPrkgr.table_name} prkg
            where prkg.GENE_ID = #{gene_id} and
                  prkg.#{col} = #{prok_group_id}"
     
      #puts "sql: #{sql}"
    
      
      res <<  @arTrsfPrkgr.find_by_sql(sql).first.nb.to_f
  
     
    }
    #puts "res: #{res}"
    return res
   
   
  end

  #return number of affected ncbi_seqs from @arGeneGroupVal table [source, dest]
  #scope between groups is already limited in table gene_group_vals
  def get_gene_groups_vals_sums(gene_id, prok_group_id)

    res = []

    #compare destination with destination
    #source column with source table
    ["prok_group_source_id","prok_group_dest_id"].each { |col|
      #match column to related table

      sql = "select sum(ggv.val) as nb
            from #{@arGeneGroupsVal.table_name} ggv
            where ggv.GENE_ID = #{gene_id} and
                  ggv.#{col} = #{prok_group_id}"

      puts "sql: #{sql}"


      res <<  @arGeneGroupsVal.find_by_sql(sql).first.nb.to_f


    }
    #puts "res: #{res}"
    return res


  end

  #return number of affected ncbi_seqs from @arGeneGroupsCnt table
  def get_gene_group_cnts(gene_id, prok_group_id)

   
    return  @sg_hsh[[gene_id, prok_group_id]] || 0.0


  end
 
  
  


  #calculations on Matrix
  def calc_transf_gr_total_one_dim
    
    mat_ab = Matrix.rows(@ab_tr_mat)
    mat_gn = Matrix.rows(@gn_tr_mat)
    # puts "mat: #{mat_ab.inspect}"
    
    #limit interfamily transfers
    #prokid_min = @mat_arr_ids.min
    #prokid_max = @mat_arr_ids.max
    #puts "prokid_min: #{prokid_min}, prokid_max: #{prokid_max}"
    
    
    @tt_intra_sums = []
    #row by row
    (0..@mat_arr_len-1).each { |s|

      #next if d != 1
      
      x = @mat_arr_ids[s]
      #find nb of sequences in group
      pgsn = pgsn_hsh[x]
      
      
      row_abs = mat_ab.row(s)
      row_gn  = mat_gn.row(s)
      
      row_sum = 0.0
      row_abs.each_with_index { |e,idx| 
        #
        next if idx != s
        #sum based on matrix
        row_sum += e 
        #puts "idx: #{idx}, e: #{e} , #{col_gn[idx] > 6}, pgsn: #{pgsn}"
      }
      row_tt = row_sum / pgsn * 100
      
      #puts "row_tt: #{row_tt}"      
        
      @tt_intra_sums[s] = row_tt
    }
    
    
    
    
    
    
    
    
    @tt_xsums = []
    @tt_xsums_cond = []
    
    
    #row by row
    (0..@mat_arr_len-1).each { |s|

      #next if d != 1
      
      x = @mat_arr_ids[s]
      #find nb of sequences in group
      pgsn = pgsn_hsh[x]
      
      
      row_abs = mat_ab.row(s)
      row_gn  = mat_gn.row(s)
      
      row_sum = 0.0
      row_sum_cond = 0.0
      row_abs.each_with_index { |e,idx| 
        #
        next if idx == s
        #sum based on matrix
        row_sum += e 
        row_sum_cond += e if row_gn[idx] >= self.gn_mt_min_th
        #puts "idx: #{idx}, e: #{e} , #{col_gn[idx] > 6}, pgsn: #{pgsn}"
      }
      #row_tt = row_sum / pgsn * 100 / 1.1 #correct to 110 genes
      #row_tt_cond = row_sum_cond / pgsn * 100 / 1.1 #correct to 110 genes
      row_tt = row_sum / pgsn * 100
      row_tt_cond = row_sum_cond  / pgsn * 100
      
      #puts "row_tt: #{row_tt}"      
      
      @tt_xsums[s] = row_tt
      @tt_xsums_cond[s] = row_tt_cond
      
    }
    
    
    @tt_ysums = []
    @tt_ysums_cond = []
    # col by col
    (0..@mat_arr_len-1).each { |d|

      #next if d != 1
      
      y = @mat_arr_ids[d]
      #find nb of sequences in group
      pgsn = pgsn_hsh[y]
      
      
      col_abs = mat_ab.column(d)
      col_gn  = mat_gn.column(d)
      
      col_sum = 0.0
      col_sum_cond = 0.0
      col_abs.each_with_index { |e,idx| 
        #
        next if idx == d
        
        #sum based on matrix
        col_sum += e 
        col_sum_cond += e if col_gn[idx] >= self.gn_mt_min_th
        #puts "idx: #{idx}, e: #{e} , #{col_gn[idx] > 6}, pgsn: #{pgsn}"
      }
      #col_tt = col_sum / pgsn * 100 / 1.1 #correct to 110 genes
      #col_tt_cond = col_sum_cond / pgsn * 100 / 1.1 #correct to 110 genes
      col_tt = col_sum / pgsn * 100
      col_tt_cond = col_sum_cond / pgsn * 100 
      
      #puts "col_tt: #{col_tt}"      
      
      @tt_ysums[d] = col_tt
      @tt_ysums_cond[d] = col_tt_cond
      
      
    }
    
    
    sql=<<-END
select count(distinct gene_id) as gene_id
from GENE_GROUP_CNTS ggc
 join PROK_GROUPS pg on pg.ID = ggc.PROK_GROUP_ID
where pg.GROUP_CRITER_ID = #{crit_id}
group by pg.ORDER_ID  
order by pg.order_id
    END

    @tt_nb_genes = GeneGroupCnt.find_by_sql(sql).collect{|e| e.gene_id}    
    puts  "tt_nb_genes: #{@tt_nb_genes.inspect}"
    
    #grand total 
    @mt_all = 0.0
    
    @pgsn_a = []
    (0..@mat_arr_len-1).each { |s|
      @pgsn_a[s] = pgsn_hsh[@mat_arr_ids[s]]
    }
    puts "@pgsn_a: #{@pgsn_a.inspect}"

    #weighted mean of a by b = sumprod(a * b) / sum (b)
   # @mt_all = (0..@mat_arr_len-1).inject(0){ |sum, i| sum + @tt_xsums[i] * @pgsn_a[i] } / @pgsn_a.reduce(:+)
     @mt_all = (0..@mat_arr_len-1).inject(0){ |sum, i| sum + (@tt_xsums[i] + @tt_intra_sums[i]) * @pgsn_a[i] } / @pgsn_a.reduce(:+)
    puts "@mt_all: #{@mt_all}" 
    
    
    
     
  end
  
  #operations @one_dim_op :sum_weight,:count_col
  def calc_transf_gr_total_one_dim_database
    
    #limit interfamily transfers
    prokid_min = @mat_arr_ids.min
    prokid_max = @mat_arr_ids.max
    
    puts "prokid_min: #{prokid_min}, prokid_max: #{prokid_max}"
    
    
    puts "new method: +++++++++++++++++++++++++++"
    @tt_ysums = []
    @tt_xsums = []
    @tt_nb_genes = []

    #for each row
    (0..@mat_arr_len-1).each { |order_id|
      #debugging
      #next if order_id != 9

     
      prok_group_id = @mat_arr_ids[order_id]
        
      #puts "prok_group_id: #{prok_group_id}"
      
      #name of the group
      prok_group_name = ProkGroup.find(prok_group_id)
      

      #puts "order_id: #{order_id}"

      grp_seqs_sum = [0.0, 0.0]
      grp_seqs_cnt = [0.0, 0.0]
      grp_seqs_rte = [0.0, 0.0]
      
      grp_seqs_rate = [0.0, 0.0]
      
      nb_genes  = 0.0
              
      @genes.each { |gn|
        
        #take into account operation 
        case @one_dim_op
        when :sum_weight then
          gn_seqs_nb = get_gene_groups_vals_sums(gn.id, prok_group_id)
        
          #puts "gn_seqs_nb, #{gn_seqs_nb.inspect}"
          
          #debugging
          #gn_seqs_cnt = 1.0/110.0
         
          
          #gn_seqs_cnt = arTransferGroup.ncbi_seqs_cnt(gn.id, prok_group_id, :count_star)
          gn_seqs_cnt = get_gene_group_cnts(gn.id, prok_group_id)
          
         
          #raise "This is wrong" unless gn_seqs_cnt == 21
         
          
          
          #when :count_col then
          #  gn_seqs_nb = arTransferGroup.ncbi_seqs_nb(gn.id, prok_group_id, prokid_min, prokid_max, :count_col)
          #puts "gn_seqs_nb, #{gn_seqs_nb.inspect}"
          #  gn_seqs_cnt = arTransferGroup.ncbi_seqs_cnt(gn.id, prok_group_id, :count_seqs)
         
          
        end
        
        
        
        
        #puts "gn_seqs_cnt: #{gn_seqs_cnt}"
        
        
        #if order_id == 3
        # puts "gn.id: #{gn.id}, prok_group_id: #{prok_group_id}, gn_seqs_nb: #{gn_seqs_nb.inspect}, gn_seqs_cnt: #{gn_seqs_cnt}"   
        #end
       
        #[100,100,100].zip([2,3,4]).map { |z| z.inject(&:+) }
        #=> [102, 103, 104]
        
        #gene seqs rate
      
        if gn_seqs_cnt != 0
          
          nb_genes += 1
          #gn_seqs_rte = gn_seqs_nb.zip([gn_seqs_cnt,gn_seqs_cnt]).map {|a,b| a/b}
          #grp_seqs_rte = grp_seqs_rte.zip(gn_seqs_rte).map { |z| z.inject(&:+) }
          
          #puts "gn_seqs_nb: #{gn_seqs_nb.inspect}, gn_seqs_cnt: #{gn_seqs_cnt}, gn_seqs_rte: #{gn_seqs_rte.inspect} NB_GENES: #{nb_genes}"
          
          
        end
        
        
        
        #vector addition
        grp_seqs_sum = grp_seqs_sum.zip(gn_seqs_nb).map { |z| z.inject(&:+) }
        #same dimension for both groups
        grp_seqs_cnt = grp_seqs_cnt.zip([gn_seqs_cnt,gn_seqs_cnt]).map { |z| z.inject(&:+) }
          
      }
        
      
      #[100,100].zip([2,3]).map { |x,y| x + y }   
      # => [102, 103]

      puts "grp_seqs_sum: #{grp_seqs_sum.inspect}"
      puts "grp_seqs_cnt: #{grp_seqs_cnt.inspect}"
      puts "grp_seqs_rte: #{grp_seqs_rte.inspect}"
      puts "nb_genes total: #{nb_genes}"
      
      #calculate as percentage 
      #grp_seqs_rate = grp_seqs_sum.zip(grp_seqs_cnt).map { |x,y| (1000000 * x) / (y * @genes.size) }
      #
      #grp_seqs_rate = grp_seqs_sum.zip(grp_seqs_cnt).map { |x,y| (100 * x) / (y * nb_genes) }
      grp_seqs_rate = grp_seqs_sum.zip(grp_seqs_cnt).map { |x,y| (100 * x) / y }
      #
      #debug
      #grp_seqs_rate = grp_seqs_sum.zip(grp_seqs_cnt).map { |x,y| x }
      
      #grp_seqs_rate = grp_seqs_rte.map { |x| (100 * x) / nb_genes }
      
      puts "grp_seqs_rate: #{grp_seqs_rate.inspect}"
      
      #normalize to number of genes
      
      #give percent values
      #grp_seqs_rate /= 110
      
      
      #if grp_seqs_rate[0] > 0.7 or grp_seqs_rate[1] > 0.7
      #puts "order_id: #{order_id} bigger than 0.7, prok_group_id:#{prok_group_id}, prok_group_name: #{prok_group_name}"
        
      #end
      
      #ysums is source, xsums is destination
      @tt_ysums[order_id], @tt_xsums[order_id] =  grp_seqs_rate
      @tt_nb_genes[order_id] = nb_genes
      
      puts "order_id: #{order_id}, grp_seqs_rate: #{grp_seqs_rate.inspect}" 
      
    }
    puts "@tt_ysums: #{@tt_ysums.inspect}" 
    puts 
    puts "@tt_xsums: #{@tt_xsums.inspect}"   
    
    
    
    
    
  end
  
  #
  def exp_transf_gr_total_one_dim_csv

    puts "in exp_transf_gr_total_one_dim_csv.."
    
    
    Dir.chdir exp_d

    csvf_f = exp_d(:csv) + "#{tt_base_name}.csv"
     
    csvf = File.new(csvf_f, "w")
    
    #headers
    csvf.puts "NAME,XTOT,YTOT,NB_GENES,INTRA"
           
    #for each row
    (0..@mat_arr_len-1).each { |a|
      
      b = @mat_arr_ids[a]
        
      #name of the group
      pg = ProkGroup.find(b)

       
      #valx = @tt_frm % @cell_lambda.call(@tt_xsums[a])
      #valy = @tt_frm % @cell_lambda.call(@tt_ysums[a])
      
      valx = @tt_frm % @tt_xsums_cond[a]
      valy = @tt_frm % @tt_ysums_cond[a]
      nb_genes = @tt_frm % @tt_nb_genes[a]
      intra = @tt_frm % @tt_intra_sums[a]
      csvf.puts "#{pg.name},#{valx},#{valy},#{nb_genes},#{intra}"
      puts "#{pg.name},#{valx},#{valy},#{nb_genes},#{intra}"

    }
   
    
    csvf.close

    #move result
    #sys "mv #{tt_base_name}.csv ../dat/"
    
  end
  
  
  def exp_tt_gr_hg
    
    
        
    
    ["a","b"].each { |ver| 
      
          
      
      
      [["pdf","pdfcairo"],["png","pngcairo"],
        ["emf","emf"] ].each { |ext,terminal| 
        
        puts "ver: #{ver}"
        puts "terminal: #{terminal}, ext: #{ext}"
      
        puts "in exp_tt_gr_hg..."
        #load com and par csv files
    
        #com
        self.stage = :hgt_com
        csvf_f = exp_d(:csv) + "#{tt_base_name}.csv"
        puts "csvf_f: #{csvf_f}"
        com_tt_a = CSV.read(csvf_f)
        heads = com_tt_a.shift
        puts "com_tt_a: #{com_tt_a.inspect}"
    
        #par
        self.stage = :hgt_tot
        csvf_f = exp_d(:csv) + "#{tt_base_name}.csv"
        puts "csvf_f: #{csvf_f}"
        par_tt_a = CSV.read(csvf_f)
        heads = par_tt_a.shift
        puts "par_tt_a: #{par_tt_a.inspect}"
    
    
        n = com_tt_a.length
        names_a = com_tt_a.collect { |it|  it[0]}
        genes_a = com_tt_a.collect { |it|  it[3]}
    
        sql=<<-END
select cl.RGB_HEX
from PROK_GROUPS pg
 join COLORS cl on cl.ID = pg.COLOR_ID
where pg.GROUP_CRITER_ID = #{crit_id}
order by pg.ORDER_ID
        END
        colors = ProkGroup.find_by_sql(sql).collect{|e| e.rgb_hex}
    
        puts "tt_nb_genes: #{@tt_nb_genes.inspect}"
        puts "genes_a: #{genes_a.inspect}"
    
        puts "n: #{n}, names: #{names_a.inspect}"
    
    
        tt_gr_d = Pathname.new "#{AppConfig.db_exports_dir}/#{calc_section}/gr_tt/work"
    
        #for source and destination columns
        #[[1,"src","HGT source by 100 comparisons and 100 genes"],
        # [2,"dst","HGT destination by 100 comparisons and 100 genes"],
        # [4,"int","HGT intra by 100 comparisons and 100 genes"],
        #].each {|col_idx,file_suffix,title|
          
        [[1,"src",""],
         [2,"dst",""],
         [4,"int",""],
        ].each {|col_idx,file_suffix,title|
          
            
          
   
          com_a = com_tt_a.collect { |it|  it[col_idx]}
          par_a = par_tt_a.collect { |it|  it[col_idx]}
      

             
    
          tt_gr_name =  "#{crit}-#{calc_type}-#{phylo_prog}-#{thres}-#{hgt_type.to_s}-hg-#{file_suffix}"
          tt_gr_f = tt_gr_d + "#{tt_gr_name}-#{ver}.gp"
    
          puts "tt_gr_d: #{tt_gr_d}"
          puts "tt_gr_f: #{tt_gr_f}"
    
          skip_idx_a = []
    
          names_txt = ""
          i = -1
          (0..n-1).each {|j|
            if (genes_a[j].to_i < self.gn_tt_min_th and ver == "a") or
                (genes_a[j].to_i >= self.gn_tt_min_th and ver == "b")
              skip_idx_a << j
              next
            end
            i += 1
            names_txt += "set xtics add (\"#{names_a[j]}\" #{i+1}) \n"
          }
    
          if crit==:family and ver == "a"
           max_y = 22
           xsize = 1600
           margb, margt, margl, margr = 0.32, 0.92, 0.07, 0.99
           hist_larg = 0.3
           #title_txt = "#{title} - (a)"
           title_txt = "(a)"
         elsif crit==:family and ver == "b"
           xsize = 250
           margb, margt, margl, margr = 0.32, 0.92, 0.45, 0.98
           hist_larg = 0.3
           title_txt = "(b)"
           if file_suffix == "src"
            max_y = 22
           else 
             max_y = 55
           end
         elsif crit==:habitat and ver == "a"
           xsize = 900
           margb, margt, margl, margr = 0.23, 0.97, 0.17, 0.98
           hist_larg = 0.2
           title_txt = "#{title}"
           max_y = 10
         elsif crit==:habitat and ver == "b"
           xsize = 320
           margb, margt, margl, margr = 0.23, 0.97, 0.45, 0.85
           hist_larg = 0.20
           title_txt = ""
           max_y = 10
         end
         
         
          #positions
          pos_txt = ""
          i = -1
          (0..n-1).each {|j|
            next if skip_idx_a.include?(j) 
            i += 1
            puts "com_a[j]: #{com_a[j]}, par_a[j]: #{par_a[j]}"
            #com
            #fs_txt = case genes_a[i].to_i >= self.gn_tt_min_th
            #when true then "solid 1 lw 2"
            #else "pattern 4 border"
            #end
            fs_txt = "solid 1 lw 2"
         
            color_txt = case crit
            when :family then "\"#{colors[j]}\""
            when :habitat then "\"blue\""
            end
            pos_txt += "set object #{1 + i*2} rect from (#{i+1}-#{hist_larg}),0             to (#{i+1}+#{hist_larg}),#{com_a[j]} fc rgb #{color_txt} fillstyle #{fs_txt} \n"
            #par
            #fs_txt = case genes_a[i].to_i >= self.gn_tt_min_th
            #when true then "solid 0.5 lw 2"
            #else "pattern 5 border"
            #end 
            fs_txt = "solid 0.5 lw 2"
            
            pos_txt += "set object #{2 + i*2} rect from (#{i+1}-#{hist_larg}),(#{com_a[j]}) to (#{i+1}+#{hist_larg}),(#{par_a[j]}) fc rgb #{color_txt} fillstyle #{fs_txt} \n"
      
            pos_txt += "# \n"
          }
  
         
           
          
   if ver == "a"
        
            
yrange_txt=<<END
 set yrange [0:#{max_y}] 
 set ytics 10 out nomirror
 set mytics 
END
      elsif ver == "b"
       
yrange_txt=<<END

  set yrange [0:#{max_y}] 
  set ytics 10 out nomirror
  set mytics 5
  #unset ytics

  #set y2range [0:#{max_y}] 
  #set y2tics 10 out nomirror
  #set my2tics 5
END

            
      end

       
    
          gr_txt=<<-END    
set terminal #{terminal} size #{xsize},1000 font "Arial,22" dashed enhanced 

set output "#{tt_gr_name}-#{ver}.#{ext}"

set size 1.00, 1.0
set origin 0.015, 0.00 

set bmargin at screen #{margb}
set tmargin at screen #{margt}

set lmargin at screen #{margl}
set rmargin at screen #{margr}



set title "#{title_txt}" font "Arial,28" 
#set ylabel "HGT source by 100 comparisons and 100 genes" font "Arial,28" 


set style fill solid border -1
set style line 1 lt 3 lc rgb "black" lw 2

#
set style line 2 lt 1 lc rgb "black" lw 0
set style line 3 lt 1 lc rgb "white" lw 2
set style line 4 lt 1 lc rgb "gray20" lw 1
set style line 5 lt 1 lc rgb "gray80" lw 1

set xrange [0.5:#{n-skip_idx_a.length}.5]
#set xtics  0 nomirror right rotate by 80 offset 0,-12.5
set xtics out nomirror rotate by 45 right 1

#{names_txt}

#{yrange_txt}

#set style fill transparent solid 0.3
#set style fill transparency pattern 5
#{pos_txt}

plot 400  with lines ls 2  title ""

          END

          #save to disk
          tt_gr_f.open('w'){ |f| f.puts gr_txt }
      
          #compile
          dir, base = tt_gr_f.split
          Dir.chdir(dir)
          sys "gnuplot #{base}"
        
          sys "mv #{base} ../#{ext}/"
          sys "mv #{tt_gr_name}-#{ver}.#{ext} ../#{ext}/"
      
        }
      
      } #end ext
    } #end version
    
  end
  

  

   
  #heatmaps
  def exp_transf_gr_heatmap_gp_pdf

    @exp_type = "pdf"

    
    
    Dir.chdir exp_d
    #work cleanly
    ['tex','log','out','aux','pdf','gp'].each {|ext|
      cmd = "rm -fr #{hm_base_name}.#{ext}"
      puts cmd; `#{cmd}`
      
    }

    sleep 2
    
    #some texts
    
    case @stage 
    when "hgt-par"
      @stage_txt = "Partial HGTs"
    when "hgt-com"
      @stage_txt = "Complete HGTs"
    when "hgt-tot"
      @stage_txt = "Complete and Partial HGTs"
    when "recomb"
      @stage_txt = "Recombinations"
    end
    
    case @phylo_prog
    when "phyml"
      @phylo_prog_txt = "PhyML inference"
      @thres_txt = "#{@thres} \\% confidence"
    when "raxml"
      @phylo_prog_txt = "RAxML inference"
      @thres_txt = "#{@thres} \\% confidence"
    when "geneconv"
      @phylo_prog_txt = "RDP4 inference"
      @thres_txt = ""
    end
    
    case @hgt_type
    when :regular
      @hgt_type_txt = "Regular transfers"
    when :all
      @hgt_type_txt = "All transfers"
    end

    @cblabel_txt = "#{@stage_txt}, #{@thres_txt}"
    
    #set range 
    #default is maximum matrix sum
    @max_cbrange = (@config.nil?) ? @mt_all.to_i : @config[2]
    
    #gnuplot template erb file  
    hm_text = File.read("#{AppConfig.db_exports_dir}/#{@stage}/#{@crit}/erb/hm.pdf.gp.erb")
    
    #gnuplot specific file
    gp_f = File.new("#{hm_base_name}.gp", "w")


    #write gnuplot file from erb template
    b= binding

    gp_erb = ERB.new(hm_text)

    #uses @hm_base_name
    gp_f.puts gp_erb.result(b)

    gp_f.close

    #compile pdfs
    cmd = "gnuplot #{hm_base_name}.gp"
    puts cmd; `#{cmd}`
    #convert
    cmd = "convert -density 300 #{hm_base_name}.pdf -antialias #{hm_base_name}.png"
    puts cmd; `#{cmd}`
    
    #copy data results
    ['dat','datx','daty'].each {|ext|
      cmd = "cp #{hm_base_name}.#{ext} ../dat/"
      puts cmd; `#{cmd}`

    }

    ['pdf','gp'].each {|ext|
      cmd = "mv #{hm_base_name}.#{ext} ../pdf/"
      puts cmd; `#{cmd}`

    }
    
    #cleanup
    #['dat','datx','daty','gp'].each {|ext|
    #  cmd = "rm -fr #{@hm_base_name}.#{ext}"
    #puts cmd; `#{cmd}`
      
    #}

  end

  #heatmaps
  def exp_transf_gr_heatmap_gp_svg

    @exp_type = "svg"

    puts "exp_d: #{exp_d}"
    Dir.chdir exp_d

    ['tex','log','out','aux','svg'].each {|ext|
      cmd = "rm -fr #{hm_base_name}.#{ext}"
      puts cmd; `#{cmd}`
      

    }
    sys "rm -fr gp_image*.png"
    sys "rm -fr gp_image*.b64"

    
    sleep 2

    #some texts

    case @stage
    when "hgt-par"
      @stage_txt = "Overall HGTs"
    when "hgt-com"
      @stage_txt = "Complete HGTs"
    when "hgt-tot"
      @stage_txt = "Overall HGTs"
    when "recomb"
      @stage_txt = "Recombinations"
    end

    case @phylo_prog
    when "phyml"
      @phylo_prog_txt = "PhyML inference"
      @thres_txt = "#{@thres} \\% confidence"
    when "raxml"
      @phylo_prog_txt = "RAxML inference"
      @thres_txt = "#{@thres} \\% confidence"
    when "geneconv"
      @phylo_prog_txt = "RDP4 inference"
      @thres_txt = ""
    end

    case @hgt_type
    when :regular
      @hgt_type_txt = "Regular transfers"
    when :all
      @hgt_type_txt = "All transfers"
    end

    @cblabel_txt = "#{@stage_txt}, #{@thres_txt}"

    #set range
    #default is maximum matrix sum
    @max_cbrange = (@config.nil?) ? @mt_all.to_i : @config[2]

    #gnuplot template erb file
    hm_text = File.read("#{AppConfig.db_exports_dir}/#{@stage}/#{@crit}/erb/hm.#{ @exp_type}.gp.erb")

    #gnuplot specific file
    gp_f = File.new("#{hm_base_name}.gp", "w")


    #write gnuplot file from erb template
    b= binding

    gp_erb = ERB.new(hm_text)

    #uses @hm_base_name
    gp_f.puts gp_erb.result(b)

    gp_f.close

    #compile pdfs
    cmd = "gnuplot #{hm_base_name}.gp"
    puts cmd; `#{cmd}`
    #convert
    #cmd = "convert -density 300 #{@hm_base_name}.pdf -antialias #{@hm_base_name}.png"
    #puts cmd; `#{cmd}`

    #copy data results
    #['dat','datx','daty','gp'].each {|ext|
    #  cmd = "cp #{hm_base_name}.#{ext} ./dat/"
    #  puts cmd; `#{cmd}`
    #}

    scale = 640 if @crit == :habitat
    scale = 920 if @crit == :family

    puts "scale: #{scale}"
    sys "convert -scale #{scale}x#{scale} gp_image_01.png gp_image_05.png"
    sys "base64 gp_image_05.png > gp_image_05.b64"
     

    doc = Nokogiri::XML(File.open("#{hm_base_name}.svg")) { |config|
      config.strict.nonet
    }
    #puts "doc: #{doc.inspect}"
    #read scaled image
    image_b64 = File.open("gp_image_05.b64", 'rb') { |f| f.read }


    #image_n = doc.search("//svg[@id='gnuplot_canvas']").first
    image_n = doc.xpath('//doc:image', 'doc' => 'http://www.w3.org/2000/svg').first

    puts "image_n: #{image_n.inspect}"
    
    image_n["xlink:href"]="data:image/png;base64,#{image_b64}"

    
    # Save a string to a file.
    aFile = File.new( "#{hm_base_name}.svg", "w")
    aFile.write(doc)
    aFile.close

    sys "mv #{hm_base_name}.gp ../svg/"
    sys "mv #{hm_base_name}.svg ../svg/"

    #['svg'].each {|ext|
    #  cmd = "mv #{@hm_base_name}.#{ext} ./#{ext}/"
    #  puts cmd; `#{cmd}`

    #}

    #cleanup
    sys "rm -fr gp_image*.png"
    sys "rm -fr gp_image*.b64"
  end
  
  
  def exp_transf_gr_heatmap_gp_png_emf

    ["png","emf"].each { |frm|
      @exp_type = frm

      puts "exp_d: #{exp_d}"
      Dir.chdir exp_d

      case @stage
      when "hgt-par"
        @stage_txt = "Partial HGTs"
      when "hgt-com"
        @stage_txt = "Complete HGTs"
      when "hgt-tot"
         #@stage_txt = "Complete and Partial HGTs"
        @stage_txt = "Partial HGTs" 
      when "recomb"
        @stage_txt = "Recombinations"
      end

      case @phylo_prog
      when "phyml"
        @phylo_prog_txt = "PhyML inference"
        @thres_txt = "#{@thres} \\% confidence"
      when "raxml"
        @phylo_prog_txt = "RAxML inference"
        @thres_txt = "#{@thres} \\% confidence"
      when "geneconv"
        @phylo_prog_txt = "RDP4 inference"
        @thres_txt = ""
      end

      case @hgt_type
      when :regular
        @hgt_type_txt = "Regular transfers"
      when :all
        @hgt_type_txt = "All transfers"
      end

      @cblabel_txt = "#{@stage_txt}, #{@thres_txt}"

      #set range
      #default is maximum matrix sum
      @max_cbrange = (@config.nil?) ? @mt_all.to_i : @config[2]

      #gnuplot template erb file
      hm_text = File.read("#{AppConfig.db_exports_dir}/#{@stage}/#{@crit}/erb/hm.#{@exp_type}.gp.erb")

      #gnuplot specific file
      gp_f = File.new("#{hm_base_name}.gp", "w")

      #write gnuplot file from erb template
      b= binding

      gp_erb = ERB.new(hm_text)

      #uses @hm_base_name
      gp_f.puts gp_erb.result(b)

      gp_f.close

      #compile
      cmd = "gnuplot #{hm_base_name}.gp"
      puts cmd; `#{cmd}`

      
      sys "mv #{hm_base_name}.gp ../#{@exp_type}/"
      sys "mv #{hm_base_name}.#{@exp_type} ../#{@exp_type}/"
    }
  end

  def export_hgts_ink

    Dir.chdir exp_d

    sql = "select bt_par.src_order,
       bt_par.dst_order,
       bt_par.cnt_rel+0 as par_rel,
       bt_par.nb_genes_rel+0 as par_nb_genes_rel,
       com_tg.cnt_rel+0 as com_rel,
       com_tg.nb_genes_rel+0 as com_nb_genes_rel,
       bt_par.src_name,
       bt_par.dst_name
from (select tg.PROK_GROUP_source_id src_id,
             tg.PROK_GROUP_dest_id dst_id,
             pg_src.ORDER_ID+1 as src_order,
             pg_dst.ORDER_ID+1 as dst_order,
             tg.CNT_REL,
             tg.NB_GENES_REL,
             pg_src.NAME as src_name,
             pg_dst.name as dst_name
from HGT_PAR_TRANSFER_GROUPS tg
 join PROK_GROUPS pg_src on pg_src.ID = tg.PROK_GROUP_SOURCE_ID                           
 join PROK_GROUPS pg_dst on pg_dst.ID = tg.PROK_GROUP_DEST_ID                           
where tg.PROK_GROUP_SOURCE_ID between 0 and 22 and
      tg.PROK_GROUP_DEST_ID between 0 and 22
order by tg.CNT_REL desc                         
) bt_par 
 join hgt_com_int_transfer_groups com_tg on com_tg.prok_group_source_id = bt_par.src_id and
                                            com_tg.prok_group_dest_id = bt_par.dst_id
limit 30"
    
    @hgts_ink = @conn.select_all sql
    
    # puts @hgts_ink.inspect
   
       
    hgts_ink = File.new("#{hgts_ink_fname}.csv", "w")
   
    #headers
    hgts_ink.puts "src_order,dst_order,par_rel,com_rel,par_nb_genes_rel,src_name,dst_name"
    
    
    @hgts_ink.each {|hgt|
      #correct spaces
      #trname = col["tree_name"].gsub(/\s/,'_')
     
      #puts "col: #{col.inspect}"
      #puts "trname: #{trname}, "
      par_rel = "%5.2f" % hgt["par_rel"]
      par_nb_genes_rel = "%5.0f" % hgt["par_nb_genes_rel"]
      
      com_rel = "%5.2f" % hgt["com_rel"]
      #com is same as par
      #com_nb_genes_rel = "%5.0f" % hgt["com_nb_genes_rel"]
      
      
      
      hgts_ink.puts "#{hgt["src_order"]},#{hgt["dst_order"]},#{par_rel},#{com_rel},#{par_nb_genes_rel},#{hgt["src_name"]},#{hgt["dst_name"]}"
    }
    hgts_ink.close
    
    #move result
    sys "mv #{hgts_ink_fname}.csv ../csv/"
    

    
  end
  

  def dataset_export
     
    
    @db_dataset_script = "#{AppConfig.db_datasets}/psql-files/#{@stage}-tbl-export.sql" 
    
    puts "@db_dataset_dir: #{@db_dataset_dir}"
     
    Dir.chdir @db_dataset_dir
    
    #clean
   
    ['dsv','log'].each {|ext|
      sys "rm -fr *.#{ext}"
         
    }
    sleep 10
     
    sys "java -XX:+UseConcMarkSweepGC -Xms128m -Xmx1024m -jar #{@sqltool_jar_fname} --rcFile=#{@sqltool_rc_fname} #{@sqltool_urlid} #{@db_dataset_script}"
    sleep 10
    #puts cmd
    
  end
  
  def dataset_import
    
    @db_dataset_script = "#{AppConfig.db_datasets}/psql-files/#{@stage}-tbl-import.sql" 
    
    puts "@db_dataset_dir: #{@db_dataset_dir}"
     
    Dir.chdir @db_dataset_dir
    
    #clean
   
    sleep 10
    
    sys "java -XX:+UseConcMarkSweepGC -Xms128m -Xmx1024m -jar #{@sqltool_jar_fname} --rcFile=#{@sqltool_rc_fname} #{@sqltool_urlid} #{@db_dataset_script}"
    
            sleep 10
    
    
            end
    
    end
