
require 'rubygems'
require 'bio' 
require 'msa_tools'
require 'faster_csv'
require 'erb'
require 'matrix'
require 'base_transfer'
require 'manage_data'
require 'time_estim'

require 'java'
JavaStringReader = java.io.StringReader
JavaString = java.lang.String


module HgtCom
  
  attr_accessor :sim_max_pval, 
    :sim_perc_recomb,
    :sim_align_type,
    :sim_order_by,
    :sim_rows_limit,
    :sim_nb_perms,
    :sim_nb_seqs,
    :sim_thres
    
  
  
  def init

    puts "in HgtCom init"
    #active record object initialization
    self.arTrsfTaxon = HgtComTrsfTaxon
    self.arTrsfPrkgr = HgtComTrsfPrkgr
    self.arTrsfTiming = HgtComTrsfTiming
    
    self.arTransferGroup =  HgtComIntTransferGroup
    self.arGeneGroupCnt = GeneGroupCnt
    self.arGeneGroupsVal = HgtComGeneGroupsVal

    super

  end

  def initialize()

    puts "in HgtCom initialize"
    
    #initialize included modules
    #super

  end
  
  
  def treat_fragms
    
    HgtComIntFragm.delete_all
    puts "destroyed HgtComIntFragm"
    #recreate list of transfers
    HgtComIntTransfer.delete_all
    #and associated timing information
    HgtComTrsfTiming.delete_all

   
    
    cnt = 0
   
    genes.each { |gn|
      cnt += 1
      #fl = fl.split

      
      #@gene_name=fl[1]
      @gene = gn
      puts "gene: #{@gene.name}"
      #next if @gene.name != "eno"
      
      next if @gene.name == "rbcL"
     

      #import one gene
      import_fragms_one_gene()
      
      

      #insert half (direct transfers then
      #reverse transfers of this gene)
      [["from_subtree", "to_subtree", "weight_direct"],
        ["to_subtree",  "from_subtree", "weight_inverse"]
      ].each {|from, to, weight|
        
        puts "Continuing fragments..."
        #hgt_com_int_contin table
        #always contains only one active half of genes
        HgtComIntContin.delete_all

        sql = "insert into hgt_com_int_contins
                             (gene_id,
                              iter_no,
                              hgt_no,
                              hgt_type,
                              hgt_com_int_fragm_id,
                              bs_val,
                              from_subtree,
                              to_subtree,
                              weight
                             )
                       select gene_id,
                              iter_no,
                              hgt_no,
                              hgt_type,
                              id,
                              bs_val,
                              #{from},
                              #{to},
                              #{weight}
                       from hgt_com_int_fragms
                       where gene_id = #{@gene.id}"
        
        #puts "sql: #{sql}"
        @conn.execute sql
       
        contin_half()

        #calc_timed_transfers_all_genes()

        linearize_half()

        
      }
      
      
    }
    
    
    
    
  end
  
  def treat_qfunc_transfers
    
    #HgtQfuncTransfer.where(:hgt_qfunc_cond_id => qfunc_f_opt_max).delete_all
    HgtQfuncTransfer.delete_all
    
    puts "deleted HgtQfuncTransfer"
    
    
    sql = \
      "insert into hgt_qfunc_transfers
       (gene_id,
        source_id,
        dest_id,
        val,
        conf)
       values
        (?,?,?,?,?);"
    
    @treat_qfunc_transfers_01_pstmt = @jdbc_conn.prepare_statement(sql);
    
    #prepare statements
    @jdbc_conn.set_auto_commit(false)
    
    
    
    cnt = 0
    nb_rows = 0
   
    genes.each { |gn|
      cnt += 1
      
      @gene = gn
      #next if @gene.name != "thrC"
      puts "gene: #{@gene.name}, gene_id: #{@gene.id}"
      
      
      Dir.chdir(qfunc_work_d)
      
      q_func_hgts = CSV.read(q_func_hgts_csv_f)
    
      heads = q_func_hgts.shift
        
      #puts "load_q_func_hgts: #{q_func_hgts.inspect}"
   
      q_func_hgts.each { |qfunc_row|
      
        src_id = qfunc_row[8]
        dst_id = qfunc_row[9]
        val = qfunc_row[10].to_f
        conf = qfunc_row[11].to_f
      
        if src_id.to_i > dst_id.to_i
          src_id, dst_id = dst_id, src_id
        
        end
      
        if conf <= self.sim_max_pval and val > 0.0
          @treat_qfunc_transfers_01_pstmt.set_int(1,@gene.id.to_i)
          @treat_qfunc_transfers_01_pstmt.set_int(2,src_id.to_i)
          @treat_qfunc_transfers_01_pstmt.set_int(3,dst_id.to_i)
          @treat_qfunc_transfers_01_pstmt.set_double(4,val)
          @treat_qfunc_transfers_01_pstmt.set_double(5,conf)
          nb_rows += 1
          @treat_qfunc_transfers_01_pstmt.add_batch()
        end
      
      
      }
      
      if nb_rows >0 
        @treat_qfunc_transfers_01_pstmt.execute_batch()
        nb_rows = 0
      end

       
      
     
      
    }
    
    @jdbc_conn.commit
    
    @jdbc_conn.set_auto_commit(true)
    
   
    
    
    
  end
  
  def import_fragms_one_gene

    Dir.chdir "#{AppConfig.hgt_com_dir}/hgt-com-#{@phylo_prog}/results"

    puts "gene_id: #{@gene.id}, gene_name: #{@gene.name}"
    
    
    @hgt_com_int_dir = "hgt-com-#{@phylo_prog}_gene#{@gene.name}_id#{@gene.id}.BQ"
          
    puts "hgt_com_int_dir: #{@hgt_com_int_dir}"
    @hgt_com_int_output_f = "#{@hgt_com_int_dir}/output.txt"
          
       
    if File.exists?(@hgt_com_int_output_f)
      File.open(@hgt_com_int_output_f,"r") { |hci|
        #parse results file
        hci.each { |ln|
          #puts ln
          if ln =~ /^\|\sIteration\s\#(\d+)\s:/
            puts "------------#{$1}---------->#{ln}"
            @iter_no = $1
          elsif ln =~ /^\|\sHGT\s(\d+)\s\/\s(\d+)\s+Trivial\s+\(bootstrap\svalue\s=\s([\d|\.]+)\%\sinverse\s=\s([\d|\.]+)\%\)/
            puts "Trivial: ------#{$1}--#{$3}--#{$4}---------->#{ln}"
            @hgt_fragm_type = "Trivial"
            @hgt_no= $1
            @bs_direct = $3.to_f
            @bs_inverse = $4.to_f
          elsif ln =~ /^\|\sHGT\s(\d+)\s\/\s(\d+)\s+Regular\s+\(bootstrap\svalue\s=\s([\d|\.]+)\%\sinverse\s=\s([\d|\.]+)\%\)/
            puts "Regular: ------#{$1}--#{$3}--#{$4}---------->#{ln}"
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
            #if @bs_val >= @thres
            if @bs_val >= thres and hgt_type_avail_db.include? @hgt_fragm_type
              #insert direct transfer, with weight_inverse information for inverse weight
              frgm = HgtComIntFragm.new
              #puts "#{@iter_no},#{@hgt_no},#{@from_subtree},#{@to_subtree},#{@bs_val}"
              #frgm.gene = Gene.find_by_name(@gene)
              frgm.gene = @gene
              frgm.iter_no=@iter_no.to_i
              frgm.hgt_no=@hgt_no.to_i
              frgm.hgt_type = @hgt_fragm_type

              frgm.from_subtree=@from_subtree
              #update nb of source gi-s
              frgm.from_cnt = @from_subtree.split(",").length

              frgm.to_subtree=@to_subtree
              frgm.to_cnt = @to_subtree.split(",").length
              frgm.bs_val=@bs_val.to_f
              frgm.weight_direct=@weight_direct
              frgm.weight_inverse=@weight_inverse
               
              frgm.save
            end
               
          else
            #puts ln
          end

            


        }
      }
    end
    
        
    
 
  end

  def contin_half

    #anyway id check is futile
    #contin table always contains only active half gene
    iterations = HgtComIntContin.select(:iter_no).where("gene_id = ?",@gene.id).order(:iter_no).map { |c| c.iter_no }.uniq
    iterations.each { |it|
      puts it.inspect
      puts "read database fragments to update"
      current_fragms = HgtComIntContin.select("hgt_no,to_subtree").where("gene_id = ? and iter_no = ?", @gene.id, it).order(:hgt_no)
      next_fragms = HgtComIntContin.select("id,hgt_no,from_subtree").where("gene_id = ? and iter_no > ?", @gene.id, it).order("iter_no,hgt_no")
        
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

    
  end
 
  def linearize_half
    
   
    #fragms = HgtComIntFragm.where("bs_val >= ?", 40).order("id asc")

    #all fragments from contin table
    #always half gene
    fragms = HgtComIntContin.order("id asc")
    
    puts "fragments to linearize: #{fragms.count}"
          
    cnt = 0
    fragms.each {|fr|
      cnt += 1
      puts "#{fr.id}"

      from_subtree = fr.from_subtree
      to_subtree = fr.to_subtree
      
      all_s1 = from_subtree.split(",").collect {|x| x.chomp.lstrip}
      all_s2 = to_subtree.split(",").collect {|x| x.chomp.lstrip}
      all_s = (all_s1.sort + all_s2.sort).uniq
      all_subtree = all_s.join(",")

      #cache age for transfer insertion
      age = {}

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
          
          
          
          
          #when timing needed 
          if @timing_needed == true
            age[[@timing_criter_id, stat]] = get_java_mrca_age(timed_tr_dated_f(:res,stat,:nwk), all_subtree, stat)
          else
            #when no timing needed 
            age[[@timing_criter_id, stat]] = 0
          
          end
          
          puts "age[[#{@timing_criter_id}, #{stat}]]: #{age[[@timing_criter_id, stat]]}"
        }

       

      } #end timing method



      farr = from_subtree.split(",").collect{|x| x.lstrip}
      tarr = to_subtree.split(",").collect{|x| x.lstrip}
      puts "#{farr.inspect},#{tarr.inspect}"

      tr_nb = farr.size * tarr.size
      farr.each {|src|
        tarr.each {|dst|
          hcit = HgtComIntTransfer.new
          hcit.source_id = src
          hcit.dest_id = dst
          
          hcit.hgt_com_int_fragm_id = fr.hgt_com_int_fragm_id
          hcit.weight = fr.weight/tr_nb.to_f
          hcit.confidence = fr.bs_val
          hcit.save

          #update timing information
          #in separate table
          [:beast,:treepl].each {|tm|
            #[:treepl].each {|tm|
            #[:beast].each {|tm|
            self.timing_prog = tm
            hctt = HgtComTrsfTiming.new
            hctt.timing_criter_id = @timing_criter_id
            hctt.hgt_com_int_transfer_id = hcit.id


            puts "hcit.weight: #{hcit.weight}"
            puts " age[[#{@timing_criter_id},#{:med}]]: #{ age[[@timing_criter_id,:med]]}"
            hctt.age_md_wg = age[[@timing_criter_id,:med]] * hcit.weight
            hctt.age_hpd5_wg = age[[@timing_criter_id,:hpd5]] * hcit.weight if tm == :beast
            hctt.age_hpd95_wg = age[[@timing_criter_id,:hpd95]] * hcit.weight if tm == :beast
            hctt.age_orig_wg = age[[@timing_criter_id,:orig]] * hcit.weight if tm == :beast
            hctt.save

            #puts "hcit: #{hcit.inspect}"
          }
         
        }
      }

      

    }

  end

  
  def elim_trivial_intra

    #eliminate transfers
    @conn.execute \
      "delete from HGT_COM_INT_TRANSFERS htx
      where htx.id in (select ht.id
                       from hgt_com_int_transfers ht
                        left join HGT_COM_INT_FRAGMS hf on hf.ID = ht.HGT_COM_INT_FRAGM_ID
                        left join NCBI_SEQS ns_src on ns_src.id = ht.SOURCE_ID
                        left join TAXON_GROUPS tg_src on tg_src.TAXON_ID = ns_src.TAXON_ID
                        left join NCBI_SEQS ns_dest on ns_dest.id = ht.DEST_ID
                        left join TAXON_GROUPS tg_dest on tg_dest.ID = ns_dest.TAXON_ID
                       where tg_src.PROK_GROUP_ID = tg_dest.PROK_GROUP_ID and
                             hf.HGT_TYPE = 'Trivial')"
    #eliminate fragments not having any usefull transfer
    @conn.execute <<-EOF
delete from HGT_COM_INT_FRAGMS
where id not in (
 select distinct hcif.ID
 from HGT_COM_INT_FRAGMS hcif
 join HGT_COM_INT_TRANSFERS hcit on hcit.HGT_COM_INT_FRAGM_ID = hcif.ID
 )
    EOF
   
  end
  

  def elim_trivial_intra_useless
=begin
    @conn.execute \
      "delete from HGT_COM_INT_TRANSFERS htx
      where htx.id in (select ht.id
                       from hgt_com_int_transfers ht
                        left join HGT_COM_INT_FRAGMS hf on hf.ID = ht.HGT_COM_INT_FRAGM_ID
                        left join NCBI_SEQS ns_src on ns_src.id = ht.SOURCE_ID
                        left join TAXON_GROUPS tg_src on tg_src.TAXON_ID = ns_src.TAXON_ID
                        left join PROK_GROUPS pg_src on pg_src.ID = tg_src.PROK_GROUP_ID
                        left join GROUP_CRITERS gc_src on gc_src.ID = pg_src.GROUP_CRITER_ID
                        left join NCBI_SEQS ns_dest on ns_dest.id = ht.DEST_ID
                        left join TAXON_GROUPS tg_dest on tg_dest.TAXON_ID = ns_dest.TAXON_ID
                        left join PROK_GROUPS pg_dest on pg_dest.ID = tg_dest.PROK_GROUP_ID
                        left join GROUP_CRITERS gc_dest on gc_dest.ID = pg_dest.GROUP_CRITER_ID
                       where tg_src.PROK_GROUP_ID = tg_dest.PROK_GROUP_ID and
                             hf.HGT_TYPE = 'Trivial' and
                             gc_src.NAME = '#{@crit}' and
                             gc_dest.NAME = '#{@crit}')"
 
=end      
  end

  
  
  
  
  def prepare_hgt_com_gene_groups_vals_old()
    
    arGeneGroupsVal.delete_all
    puts "#{arGeneGroupsVal.table_name} deleted..."
    
    #@conn.execute "delete from HGT_COM_GENE_GROUPS_VALS"

    @conn.execute \
      "insert into hgt_com_gene_groups_vals 
      (gene_id,PROK_GROUP_source_id,prok_group_dest_id,val)
      select  hcf.GENE_ID,
              tg_src.PROK_GROUP_ID,
              tg_dest.PROK_GROUP_ID,
              sum(ht.weight) as weight
      from HGT_COM_INT_TRANSFERS ht
        join HGT_COM_INT_FRAGMS hcf on hcf.ID = ht.HGT_COM_INT_FRAGM_ID
        join NCBI_SEQS ns_src on ns_src.id = ht.SOURCE_ID
        join TAXON_GROUPS tg_src on tg_src.TAXON_ID = ns_src.TAXON_ID
        join NCBI_SEQS ns_dest on ns_dest.id = ht.DEST_ID
        join TAXON_GROUPS tg_dest on tg_dest.TAXON_ID = ns_dest.TAXON_ID
      group by tg_src.PROK_GROUP_ID,
               tg_dest.PROK_GROUP_ID,
               hcf.GENE_ID
      order by tg_src.PROK_GROUP_ID,
               tg_dest.PROK_GROUP_ID,
               hcf.GENE_ID"
     
     
    puts "#{arGeneGroupsVal.name} inserted..."
    
    
  end
  
  
  
  def prepare_hgt_com_trsf_taxons()
    
    @conn.execute \
      "truncate table hgt_com_trsf_taxons"
    
    puts "hgt_com_trsf_taxons table truncated..."
    
    
    @conn.execute \
      "insert into HGT_COM_TRSF_TAXONS
      (gene_id,txsrc_id,txdst_id,weight_tr_tx,age_md_wg_tr_tx)
     select hcf.gene_id,
       ns_src.TAXON_ID,
       ns_dest.TAXON_ID,
       sum(ht.weight),
       sum(ht.age_md_wg)
     from HGT_COM_INT_TRANSFERS ht
     join HGT_COM_INT_FRAGMS hcf on hcf.ID = ht.HGT_COM_INT_FRAGM_ID
     join NCBI_SEQS ns_src on ns_src.id = ht.SOURCE_ID
     join NCBI_SEQS ns_dest on ns_dest.id = ht.DEST_ID
     group by hcf.gene_id,
              ns_src.TAXON_ID,
              ns_dest.TAXON_ID
     order by hcf.gene_id,
              ns_src.TAXON_ID,
              ns_dest.TAXON_ID"
     
     
    puts "hgt_com_trsf_taxons table inserted..."
    
    
  end
  
  def prepare_hgt_com_qfunc_trsf_taxons()
    
    @conn.execute \
      "truncate table hgt_com_trsf_taxons"
    
    puts "hgt_com_trsf_taxons table truncated..."
    
    
    @conn.execute \
      "insert into HGT_COM_TRSF_TAXONS
      (gene_id,txsrc_id,txdst_id,weight_tr_tx)
     select hqt.GENE_ID,
            ns_src.TAXON_ID,
            ns_dest.TAXON_ID,
       sum(val)
     from HGT_QFUNC_TRANSFERS hqt
      join NCBI_SEQS ns_src on ns_src.id = hqt.SOURCE_ID
      join NCBI_SEQS ns_dest on ns_dest.id = hqt.DEST_ID
     group by hqt.GENE_ID,
              ns_src.TAXON_ID,
              ns_dest.TAXON_ID
     order by hqt.GENE_ID,
              ns_src.TAXON_ID,
              ns_dest.TAXON_ID"
     
     
    puts "hgt_com_trsf_taxons table inserted..."
    
    
  end
  
  
  #distributes transfers according to taxon_group classification
  #only inter group transfers for each group criter are taken into account
  #
  def prepare_hgt_com_trsf_prkgrs_old()
    
    @conn.execute \
      "truncate table hgt_com_trsf_prkgrs"
    
    puts "hgt_com_trsf_prkgrs table truncated..."
      
    #
    sql = "select id,
                   gene_id,
                   TXSRC_ID,
                   TXDST_ID,
                   WEIGHT_TR_TX
            from HGT_COM_TRSF_TAXONS"
     
    #puts "sql: #{sql}"
    
      
    tr_taxons =  HgtComTrsfTaxon.find_by_sql(sql)
   
    tr_taxons.each {|tr|
     

      #debugging
      #next unless tr.gene_id == 111 and tr.txsrc_id == 768679 and tr.txdst_id == 374847
          
      #puts "tr: #{tr.inspect}"
      #puts "tr.id: #{tr.id}, #{tr.gene_id}"
     
      #for each chiteria
      (0..1).each {|crit|
        
        #for each criteria and
        #for each source and destination prok groups
        sql = "select tg.PROK_GROUP_ID,
                      tg.WEIGHT_PG
               from TAXON_GROUPS tg 
                join PROK_GROUPS pg on pg.id = tg.PROK_GROUP_ID
               where tg.TAXON_ID = #{tr.txsrc_id} and
                     pg.GROUP_CRITER_ID = #{crit}"
        #puts "sql: \n #{sql}"
      
        pg_src = TaxonGroup.find_by_sql(sql)
      
        
        sql = "select tg.PROK_GROUP_ID,
                      tg.WEIGHT_PG
               from TAXON_GROUPS tg 
                join PROK_GROUPS pg on pg.id = tg.PROK_GROUP_ID
               where tg.TAXON_ID = #{tr.txdst_id} and
                     pg.GROUP_CRITER_ID = #{crit}"
        #puts "sql: \n #{sql}"
      
        pg_dst = TaxonGroup.find_by_sql(sql)
      
        pg_src.each {|src|
          pg_dst.each {|dst|
            
            #puts "src: #{src.inspect}"
            #puts "dst: #{dst.inspect}"
            
            #insert alternative
            prkg = HgtComTrsfPrkgr.new 
            prkg.gene_id = tr.gene_id
            prkg.hgt_com_trsf_taxon_id = tr.id
            prkg.pgsrc_id = src.prok_group_id
            prkg.pgdst_id = dst.prok_group_id
            prkg.weight_tr_pg = tr.weight_tr_tx * src.weight_pg * dst.weight_pg
            prkg.save
            
            #prkg.gene_id = tr.gene_id 
            #prkg.save
            
            
          }
        }
        
        
        
        
   
      }  
    }
   
    
  end
  
  
  
  

  def transfer_groups
  
    #recreate recomb_transfer_groups   
    arTransferGroup.delete_all
    sleep 10

 
    #insert all prokaryotes groups
    @conn.execute "insert into hgt_com_int_transfer_groups
                    (prok_group_source_id,prok_group_dest_id)
                    select pg1.ID,pg2.id
                    from PROK_GROUPS pg1
                     cross join PROK_GROUPS pg2 
                    order by pg1.id,
                             pg2.id"
    # transfers are already filtered by threshold  
    #where ht.confidence >= #{@thres} and
    #by Regular / Trivial
    #denormalize regular transfers as regular_cnt
    @conn.execute "update hgt_com_int_transfer_groups htg
                   set htg.cnt =  select sum(ht.weight)
                   from hgt_com_int_transfers ht
                    left join HGT_COM_INT_FRAGMS hf on hf.ID = ht.HGT_COM_INT_FRAGM_ID
                    left join NCBI_SEQS ns_src on ns_src.id = ht.SOURCE_ID
                    left join TAXON_GROUPS tg_src on tg_src.TAXON_ID = ns_src.TAXON_ID  
                    left join NCBI_SEQS ns_dest on ns_dest.id = ht.DEST_ID
                    left join TAXON_GROUPS tg_dest on tg_dest.TAXON_ID = ns_dest.TAXON_ID
                   where tg_src.PROK_GROUP_ID = htg.prok_group_source_id and
                         tg_dest.PROK_GROUP_ID = htg.prok_group_dest_id
                   group by tg_src.PROK_GROUP_ID,
                           tg_dest.PROK_GROUP_ID"
     
    
      
    @conn.execute "update hgt_com_int_transfer_groups
                    set cnt=nvl(cnt,0)"

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
    
    case @crit  
    when :family
      @custom_configs[[:all,"raxml",50, :abs]] = [410 - 5 + 5 ,140] #
      @custom_configs[[:all,"raxml",50, :rel]] = [410 + 30 ,140] #
    
      @custom_configs[[:all,"raxml",75, :abs]] = [410 - 25 + 5 ,140] #
      @custom_configs[[:all,"raxml",75, :rel]] = [410 + 10 ,140] #
    
      @custom_configs[[:all,"phyml",50, :abs]] = [410 - 5 + 5,140]
      @custom_configs[[:all,"phyml",50, :rel]] = [410 + 30 ,140]
    
      @custom_configs[[:all,"phyml",75, :abs]] = [410 - 25 + 5,140]
      @custom_configs[[:all,"phyml",75, :rel]] = [410 + 10 ,140]
    
      @custom_configs[[:regular,"raxml",50, :abs]] = [410 - 20 + 5,140] #
      @custom_configs[[:regular,"raxml",50, :rel]] = [410 + 20 ,140] #
      
      #most restrictive
      @custom_configs[[:regular,"raxml",75, :abs]] = [410 - 30 + 5,140] #370
      
      @custom_configs[[:regular,"raxml",75, :rel]] = [425 , 130, 100 ] #10 max
    
      @custom_configs[[:regular,"phyml",50, :abs]] = [410 - 20 + 5,140]
      @custom_configs[[:regular,"phyml",50, :rel]] = [410 + 20 ,140]
      @custom_configs[[:regular,"phyml",75, :abs]] = [410 - 30 + 5,140] 
      @custom_configs[[:regular,"phyml",75, :rel]] = [410 + 10 ,140]  
    when :habitat
      @custom_configs[[:all,"raxml",50, :abs]] = [250 ,100] 
      @custom_configs[[:all,"raxml",50, :rel]] = [250 ,100] 
    
      @custom_configs[[:all,"raxml",75, :abs]] = [250 ,100] 
      @custom_configs[[:all,"raxml",75, :rel]] = [210 ,70] 
    
      @custom_configs[[:all,"phyml",50, :abs]] = [250 ,100] 
      @custom_configs[[:all,"phyml",50, :rel]] = [250 ,100] 
    
      @custom_configs[[:all,"phyml",75, :abs]] = [250 ,100] 
      @custom_configs[[:all,"phyml",75, :rel]] = [250 ,100] 
    
      @custom_configs[[:regular,"raxml",50, :abs]] = [250 ,100] 
      @custom_configs[[:regular,"raxml",50, :rel]] = [250 ,100] 
      
      #most restrictive
      @custom_configs[[:regular,"raxml",75, :abs]] = [220 ,80, 550] #120
      
      @custom_configs[[:regular,"raxml",75, :rel]] = [215 , 70 , 2] #0.315
    
      @custom_configs[[:regular,"phyml",50, :abs]] = [250 ,100] 
      @custom_configs[[:regular,"phyml",50, :rel]] = [250 ,100] 
      @custom_configs[[:regular,"phyml",75, :abs]] = [250 ,100] 
      @custom_configs[[:regular,"phyml",75, :rel]] = [250 ,100] 
    end
    
    querry_arr = [@hgt_type, @phylo_prog, @thres, @calc_type] 
    #puts "qer_arr: #{querry_arr.inspect}"
    #puts "@custom_configs: #{@custom_configs.inspect}"
    @config = @custom_configs[querry_arr]

    
  end
  
  
  
  
  def leaf_transf_cnt()
    return HgtComIntTransfer.count
    
  end
  
  def calc_global_hgt_rate
    
    trsf_all_sum = 0.0
    trsf_all_cnt = 0.0
    trsf_all_rate = 0.0
    
    @genes.each { |gn|
      #next if gn.id != 174
      
      #fetch nb of transfers
      sql = "select  sum(ht.weight) as weight
             from HGT_COM_INT_TRANSFERS ht
              join HGT_COM_INT_FRAGMS hcf on hcf.ID = ht.HGT_COM_INT_FRAGM_ID
             where gene_id = #{gn.id}"
   
      trsfs = @conn.select_all sql
       
      
      trsf_cnt = trsfs.first["weight"].to_f
      
      
      #fetch nb of ncbi_seqs
      sql = "select count(*) as cnt
             from GENE_BLO_SEQS
             where gene_id = #{gn.id}"
   
      seqs_cnt = @conn.select_all(sql).first["cnt"].to_f
     
      #val_one = trsf_cnt * seqs_cnt 
      #val_one = trsf_cnt 
      trsf_all_sum += trsf_cnt
      trsf_all_cnt += seqs_cnt
      
      puts "trsf_cnt: #{trsf_cnt}, seqs_cnt: #{seqs_cnt}"
      
      
    }
    
    trsf_all_rate = trsf_all_sum / trsf_all_cnt
    #puts "trsf_all_cnt: #{trsf_all_cnt}, trsf_all_sum: #{trsf_all_sum}, trsf_all_rate: #{trsf_all_rate}"
    #trsf_all_rate /= @genes.count
    #
    puts "trsf_all_cnt: #{trsf_all_cnt}, trsf_all_sum: #{trsf_all_sum}, trsf_all_rate: #{trsf_all_rate}"
    
      
  end

  def test
    puts "ok: "
    
    sql2 = HgtComIntTransfer \
      .joins(:hcf, [{:ns_src => {:taxon => :taxon_group}},{:ns_dest => {:taxon => :taxon_group}}] ) \
      .where(:hcf => {:gene_id => 111}) \
      .to_sql
         
    # :posts => [{:comments => :guest}, :tags]
    #.joins( ) \
    #.joins(:ns_dest => :taxon) \
         
    
    #sql2 = HgtComIntTransfer.joins(:hgt_com_int_fragm).to_sql
    puts "sql2: #{sql2}"
    
    #sql3 = HgtComIntTransfer.fragments.to_sql
    #puts "sql3: #{sql3}"
    
    
    
  end
  
  
  #configurations
  def qfunc_prog_d
    Pathname.new "~/devel/PROJ_CPP/hgt-qfunc5"
  end
  
  def qfunc_prog
    qfunc_prog_d + "hgt-qfunc-deb"
  end
      
  def qfunc_work_d 
    Pathname.new "/root/devel/proc_hom/db/exports/hgt-qfunc"
  end
      
      
  def qfunc_gr_seq_csv_f
    qfunc_work_d + "gr-seq-df-#{@gene.name}-#{@gene.id}.csv"
  end
   
  def qfunc_msa_fasta_d
    Pathname.new "/root/devel/files_srv/db_files/proc_hom/hgt-com-110/gene_blo_seqs_msa/fasta"
  end
      
  def qfunc_msa_fasta_f
    qfunc_msa_fasta_d + "#{@gene.name}.fasta"
  end
    
  def q_func_hgts_csv_f
    qfunc_work_d + "hgt-q-funcs-#{@gene.name}-#{@gene.id}.csv"
  end
  
  #get alignement length
  def qfunc_align_len 
    @conn.select_rows( sql=<<-END
    select gbr.BLOCKS_LENGTH
from GENE_BLO_RUNS gbr
where gbr.GENE_ID = #{@gene.id}
      END
    )[0][0].to_i
  end
  
  def qfunc_f_opt_max
    @qfunc_f_opt_max
  end
  
  def qfunc_f_opt_max=val
    @qfunc_f_opt_max=val
  end
  
  
  def load_hgt_q_funcs()
    puts "in load_hgt_q_funcs..."
  
    #select and order pairs
    #csvf_f = "/root/devel/PROJ_CPP/hgt-qfunc5/q-func-hgt-trsfs.csv"  #exp_d(:csv) + "#{tt_base_name}.csv"
    #puts "csvf_f: #{csvf_f}"
        
    #q_func_hgts = CSV.read(csvf_f)
    q_func_hgts = CSV.read(q_func_hgts_csv_f)
    
    heads = q_func_hgts.shift
        
    #puts "load_q_func_hgts: #{q_func_hgts.inspect}"
       
    HgtQfunc.delete_all
    HgtObjAll.delete_all
     
       
    q_func_hgts.each { |qfunc_row|
      
      src_id = qfunc_row[8]
      dst_id = qfunc_row[9]
      
      if src_id.to_i > dst_id.to_i
        src_id, dst_id = dst_id, src_id
        
      end
      
      
      
      #puts "src_id: #{src_id}, dst_id: #{dst_id}"
      
      #insert into alls
      
      #hoa = HgtObjAll.new
      #hoa.source_id = src_id
      #hoa.dest_id = dst_id
      #hoa.save
      @load_hgt_q_funcs_01_pstmt.set_int(1,src_id.to_i)
      @load_hgt_q_funcs_01_pstmt.set_int(2,dst_id.to_i)
      @load_hgt_q_funcs_01_pstmt.add_batch()
      
      #qf = HgtQfunc.new
      #qf.gene_id = @gene.id
      #qf.source_id = src_id
      #qf.dest_id = dst_id
      #qf.val = qfunc_row[10].to_f
      #qf.conf = qfunc_row[11].to_f
      #qf.save
      
      @load_hgt_q_funcs_02_pstmt.set_int(1,@gene.id.to_i)
      @load_hgt_q_funcs_02_pstmt.set_int(2,src_id.to_i)
      @load_hgt_q_funcs_02_pstmt.set_int(3,dst_id.to_i)
      @load_hgt_q_funcs_02_pstmt.set_double(4,qfunc_row[10].to_f)
      @load_hgt_q_funcs_02_pstmt.set_double(5,qfunc_row[11].to_f)
      @load_hgt_q_funcs_02_pstmt.add_batch()
      
      
    }
    
    @load_hgt_q_funcs_01_pstmt.execute_batch()
    @load_hgt_q_funcs_02_pstmt.execute_batch()
     
    
   
    
    #order and rank
    
    order_by_cond = case self.sim_order_by
    when :pvals
      " order by min(hq.conf) asc,
            sum(hq.VAL) desc "
    when :vals
      " order by sum(hq.VAL) desc,
            min(hq.conf) asc "
    end
    
    sql=<<-END
select hq.gene_id,
       hq.source_id,
       hq.dest_id,
       sum(hq.VAL) as val,
       min(hq.conf) as conf
from HGT_QFUNCS hq
--where hq.conf between 0.0000000000001 and 0.999
where hq.conf < #{self.sim_max_pval}
group by hq.gene_id,
       hq.source_id,
       hq.dest_id
#{order_by_cond}
limit #{self.sim_rows_limit}
    END

    #order by max(hq.conf) asc,
    #        sum(hq.VAL) desc


    tab = HgtQfunc.find_by_sql(sql)
        
    HgtQfunc.delete_all
    
    loc_conf = 0.0
    loc_val = 0.0
    loc_rank = 0
    
    tab.each { |row|
      
      
      qf = HgtQfunc.new
      #puts "row: #{row.inspect}"
 
    
      qf.gene_id = @gene.id
      qf.source_id = row.source_id
      qf.dest_id = row.dest_id
      qf.val = row.val
      qf.conf = row.conf
      
      #different (source_id,dest_id) with same (val,conf) get same rank
      if row.val != loc_val or row.conf != loc_conf
        loc_rank += 1
        loc_val = row.val
        loc_conf = row.conf
      end
      
      qf.rank = loc_rank
      
      qf.save
    
    }       
        
         
    
  end
  
    
  def bring_hgt_detects
    #hgt-detects
    puts "in bring_hgt_detects..."
    #select and order pairs
=begin    
    sql=<<-END
 select hcif.GENE_ID,
       hcit.SOURCE_ID,
       hcit.DEST_ID,
--       tg_src.PROK_GROUP_ID,
--       tg_dst.PROK_GROUP_ID,
--       ggc_src.CNT,
--       ggc_dst.cnt,
       hcit.WEIGHT,
       hcit.CONFIDENCE,
	     hcif.FROM_CNT,
       hcif.TO_CNT,
       hcif.FROM_SUBTREE,
       hcif.TO_SUBTREE
from HGT_COM_INT_TRANSFERS hcit
  join HGT_COM_INT_FRAGMS hcif on hcit.HGT_COM_INT_FRAGM_ID = hcif.id
  join NCBI_SEQS ns_src on ns_src.id = hcit.SOURCE_ID
  join NCBI_SEQS ns_dest on ns_dest.id = hcit.DEST_ID
  join TAXON_GROUPS tg_src on tg_src.TAXON_ID = ns_src.TAXON_ID
  join TAXON_GROUPS tg_dst on tg_dst.TAXON_ID = ns_dest.TAXON_ID
  join GENE_GROUP_CNTS ggc_src on ggc_src.gene_id = hcif.GENE_ID and
                                  ggc_src.PROK_GROUP_ID = tg_src.PROK_GROUP_ID
  join GENE_GROUP_CNTS ggc_dst on ggc_dst.gene_id = hcif.GENE_ID and
                                  ggc_dst.PROK_GROUP_ID = tg_dst.PROK_GROUP_ID
where hcif.GENE_ID = #{@gene.id} and
      tg_src.PROK_GROUP_ID != tg_dst.PROK_GROUP_ID and
      ggc_src.CNT > 1 and
      ggc_dst.cnt > 1 and
      hcif.FROM_CNT = 1 and
      hcif.TO_CNT = 1 and
      tg_src.PROK_GROUP_ID between 0 and 22 and
      tg_dst.PROK_GROUP_ID between 0 and 22     
    END
=end    
    
    sql=<<-END
 select hcif.GENE_ID,
       hcit.SOURCE_ID,
        hcit.DEST_ID,
        hcit.WEIGHT,
       hcit.CONFIDENCE,
	  hcif.FROM_CNT,
       hcif.TO_CNT,
       hcif.FROM_SUBTREE,
       hcif.TO_SUBTREE,
       hctt.AGE_MD_WG
from HGT_COM_INT_TRANSFERS hcit
  join HGT_COM_TRSF_TIMINGS hctt on hctt.HGT_COM_INT_TRANSFER_ID = hcit.ID and
                                    hctt.TIMING_CRITER_ID = 0
  join HGT_COM_INT_FRAGMS hcif on hcit.HGT_COM_INT_FRAGM_ID = hcif.id
  join NCBI_SEQS ns_src on ns_src.id = hcit.SOURCE_ID
  join NCBI_SEQS ns_dest on ns_dest.id = hcit.DEST_ID
  join TAXON_GROUPS tg_src on tg_src.TAXON_ID = ns_src.TAXON_ID
  join TAXON_GROUPS tg_dst on tg_dst.TAXON_ID = ns_dest.TAXON_ID
  join GENE_GROUP_CNTS ggc_src on ggc_src.gene_id = hcif.GENE_ID and
                                  ggc_src.PROK_GROUP_ID = tg_src.PROK_GROUP_ID
  join GENE_GROUP_CNTS ggc_dst on ggc_dst.gene_id = hcif.GENE_ID and
                                  ggc_dst.PROK_GROUP_ID = tg_dst.PROK_GROUP_ID 
where hcif.GENE_ID = #{@gene.id} and
--      hctt.AGE_MD_WG >= 50.0 and
      tg_src.PROK_GROUP_ID != tg_dst.PROK_GROUP_ID and
      ggc_src.CNT > 1 and
      ggc_dst.cnt > 1 and
      tg_src.PROK_GROUP_ID between 0 and 22 and
      tg_dst.PROK_GROUP_ID between 0 and 22
    END
    
    hgt_detects = HgtDetect.find_by_sql(sql)
        
    HgtDetect.delete_all

    nb_rows = 0
    
    hgt_detects.each { |row|
      
      #puts "row: #{row.inspect}"
    
      #hd = HgtDetect.new
      @bring_hgt_detects_01_pstmt.set_int(1,@gene.id.to_i)
      
      #hd.gene_id = @gene.id
      
      if row.source_id.to_i > row.dest_id.to_i
        #puts "bigger"
        @bring_hgt_detects_01_pstmt.set_int(2,row.dest_id.to_i)
        @bring_hgt_detects_01_pstmt.set_int(3,row.source_id.to_i)
        #hd.source_id = row.dest_id.to_i
        #hd.dest_id = row.source_id.to_i
      
      else
        #puts "lower"
        #hd.source_id = row.source_id.to_i
        #hd.dest_id = row.dest_id.to_i
        @bring_hgt_detects_01_pstmt.set_int(2,row.source_id.to_i)
        @bring_hgt_detects_01_pstmt.set_int(3,row.dest_id.to_i)
        
      
      end
      
      @bring_hgt_detects_01_pstmt.set_double(4,row.weight.to_f)
      @bring_hgt_detects_01_pstmt.set_double(5,row.confidence.to_f)
      @bring_hgt_detects_01_pstmt.set_int(6,row.from_cnt.to_f)
      @bring_hgt_detects_01_pstmt.set_int(7,row.to_cnt.to_f)
      
      
      #String s = (String) obj;
      #str = JavaString.new row.from_subtree
      #str_reader = JavaStringReader.new str
      
      #stringReader = new StringReader(s);
      #stmt.setCharacterStream(i + 1, stringReader , s.length());
      #@bring_hgt_detects_01_pstmt.setCharacterStream(8, str_reader , str.length())
      @bring_hgt_detects_01_pstmt.set_string(8,"")
      
      #str = JavaString.new row.to_subtree
      #str_reader = JavaStringReader.new str
      
      
      #@bring_hgt_detects_01_pstmt.setCharacterStream(9, str_reader , str.length())
      @bring_hgt_detects_01_pstmt.set_string(9,"")
      
      nb_rows += 1
      @bring_hgt_detects_01_pstmt.add_batch()
      
      #hd.val = row.weight
      #hd.conf = row.confidence
      #hd.from_cnt = row.from_cnt
      #hd.to_cnt = row.to_cnt
      #hd.from_subtree = row.from_subtree
      #hd.to_subtree = row.to_subtree
      
      
      #hd.save
      
    } 
    
    if nb_rows > 0
      @bring_hgt_detects_01_pstmt.execute_batch()
      nb_rows=0
    end
    
    @jdbc_conn.commit
    
    
    
    #order and rank
=begin    
    sql=<<-END
select hd.gene_id,
       hd.source_id,
       hd.dest_id,
       sum(hd.VAL) as val,
       max(hd.conf) as conf
from HGT_DETECTS hd
where hd.from_cnt = 1 and
      hd.to_cnt = 1
group by hd.gene_id,
       hd.source_id,
       hd.dest_id
order by max(hd.conf) desc,
         sum(hd.VAL) desc
    END
=end  
    
    sql=<<-END
select hd.gene_id,
       hd.source_id,
       hd.dest_id,
       sum(hd.VAL) as val,
       max(hd.conf) as conf
from HGT_DETECTS hd
group by hd.gene_id,
       hd.source_id,
       hd.dest_id
order by sum(hd.VAL) desc
limit 500
    END
    
    hgt_detects = HgtDetect.find_by_sql(sql)
        
    HgtDetect.delete_all

     
    loc_conf = 0.0
    loc_val = 0.0
    loc_rank = 0
    hgt_detects.each { |row|
      
      #puts "row: #{row.inspect}"
    
      hd = HgtDetect.new
      
      hd.gene_id = @gene.id
      hd.source_id = row.source_id
      hd.dest_id = row.dest_id
      hd.val = row.val
      hd.conf = row.conf
      
      #different (source_id,dest_id) with same (val,conf) get same rank
      if row.val != loc_val or row.conf != loc_conf
        loc_rank += 1
        loc_val = row.val
        loc_conf = row.conf
      end
      
      hd.rank = loc_rank
      
      hd.save
      
      
    } 
    
    
    
  end
  
  def fusion_hgt_objs
    
    sql=<<-END
    select hq.source_id,
       hq.DEST_ID
from HGT_QFUNCS hq
union
select hd.source_id,
       hd.dest_id
from HGT_DETECTS hd
    END
    
    tab = HgtObj.find_by_sql(sql)
        
    HgtObj.delete_all
    
     
    tab.each { |row|
      
      
      rw = HgtObj.new
      #puts "row: #{row.inspect}"
 
    
      rw.source_id = row.source_id
      rw.dest_id = row.dest_id
       
      rw.save
    
    }       
    
    
    
  end
  
  
  def calc_power_stats
    
    sql=<<-END
select count(*) as cnt
 from HGT_POS_TRUE
    END
    
    tab = HgtObj.find_by_sql(sql)
    
    true_pos = tab.first.cnt.to_f
    
   
    
    false_pos = @conn.select_rows( sql=<<-END
 select count(*) as cnt
 from HGT_POS_FALSE
      END
    )[0][0].to_f

    
    true_neg = @conn.select_rows( sql=<<-END
 select count(*)
 from HGT_NEG_TRUE
      END
    )[0][0].to_f
        
    
    false_neg = @conn.select_rows( sql=<<-END
 select count(*)
 from HGT_NEG_FALSE
      END
    )[0][0].to_f
    
    #    tab = @conn.select_rows(sql)
    
    #false_pos = tab
    
    puts "true_pos: #{true_pos}, false_pos: #{false_pos}, true_neg: #{true_neg}, false_neg: #{false_neg}"
    
    hgt_pos = true_pos + false_neg
    hgt_neg = false_pos + true_neg
    
    qfu_pos = true_pos + false_pos
    qfu_neg = true_neg + false_neg
    
    puts "hgt_pos: #{hgt_pos}, qfu_pos: #{qfu_pos}, hgt_neg: #{hgt_neg}, qfu_neg: #{qfu_neg}"
    
    
    
    #Sensitivity = TP / (TP + FN)
    sensit = true_pos / hgt_pos
    sensit = -1 unless sensit.finite?
    
    #Specificity = TN / (FP + TN)
    specif = true_neg / hgt_neg
    specif = -1 unless specif.finite?
    
    
    #Positive predictive value = TP / (TP + FP)
    ppv = true_pos / (true_pos + false_pos)
    ppv = -1 unless ppv.finite?
    
    #Negative predictive value = TN / (FN + TN)
    npv = true_neg / (false_neg + true_neg)
    npv = -1 unless npv.finite?
    
    
    #Likelihood ratio positive = sensitivity / (1 − specificity)
    lrt_pos = sensit / (1 - specif)
    lrt_pos = 0.0 unless lrt_pos.finite?
    
    #Likelihood ratio negative = (1 − sensitivity) / specificity
    lrt_neg = (1- sensit) /specif
    lrt_neg = 0.0 unless lrt_neg.finite?
    
    puts "sensit: #{ "%5.3f" % sensit}, specif: #{"%5.3f" %  specif}, ppv: #{"%5.3f" % ppv}, npv: #{"%5.3f" % npv}"
    puts "lrt_pos: #{"%5.3f" % lrt_pos}, lrt_neg: #{"%5.3f" % lrt_neg}"
    
    hqs = HgtQfuncStat.new
    hqs.hgt_qfunc_cond_id = qfunc_f_opt_max
    hqs.gene_id = @gene.id
    hqs.true_pos = true_pos
    hqs.false_pos = false_pos
    hqs.true_neg = true_neg
    hqs.false_neg = false_neg
    hqs.sensit = sensit
    hqs.specif = specif
    hqs.ppv = ppv
    hqs.npv = npv
    hqs.lrt_pos = lrt_pos
    hqs.lrt_neg = lrt_neg
    hqs.save
    
  end
  
  
  
  def calc_hgt_q_func_genes
   
    cnt = 0
   
    #prepare R connection
    #export groups
    c=Rserve::Connection.new

    
    str=<<-EOF
rm(list=ls(all=TRUE))
library(MASS)
Sys.setenv(JAVA_HOME='/usr/java/latest/bin')
options(java.parameters="-Xmx1g")
library(rJava)
.jinit()
print(.jcall("java/lang/System", "S", "getProperty", "java.version"))
library(RJDBC)
library(DBI)
setwd("/root")
print(getwd())
drv <- JDBC("org.hsqldb.jdbcDriver","/root/devel/proc_hom/lib/hsqldb.jar", identifier.quote='\"')
conn <- dbConnect(drv, 'jdbc:hsqldb:hsql://localhost:9005/proc_hom', 'SA', '')
    EOF

    #print str
    #execute
    x = c.eval str
    #puts "x: #{x.to_s}"
    
 
    genes.each { |gn|
      cnt += 1
      
      @gene = gn
      next if @gene.name == "rbcL"
      puts "gene: #{@gene.name}, gene_id: #{@gene.id}"
      
      
      
      #execute hgt-qfunc
      
      Dir.chdir(qfunc_work_d)
      
           
      #export groups
      c.assign("gene_id", @gene.id)
      str=<<-EOF
sql <-sprintf("select tg.PROK_GROUP_ID as pgid,
       gbs.NCBI_SEQ_ID as seqid     
from GENE_BLO_SEQS gbs
 join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
 join TAXON_GROUPS tg on tg.TAXON_ID = ns.TAXON_ID
where gbs.GENE_ID = %i
      and tg.PROK_GROUP_ID between 0 and 22
order by  tg.PROK_GROUP_ID,
          gbs.NCBI_SEQ_ID",gene_id)

gr_seq_df <- dbGetQuery(conn, sql)

print(gr_seq_df)
write.csv(gr_seq_df, file = "#{qfunc_gr_seq_csv_f}")
      EOF

      print str
      #execute
      c.void_eval str
      
        
      
      
      exec_s = "#{qfunc_prog} --winl #{qfunc_align_len} --gr-seqs-csv #{qfunc_gr_seq_csv_f} --msa-fasta #{qfunc_msa_fasta_f} --q-func-hgts-csv #{q_func_hgts_csv_f} --f_opt_max #{qfunc_f_opt_max}"
      
      sys exec_s
      
      
    }
    
    c.close

   
   
   
  end
  
  def stat_hgt_q_func_genes
   
    HgtQfuncStat.where(:hgt_qfunc_cond_id => qfunc_f_opt_max).delete_all
    puts "destroyed HgtQfuncStat"
      
 
      
    sql = \
      "insert into hgt_obj_alls
       (source_id,
        dest_id,
        created_at,
        updated_at)
       values
        (?,?,current_timestamp,current_timestamp);"
    
    @load_hgt_q_funcs_01_pstmt = @jdbc_conn.prepare_statement(sql);
    
    sql = \
      "insert into hgt_qfuncs
       (gene_id,
        source_id,
        dest_id,
        val,
        conf,
        created_at,
        updated_at)
       values
        (?,?,?,?,?,current_timestamp,current_timestamp);"
    
    @load_hgt_q_funcs_02_pstmt = @jdbc_conn.prepare_statement(sql);
    
   
    
   
    sql = \
      "insert into hgt_detects
       (gene_id,
        source_id,
        dest_id,
        val,
        conf,
        from_cnt,
        to_cnt,
        from_subtree,
        to_subtree,
        created_at,
        updated_at)
       values
        (?,?,?,?,?,?,?,?,?,current_timestamp,current_timestamp);"
    
    @bring_hgt_detects_01_pstmt = @jdbc_conn.prepare_statement(sql);
    
    
    
    
    #prepare statements
    @jdbc_conn.set_auto_commit(false)
    
    
    
    cnt = 0
   
    genes.each { |gn|
      cnt += 1
      
      @gene = gn
      next if @gene.name == "rbcL"
      puts "gene: #{@gene.name}, gene_id: #{@gene.id}"
      
      
      Dir.chdir(qfunc_work_d)
      
           
       
      #treat one gene
      load_hgt_q_funcs()
     
      bring_hgt_detects()
      fusion_hgt_objs()
      calc_power_stats()
      @jdbc_conn.commit
      
    }
    
    @jdbc_conn.set_auto_commit(true)
     
  end
  
  
  def palmer_d
    Pathname.new "/root/devel/proc_hom/db/palmer_rbcl"
  end
  
  def palmer_qfunc_gr_seq_csv_f
    palmer_d + "csv/gr-seq-df-rbcL-220.csv"
  end
  
  def palmer_row_seqs_f
    palmer_d + "align/row-seqs-rbcL-220.fasta"
  end
  
  def palmer_gblocks_seqs_f
    palmer_d + "align/gblocks-seqs-rbcL-220.fasta"
  end
  
  def palmer_gblocks_phy_f
    palmer_d + "align/gblocks-seqs-rbcL-220.phy"
  end
  
  
  
  def palmer_delete
    
    @conn.execute <<-EOF
delete 
from TAXON_GROUPS tg
where tg.PROK_GROUP_ID in (select pg.id
from GROUP_CRITERS gc
 join PROK_GROUPS pg on pg.GROUP_CRITER_ID = gc.ID
where gc.NAME = 'palmer'
)
    EOF

    @conn.execute <<-EOF
delete
from GENE_BLO_SEQS gbs
where gene_id in (select gn.id
 from genes gn
where gn.NAME = 'rbcL')
    EOF
    
    

  end
  
  
  def palmer_data
    
    
       
    
    #create gene
    gn_o = Gene.find_by_name("rbcL")
    puts "gn_o: #{gn_o}"
    if gn_o.nil?
      gn_o = Gene.new
      gn_o.name = "rbcL"
      gn_o.save
    end
    puts "gn_o: #{gn_o.inspect}"
  
    #create group_criter
    gr_o = GroupCriter.find_by_name("palmer")
    puts "gr_o: #{gr_o}"
    if gr_o.nil?
      gr_o = GroupCriter.new
      gr_o.name = "palmer"
      gr_o.save
    end
    puts "gr_o: #{gr_o.inspect}"
    
    
    ################################################# prok_groups
    
    palmer_groups_csv_f = palmer_d + "csv/rbcL_groups.csv"
    palmer_gr_arr = CSV.read(palmer_groups_csv_f)
    puts "palmer_gr_arr: #{palmer_gr_arr}"
    palmer_gr_arr.shift
    #insert NcbiSeq
    palmer_gr_arr.each {|row|
      
 
      puts "#{row[0]}, #{row[1]}, #{row[2]}"
      
            
      prk_gr = ProkGroup.find_by_abrev_and_group_criter_id(row[2],gr_o.id)
      puts "prk_gr #{prk_gr.inspect}"
      if prk_gr.nil?
        prk_gr = ProkGroup.new
        prk_gr.order_id = row[0]
        prk_gr.name = row[1]
        prk_gr.abrev = row[2]
        prk_gr.group_criter_id = gr_o.id
        prk_gr.save
      end
      
      
      
    }
    
    ################################# palmer arr
    palmer_csv_f = palmer_d + "csv/rbcL_v6.csv"
    palmer_arr = CSV.read(palmer_csv_f)
    #puts "palmer_arr: #{palmer_arr}"
    palmer_arr.shift
   
    
    ################################### taxon_groups
   
    palmer_arr.each {|row|
      
      gr = row[4]
      taxid = row[3]
      
      prk_gr = ProkGroup.find_by_abrev_and_group_criter_id(gr,gr_o.id)
      
      puts "gr: #{gr}, prk_gr.id #{prk_gr.id}, taxid: #{taxid}"
      
      tg_o = TaxonGroup.find_by_prok_group_id_and_taxon_id(prk_gr.id,taxid)
      
      puts "tg_o: #{tg_o.inspect}"
      if tg_o.nil?
        tg_o = TaxonGroup.new
        tg_o.prok_group_id= prk_gr.id
        tg_o.taxon_id = taxid
        tg_o.weight_pg = 1.0
        tg_o.save
      end
      
      
      
      
    }
    
    
    ######################################### ncbi_seqs

   
    
    
    #insert NcbiSeq
    palmer_arr.each {|row|
      
      gi = row[0].to_i
      
      puts "#{gi}, #{row[1]}, #{row[2]}, #{row[3]}, #{row[4]}"
      
            
      begin
        #find and update
        ncbi_seq = NcbiSeq.find(gi)
        ncbi_seq.vers_access = row[2]
        ncbi_seq.taxon_id = row[3]
        ncbi_seq.save
        
        #puts "ncbi_seq: #{ncbi_seq.inspect}"
      rescue ActiveRecord::RecordNotFound
        #insert
        ncbi_seq = NcbiSeq.new
        ncbi_seq.id = gi
        ncbi_seq.vers_access = row[2]
        ncbi_seq.taxon_id = row[3]
        ncbi_seq.save
                
      end
      
      
      
    }
    
    ###############################  gene_blo_seqs
    palmer_arr.each {|row|
      
      
      gi = row[0]
           
      gbs_o = GeneBloSeq.find_by_ncbi_seq_id_and_gene_id(gi, gn_o.id)
      
      puts "gi: #{gi}, gbs_o: #{gbs_o.inspect}"
      
      if gbs_o.nil?
        gbs_o = GeneBloSeq.new
        gbs_o.ncbi_seq_id = gi
        gbs_o.gene_id = gn_o.id
        gbs_o.save
      end
      
      
      
      
    }
    
    ###############################  alignment
    ud = UqamDoc::Parsers.new
    palmer_oa = Bio::Alignment::OriginalAlignment.new()
     
    
      
    palmer_arr.each {|row|
      
      
      gi = row[0]
      access = row[1]
      
      acc_f = palmer_d + "access_seqs/#{access}.fasta"
      puts "gi: #{gi}, acc_f: #{acc_f}"
      
      #read alignment
      oa = ud.fastafile_to_original_alignment(acc_f)
      row = oa.first
      puts "row: #{row.inspect}"
     
      palmer_oa.add_seq(row, gi)
      
      puts "oa_size: #{oa.size}"
     
      
      
      
    }
    
    ud.string_to_file(palmer_oa.output(:fasta),palmer_row_seqs_f)
    
    #genes = myarr.collect {|e| e[0]}
    
  end
  
  
  def palmer_q_func_gene
    
    #prepare R connection
    #export groups
    c=Rserve::Connection.new

    
    str=<<-EOF
rm(list=ls(all=TRUE))
library(MASS)
Sys.setenv(JAVA_HOME='/usr/java/latest/bin')
options(java.parameters="-Xmx1g")
library(rJava)
.jinit()
print(.jcall("java/lang/System", "S", "getProperty", "java.version"))
library(RJDBC)
library(DBI)
setwd("/root")
print(getwd())
drv <- JDBC("org.hsqldb.jdbcDriver","/root/devel/proc_hom/lib/hsqldb.jar", identifier.quote='\"')
conn <- dbConnect(drv, 'jdbc:hsqldb:hsql://localhost:9005/proc_hom', 'SA', '')
    EOF

    #print str
    #execute
    x = c.eval str
    #puts "x: #{x.to_s}"
    
 
    #execute hgt-qfunc
      
    #  Dir.chdir(qfunc_work_d)
      
           
    #export groups
    c.assign("gene_id", 220)
    str=<<-EOF
sql <-sprintf("select tg.PROK_GROUP_ID as pgid,
       gbs.NCBI_SEQ_ID as seqid     
from GENE_BLO_SEQS gbs
 join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
 join TAXON_GROUPS tg on tg.TAXON_ID = ns.TAXON_ID
where gbs.GENE_ID = %i
      and tg.PROK_GROUP_ID between 104 and 109
order by  tg.PROK_GROUP_ID,
          gbs.NCBI_SEQ_ID",gene_id)

gr_seq_df <- dbGetQuery(conn, sql)

print(gr_seq_df)
write.csv(gr_seq_df, file = "#{palmer_qfunc_gr_seq_csv_f}")
    EOF

    print str
    #execute
    c.void_eval str
      
        
      
    c.close

   
  end
  
  def palmer_q_func_exec
     
    @gene = Gene.find(220)
      
    ud = UqamDoc::Parsers.new
         
    oa = ud.fastafile_to_original_alignment(palmer_gblocks_seqs_f)
    #convert to phylip for RAxML
    ud.string_to_file(oa.output(:phylip),palmer_gblocks_phy_f)
     
    len = oa.first.length
    puts "len: #{len}"
    
    Dir.chdir(palmer_d + "qfunc")
       
    puts "gene: #{@gene.name}, #{@gene.id}"
          
    exec_s = "#{qfunc_prog} --winl #{len} --gr-seqs-csv #{palmer_qfunc_gr_seq_csv_f} --msa-fasta #{palmer_gblocks_seqs_f} --q-func-hgts-csv q_func_rbcL-hgts.csv --f_opt_max 2"
    puts exec_s
    sys exec_s
      
  end
  
  def palmer_fix_species_tree
    
    itol_tree_f = palmer_d + "species_tree/expanded_ids.nwk"
    sp_tree_f = palmer_d + "species_tree/species_tree.nwk"
    
    s = File.open(itol_tree_f, 'rb') { |f| f.read }
    puts "s: #{s}"

    sptr = Bio::Newick.new(s).tree
    
       
    root = sptr.root
    root.name = "root"
    puts "root: #{root.name}"
    
    #remove INT from internal nodes
    sptr.collect_node!() { |node| 
      # puts "node: #{node}, name: #{node.name}"
         
      res =  /(INT)?(.+)/.match(node.name)
      #puts "res[1]: #{res[1]}, res[2]: #{res[2]}"
     
      node.name = res[2]
      node
    }
    
    
    #for each distinct taxon id in the alignment
    txids = @conn.select_rows( sql=<<-END
 select distinct taxon_id
from GENE_BLO_SEQS gbs
 join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
where gene_id = 220     
      END
    ).collect {|e| e[0].to_s}
    
    puts "txids: #{txids.inspect}"
    puts "tree: #{sptr.output_newick({:indent => false})}"
   
    txids.each {|txid|
      
      #puts "txid: #{txid}"
      #bring gi's of this taxid from alignment in database
      gis = @conn.select_rows( sql=<<-END
 select gbs.NCBI_SEQ_ID
from GENE_BLO_SEQS gbs
 join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
where gene_id = 220 and
      taxon_id = #{txid}
        END
      ).collect {|e| e[0].to_s}
    
      #puts "gis: #{gis.inspect}"
    
      #find txid node in tree
      n1 = sptr.get_node_by_name(txid)
      #puts "n1: #{n1.inspect}"
      raise "taxid not found" if n1.nil?
        
      #add gis as descendents
      #add a TEMP prefix to avoid name conflicts
      gis.each {|gi|
        nn = Bio::Tree::Node.new
        nn.name = "TEMP#{gi}" 
        
        ee = Bio::Tree::Edge.new
        ee.distance = 1.0
        
        sptr.add_node(nn)
        sptr.add_edge(n1, nn, ee)
        
      }
            
      
      #n0 = nil
      #puts "n0: #{n0.name}"
      #sptr.nodes.each { |nd| 
      #  n0 = nd if nd.name.to_s == txid.to_s 
      #  puts "n0: ->#{nd}<-, name: ->#{nd.name}<-"
        
      #}
      #puts "n0: #{n0}, name: #{n0.inspect}"
      
    }
    
    
    #prepend INT to internal nodes
    #better remove all internal node names
    # HGT-DETECTION 
    sptr.collect_node!() { |node| 
      # puts "node: #{node}, name: #{node.name}"
      if not sptr.leaves(root).include? node
        #node.name = "INT#{node.name}"
        node.name = nil
      end
         
      node
    }
    root.name = nil
    
    #remove TEMP from leaves
    leaves = sptr.leaves(root)
    leaves.each { |lv|
      puts "leaf : #{lv.inspect}"
      res =  /(TEMP)?(.+)/.match(lv.name)
      puts "lv.name: #{lv.name}, res[2], #{res[2]}"     
      lv.name = res[2]
    
      
    }
    
   
    
    #
    sptr.remove_nonsense_nodes()
    #normalize all distances to 1
    sptr.each_edge() { |source, target, edge| 
      edge.distance=1.0
    }
    
    
    
    
    
    #iterate leaves
    #leaves = sptr.leaves(root)
    #leaves.each { |lv|
    #  puts "leaf : #{lv.inspect}"
    #  
    #}
    
    #write result to file
    st = sptr.output_newick({:indent => false})
    @ud.string_to_file(st, sp_tree_f)
    
        
    
    
  end
  
  #################################### HGT_SIM
  
  def gene_length(gene_id)
    @conn.select_rows( sql=<<-END
 select gbr.BLOCKS_LENGTH
from GENE_BLO_RUNS gbr
where gbr.GENE_ID = #{gene_id}
      END
    )[0][0].to_i
    

  end
  
  def gene_nb_seqs(gene_id)
    @conn.select_rows( sql=<<-END
 select count(*) as cnt
from genes gn 
 join GENE_BLO_SEQS gbs on gbs.GENE_ID = gn.ID 
where gn.ID = #{gene_id}
group by gn.id
      END
    )[0][0].to_i
      

  end
  
  def create_hgt_sim_cond(gene_id, max_trsfs)
    
    hsc = HgtSimCond.find_by_gene_id_and_max_trsfs(gene_id, max_trsfs)
    if hsc.nil?
      hsc = HgtSimCond.new
      hsc.gene_id = gene_id
      hsc.max_trsfs = max_trsfs     
     
    end
    
    #hsc.sim_nb_perms = (gene_length(gene_id).to_f * 0.2).to_i
    hsc.nb_perms = self.sim_nb_perms
    
    hsc.save
    
    return hsc
    
  end
  
  ############## file definitions
  
  def sim_d
    Pathname.new "/root/devel/proc_hom/db/exports/hgt-simul"
  end
  
  def sim_work_d 
    sim_d + "#{gene.id}-#{gene.name}"
  end
  
  def sim_qfunc_gr_seq_csv_f
    sim_work_d + "gr-seq-df-#{gene.name}-#{gene.id}.csv"
  end
  
  def sim_ori_align_fa_f
    sim_work_d + "#{gene.name}.fasta"
  end
  
  def sim_seqgen_align_fa_f
    sim_work_d + "#{gene.name}-seqgen.fa"
  end
  
  def sim_seqgen_align_phy_f
    sim_work_d + "#{gene.name}-seqgen.phy"
  end

  def sim_ori_align_phy_f
    sim_work_d + "#{gene.name}.phy"
  end
  
  def sim_perm_align_fa_f
    sim_work_d + "perm-#{gene.name}.fa"
  end
  
  def sim_perm_align_phy_f
    sim_work_d + "perm-#{gene.name}.phy"
  end
  
  def sim_q_func_hgts_csv_f
    sim_work_d + "hgt-q-funcs-#{@gene.name}-#{@gene.id}.csv"
  end
  
  
  def gen_one_perm_for_cond(cond_id)
    
    #puts "try: gene_name: #{gene.name}"
    
    case self.sim_align_type
    when :original
      #read original alignment
      puts "sim_ori_align_fa_f: #{sim_ori_align_fa_f}"
      oa = @ud.fastafile_to_original_alignment(sim_ori_align_fa_f)
      
    when :seqgen
      #read simulated alignment without residual hgts
      puts "sim_seqgen_align_fa_f #{sim_seqgen_align_fa_f}"
      oa = @ud.fastafile_to_original_alignment(sim_seqgen_align_fa_f)
     
    end
    
    
    
    
    #convert to phylip for RAxML
    #@ud.string_to_file(oa.output(:phylip),palmer_gblocks_phy_f)
     
    len = oa.first.length
    puts "len: #{len}"
    
    hsc = HgtSimCond.find(cond_id)
    
    #read groups
    pg_gi = CSV.read(sim_qfunc_gr_seq_csv_f)
    pg_gi.shift
        
    #puts "pg_gi: #{pg_gi.inspect}" 
    nb_seqs = pg_gi.length
    puts "nb_seqs: #{nb_seqs}"
     
    #arr = []
    #5000.times {
    #  rnd = @rnd_gen.rand(0...nb_seqs)
    #  arr << rnd
    #puts "rnd: #{rnd}"
      
    #}
    #puts "#{arr.min}, #{arr.max}"
     
    
    
    #count group sizes
    grp_cnt = {}
    #nb_seqs.times { |i|
    #  row = pg_gi[i]
    #  grp = row[1]
    #  gi = row[2]
       
    # puts "grp: #{grp}, gi: #{gi}"
            
      
    #puts "id: #{i}, pg_gi: #{pg_gi[i].inspect}"
  
    #}
     
    pg_cnt_h = pg_gi.inject({}){|res,el| 
      grp = el[1]
      gi = el[2]
       
      puts "grp: #{grp}, gi: #{gi}"
      if res[grp].nil?
        res[grp] = 1
      else
        res[grp] += 1
      end 
    
      res
      
    }
      
    #puts "pg_cnt_h: #{pg_cnt_h.inspect}"
    
    mut_arr = []
    mut_arr_gi = []
    
    while mut_arr.length < hsc.max_trsfs do
      #draw a pair of indexes
      src = @rnd_gen.rand(0...nb_seqs)
      dst = @rnd_gen.rand(0...nb_seqs)
      #metadata
      src_pg = pg_gi[src][1]
      dst_pg = pg_gi[dst][1]
      
      src_pg_dim = pg_cnt_h[src_pg]
      dst_pg_dim = pg_cnt_h[dst_pg]
    
      
      chk_cond = true
      #check if backward
      src_arr = mut_arr.collect {|e| e[0]}
      dst_arr = mut_arr.collect {|e| e[1]}
      
      puts "src_arr: #{src_arr}"
      
      if src_arr.include?(dst)
        #do not add
        chk_cond = false
        puts "backward: #{src} -> #{dst}"
      end
      
      if dst_arr.include?(src)
        #do not add
        chk_cond = false
        puts "overwriting: #{dst} -> #{src}"
      end
      
      
      #check if group have minimum 2 elements
      if src_pg_dim < 2 or dst_pg_dim < 2
        chk_cond = false
        puts "small group: #{src} -> #{dst}"
      end
      
      #check same group
      if src_pg == dst_pg
        chk_cond = false
        puts "same group: #{src} -> #{dst}"
      end
      
      
      
      
      
      puts "src: #{src}, dst: #{dst}, src_pg: #{src_pg}, dst_pg: #{dst_pg}, src_pg_dim: #{src_pg_dim}, dst_pg_dim: #{dst_pg_dim}"
        
      
      #add it to result array
      if chk_cond
        mut_arr << [src,dst] 
        mut_arr_gi << [pg_gi[src][2],pg_gi[dst][2]] 
      end
      
    end
    puts "mut_arr.length: #{mut_arr.length}, mut_arr: #{mut_arr.inspect}"
    
        
    
    hsp = HgtSimPerm.new
    hsp.hgt_sim_cond_id = cond_id
    hsp.nb_trsfs = mut_arr.length
    hsp.perm_list_id = mut_arr.to_s
    hsp.perm_list_gi = mut_arr_gi.to_s
    
    hsp.save
    
    #load HgtSimMut
    HgtSimMut.delete_all
    mut_arr_gi.each { |src_id, dst_id|  
      hsm = HgtSimMut.new
      hsm.gene_id = gene.id
    
    
      if src_id.to_i > dst_id.to_i
        src_id, dst_id = dst_id, src_id
        
      end
    
      hsm.source_id = src_id
      hsm.dest_id = dst_id
        
      hsm.save
    }
  
  
    #generate permuted alignment
     
    #oa_perm = @ud.fastafile_to_original_alignment(sim_ori_align_fa_f)
    oa_perm = Bio::Alignment::OriginalAlignment.new()
    
    oa.each_pair() { |k, seq|
      oa_perm.add_seq(seq, k)
      
    }
  
    len = oa_perm.first.length
    puts "len: #{len}"
    
    #replace sequences destination in permutation alignement
    #with those in source original alignment
    mut_arr_gi.each { |src,dst|
      
      dst_seq = oa[dst]
      src_seq = oa[src]
    
    
      #transfer source sequence 
      mut_seq = src_seq
    
      #generate hibridisations from dst seqs
      nb_hibr = (len * self.sim_perc_recomb).to_i
      puts "nb_hibr: #{nb_hibr}"
      #bring in some original dst nucleotides
      nb_hibr.times {
        hib_pos = @rnd_gen.rand(0...len)
      
      
        puts mut_seq[hib_pos]==dst_seq[hib_pos]
           
        mut_seq[hib_pos]=dst_seq[hib_pos]
      
        puts "mut_seq [#{hib_pos}]: #{mut_seq[hib_pos]}"
        
      }  
      puts "src: #{src},dst: #{dst}, src_seq: #{src_seq} \n,                     mut_seq: #{mut_seq}"
      
      #overwrite sequence
      oa_perm.delete(dst)
      oa_perm.add_seq(mut_seq, dst)
      
    }
      
    #write to file
    @ud.string_to_file(oa_perm.output(:fasta),sim_perm_align_fa_f)
    #convert to phylip for RAxML
    @ud.string_to_file(oa_perm.output(:phylip),sim_perm_align_phy_f)
     
 
    [7,8,9,11].each { |item|  
      self.qfunc_f_opt_max = item
      run_funcs_for_perm(hsp.id)
      
    }
 
    
    
    
    
  end

 
  def load_sim_dets()
    puts "in load_sim_dets..."
  
    #select and order pairs
    #csvf_f = "/root/devel/PROJ_CPP/hgt-qfunc5/q-func-hgt-trsfs.csv"  #exp_d(:csv) + "#{tt_base_name}.csv"
    #puts "csvf_f: #{csvf_f}"
        
    #q_func_hgts = CSV.read(csvf_f)
    q_func_hgts = CSV.read(sim_q_func_hgts_csv_f)
    
    heads = q_func_hgts.shift
        
    #puts "load_q_func_hgts: #{q_func_hgts.inspect}"
       
    HgtSimDet.delete_all
    #HgtObjAll.delete_all
     
       
    q_func_hgts.each { |qfunc_row|
      
      src_id = qfunc_row[8].to_i
      dst_id = qfunc_row[9].to_i
      val = qfunc_row[10].to_f
      conf = qfunc_row[11].to_f
      
      next if conf >= self.sim_max_pval
    
    
      if src_id.to_i > dst_id.to_i
        src_id, dst_id = dst_id, src_id
        
      end
      
      
      
      #puts "src_id: #{src_id}, dst_id: #{dst_id}"
      
      #insert into alls
      
      hsd = HgtSimDet.new
      hsd.gene_id = gene.id
      hsd.source_id = src_id
      hsd.dest_id = dst_id
      hsd.val = val
      hsd.conf = conf
      
      hsd.save
      
    }   
  
    order_by_cond = case self.sim_order_by
    when :pvals
      " order by conf asc,
          val desc "
    when :vals
      " order by val desc,
           conf asc "
    end
  
    #order and filter
    filter = @conn.select_rows( sql=<<-END
 select gene_id,source_id,dest_id,val,conf
 from hgt_sim_dets
 #{order_by_cond} 
 limit #{self.sim_rows_limit} 
      END
    )
    
  
    HgtSimDet.delete_all
  
    filter.each { |gene_id,source_id,dest_id,val,conf|
      hsd = HgtSimDet.new
      hsd.gene_id = gene_id
      hsd.source_id = source_id
      hsd.dest_id = dest_id
      hsd.val = val
      hsd.conf = conf
      
      hsd.save
    }
  
  
  
        
         
    
      
    
  end
  
  def run_funcs_for_perm(perm_id)
 
    Dir.chdir(sim_work_d)
 
    #execute qfunc 
    exec_s = "#{qfunc_prog} --winl #{gene_length(gene.id)} --gr-seqs-csv #{sim_qfunc_gr_seq_csv_f} --msa-fasta #{sim_perm_align_fa_f} --q-func-hgts-csv #{sim_q_func_hgts_csv_f} --f_opt_max #{qfunc_f_opt_max}"
    puts exec_s
    sys exec_s
  
    #load qfunc values
    load_sim_dets()
  
    hsps = HgtSimPermStat.new
    hsps.hgt_sim_perm_id = perm_id
    hsps.qfunc = qfunc_f_opt_max
  
    hsps.true_pos = @conn.select_rows( sql=<<-END
 select count(*)
from HGT_SIM_POS_TRUE
      END
    )[0][0].to_f
    
    hsps.false_pos = @conn.select_rows( sql=<<-END
select count(*)
from HGT_SIM_POS_FALSE
      END
    )[0][0].to_f
  
    hsps.false_neg = @conn.select_rows( sql=<<-END
select count(*)
from HGT_SIM_NEG_FALSE
      END
    )[0][0].to_f
  
    
    #Sensitivity = TP / (TP + FN)
    hsps.sensit = hsps.true_pos / (hsps.true_pos + hsps.false_neg)
    hsps.sensit = -1 unless hsps.sensit.finite?
    #Positive predictive value = TP / (TP + FP)
    hsps.ppv = hsps.true_pos / (hsps.true_pos + hsps.false_pos)
    hsps.ppv = 0.0 unless hsps.ppv.finite?
  
    hsps.save  
  
  
    
  
  end
 
  
  def gen_all_perms_for_cond(cond_id)
    
    puts "cond_id: #{cond_id}"
    
    hsc = HgtSimCond.find(cond_id)
    nb_perms = hsc.nb_perms()
    
    @conn.execute <<-EOF
  delete
from HGT_SIM_PERM_STATS hsps
where hsps.HGT_SIM_PERM_ID in (select hsp.id
                               from HGT_SIM_PERMS hsp
                               where hsp.HGT_SIM_COND_ID = #{cond_id})
    EOF
  
    HgtSimPerm.where(:hgt_sim_cond_id => cond_id).delete_all
  
                             
    
    nb_perms.times { |i|  
      
      gen_one_perm_for_cond(cond_id)
      
    }
    
  end

  def qfunc_res_d
    Pathname.new "/root/devel/proc_hom/db/exports/hgt-qfunc/results"
  
  end


  def font2outl(pdf_wo_ext)
    #text to outlines
    sys "gs -dNOPAUSE -dNOCACHE -dBATCH -sDEVICE=epswrite -sOutputFile=#{pdf_wo_ext}.ol.eps #{pdf_wo_ext}.pdf"

   #crop eps
    sys "ps2pdf -dEPSCrop #{pdf_wo_ext}.ol.eps"

#verify no fonts anymore
#pdffonts ${source}-ol.pdf

#overwrite 
#sys "mv #{pdf_wo_ext}.ol.pdf #{pdf_wo_ext}.ol.pdf"

  end
  
  def pdf2emf(pdf_wo_ext)
    #use pstopdf
    sys "pstoedit #{pdf_wo_ext}.pdf #{pdf_wo_ext}.emf -f \"emf:-m -drawbb -OO\""

  end
  
  
  def gen_proj3_sim_plots
    nb_seqs_a = [1,2,4,8,16,32,64,128]
    perc_recomb_a = [0,25,50]
 
    nb_seqs_a.each {|ns|
                  
      perc_recomb_a.each {|pr|
       
        simul_name = "simul_#{ns}_#{pr}_recomb_100pval"
        simul_d = qfunc_res_d + simul_name
        Dir.chdir simul_d
        puts Dir.pwd
        
        sim_plot_f = Pathname.new "sim_plot.R"
        #
sim_plot_txt=<<-END   
library(quantmod)
library(Cairo)

rm(list=ls(all=TRUE))


setwd("#{simul_d}")
print(getwd())


#qfunc_stats_df[qfunc_stats_df==-1] <- NA

#write.csv(qfunc_stats_df, file = "qfunc_stats_df.csv")

options(stringsAsFactors = FALSE)
qfunc_stats_df <- read.csv(file="qfunc_stats_df.csv",sep=",",head=TRUE)

#filter
qfunc_stats_df <- qfunc_stats_df[qfunc_stats_df$STAT=='SENS',]

#rename function names
qfunc_stats_df$FUNC[qfunc_stats_df$FUNC == 'Q7.1'] <- 'Q7'
qfunc_stats_df$FUNC[qfunc_stats_df$FUNC == 'Q8.1'] <- 'Q8a'
qfunc_stats_df$FUNC[qfunc_stats_df$FUNC == 'Q8.2'] <- 'Q8b'
#percentage
qfunc_stats_df$SENSIT <- qfunc_stats_df$SENSIT * 100

CairoPDF(file = "#{simul_name}.pdf",
         width = 6, height = 2, onefile = TRUE, family = "Arial",
         title = "R Graphics Output", fonts = NULL, version = "1.1",
         paper = "special", bg = "transparent", fg = "black", pointsize = 14)

par(las = 1) # rotates the y axis values for every plot you make from now on unless otherwise specified

#margins
#bottom,left,top,right
par(mar=c(2, 2.5, 0.5, 0.5)) 

boxplot(SENSIT~FUNC, data=qfunc_stats_df, notch=FALSE, medlwd=4,
        col=(c("#FF9999","#99CCFF","#9999FF","#FF99CC")),
        main="",
        sub="",
        xlab="", 
        ylim=c(1, 100),
        horizontal=TRUE,
        lwd=2
        )
axis(1, 1:20*5, rep('', 20))


dev.off()

          END
      
        #save to disk
        sim_plot_f.open('w'){ |f| f.puts sim_plot_txt }
        
        #compile
         sys "R < #{sim_plot_f} --no-save"
        
        #convert with outlines
        #self.font2outl "#{simul_name}"
        
        #better convert with pstoedit
        self.pdf2emf "#{simul_name}" 
                
                  
      }
    }
  end
  
  def gen_proj3_sim_plots_data
     nb_seqs = self.sim_nb_seqs.to_s
     perc_recomb = (self.sim_perc_recomb() *100).to_i.to_s
     simul_name = "simul_#{nb_seqs}_#{perc_recomb}_recomb_100pval"
     
     simul_d = qfunc_res_d + simul_name
     Dir.chdir simul_d
     puts Dir.pwd
     
 sim_plot_data_f = Pathname.new "sim_plot_data.R"
        #
sim_plot_data_txt=<<-END   
rm(list=ls(all=TRUE))

# Set JAVA_HOME, set max. memory, and load rJava library
Sys.setenv(JAVA_HOME='/usr/java/latest/bin')
options(java.parameters="-Xmx1g")
library(rJava)

# Output Java version
.jinit()
print(.jcall("java/lang/System", "S", "getProperty", "java.version"))

# Load RJDBC library
library(RJDBC)


setwd("#{simul_d}")
print(getwd())

#--receive by prok-group
sql <- "
select hps.SENSIT as val,
'SENS' as stat,
case hps.QFUNC
when 7 then 'Q7.1'
when 8 then 'Q8.1'
when 9 then 'Q9'
when 11 then 'Q8.2'
end as func
from HGT_SIM_PERM_STATS hps
 union all 
select hps.ppv as val,
'PPV' as stat,
case hps.QFUNC
when 7 then 'Q7.1'
when 8 then 'Q8.1'
when 9 then 'Q9'
when 11 then 'Q8.2'
end as func
from HGT_SIM_PERM_STATS hps
"

drv <- JDBC("org.hsqldb.jdbcDriver","/root/devel/proc_hom/lib/hsqldb.jar", identifier.quote="\\"")
conn <- dbConnect(drv, "jdbc:hsqldb:hsql://localhost:9005/proc_hom", "SA", "")

qfunc_stats_df <- dbGetQuery(conn, sql)
qfunc_stats_df[qfunc_stats_df==-1] <- NA

write.csv(qfunc_stats_df, file = "qfunc_stats_df.csv")
          END
      
        #save to disk
        sim_plot_data_f.open('w'){ |f| f.puts sim_plot_data_txt }
        
        #compile
         sys "R < #{sim_plot_data_f} --no-save"
        
     
  end
  
  def gen_proj3_stat_plot
    
   thres_a = [90,75,50]
 
    thres_a.each {|th|
            
     stat_name = "stat_#{th}bs_100pval"
     
     stat_d = qfunc_res_d + stat_name
     Dir.chdir stat_d
     puts Dir.pwd
     
      
     
     stat_plot_f = Pathname.new "stat_plot.R"      
     
stat_plot_txt=<<-END   
library(quantmod)
library(Cairo)

rm(list=ls(all=TRUE))


setwd("#{stat_d}")
print(getwd())


options(stringsAsFactors = FALSE)
qfunc_stats_df <- read.csv(file="qfunc_stats_df.csv",sep=",",head=TRUE)

#filter
qfunc_stats_df <- qfunc_stats_df[qfunc_stats_df$STAT=='SENS',]

#rename function names
qfunc_stats_df$FUNC[qfunc_stats_df$FUNC == 'Q7.1'] <- 'Q7'
qfunc_stats_df$FUNC[qfunc_stats_df$FUNC == 'Q8.1'] <- 'Q8a'
qfunc_stats_df$FUNC[qfunc_stats_df$FUNC == 'Q8.2'] <- 'Q8b'
#percentage
qfunc_stats_df$SENSIT <- qfunc_stats_df$SENSIT * 100

CairoPDF(file = "#{stat_name}.pdf",
         width = 12, height = 4, onefile = TRUE, family = "Arial",
         title = "R Graphics Output", fonts = NULL, version = "1.1",
         paper = "special", bg = "transparent", fg = "black", pointsize = 14)


par(las = 1) # rotates the y axis values for every plot you make from now on unless otherwise specified

#margins
#bottom,left,top,right
par(mar=c(2, 2.5, 0.5, 0.5)) 

boxplot(SENSIT~FUNC, data=qfunc_stats_df, notch=FALSE, medlwd=4,
        col=(c("#FF9999","#99CCFF","#9999FF","#FF99CC")),
        main="",
        sub="",
        xlab="", 
        ylim=c(1, 100),
        horizontal=TRUE,
        lwd=2
        )
axis(1, 1:20*5, rep('', 20))

dev.off()
         END
      
        #save to disk
        stat_plot_f.open('w'){ |f| f.puts stat_plot_txt }
        
        #compile
         sys "R < #{stat_plot_f} --no-save"
        
        #self.font2outl "#{stat_name}"
        self.pdf2emf "#{stat_name}"
        
         #sys "mv #{base} ../#{ext}/"
         #sys "mv #{tt_gr_name}-#{ver}.#{ext} ../#{ext}/"
                  
      }
   
  end
  
  def gen_proj3_stat_plot_data
    
     stat_name = "stat_#{self.sim_thres}bs_100pval"
     
     stat_d = qfunc_res_d + stat_name
     Dir.chdir stat_d
     puts Dir.pwd
     
 stat_plot_data_f = Pathname.new "stat_plot_data.R"
        #
stat_plot_data_txt=<<-END   
rm(list=ls(all=TRUE))

# Set JAVA_HOME, set max. memory, and load rJava library
Sys.setenv(JAVA_HOME='/usr/java/latest/bin')
options(java.parameters="-Xmx1g")
library(rJava)

# Output Java version
.jinit()
print(.jcall("java/lang/System", "S", "getProperty", "java.version"))

# Load RJDBC library
library(RJDBC)


setwd("#{stat_d}")
print(getwd())

#--receive by prok-group
sql <- "
select hqs.SENSIT as val,
'SENS' as stat,
case hqs.HGT_QFUNC_COND_ID
when 7 then 'Q7.1'
when 8 then 'Q8.1'
when 9 then 'Q9'
when 11 then 'Q8.2'
end as func
from HGT_QFUNC_STATS hqs
 union all
select hqs.ppv as val,
'PPV' as stat,
case hqs.HGT_QFUNC_COND_ID
when 7 then 'Q7.1'
when 8 then 'Q8.1'
when 9 then 'Q9'
when 11 then 'Q8.2'
end as func
from HGT_QFUNC_STATS hqs
 union all
select hqs.specif as val,
'SPEC' as stat,
case hqs.HGT_QFUNC_COND_ID
when 7 then 'Q7.1'
when 8 then 'Q8.1'
when 9 then 'Q9'
when 11 then 'Q8.2'
end as func
from HGT_QFUNC_STATS hqs
"

drv <- JDBC("org.hsqldb.jdbcDriver","/root/devel/proc_hom/lib/hsqldb.jar", identifier.quote="\\"")
conn <- dbConnect(drv, "jdbc:hsqldb:hsql://localhost:9005/proc_hom", "SA", "")

qfunc_stats_df <- dbGetQuery(conn, sql)
qfunc_stats_df[qfunc_stats_df==-1] <- NA

write.csv(qfunc_stats_df, file = "qfunc_stats_df.csv")
    END
      
        #save to disk
        stat_plot_data_f.open('w'){ |f| f.puts stat_plot_data_txt }
        
        #compile
        sys "R < #{stat_plot_data_f} --no-save"
        
     
  end
  
end
