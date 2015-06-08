
require 'rubygems'
require 'bio' 
require 'msa_tools'
require 'faster_csv'


class AssertError < StandardError
end

class HgtComInt
  
 def initialize()
  @ud = UqamDoc::Parsers.new
 end
 
 
  
 def retrieve_gi(vers_access)
  gi_str = ""
  
  #puts "executing...."
  Bio::NCBI.default_email = "dunarel@gmail.com"
 
  list = [ vers_access]
 
  prot_entry =  Bio::NCBI::REST::EFetch.protein(list, "gb")
  #sleep(1)


  prot_gb = Bio::GenBank.new(prot_entry)
   
  #puts prot_entry
 
   version_str = ""
   #sometimes name spans two lines
   if prot_entry =~ /VERSION\s*(\S+)\s*(\S+)\s*(\S+)/
  
     vers_access =  $1
     gi_str = $2
 
      
   end
 
     #puts "va: #{vers_access}, gi: #{gi_str}"  
   
   if gi_str =~ /GI:(\d+)/
     gi_str = $1
   end
   
   #puts "va: #{vers_access}, gi: #{gi_str}"  

   return gi_str
   
   
 end

  def sequences
     
    #only non processed vers_access
    gseqs = GeneSeq.where("vers_access not in (select vers_access from ncbi_seqs)")
   
    gseqs.each { |gs|



       # Prevent Infinite Loops
       counter = 0

       begin
       #monitor naseq retrieval
        gi = retrieve_gi(gs.vers_access)
     

       rescue => e
          p e.message
          p e.backtrace
         #EOFError
        puts "encountered EOFError"
        
        # Fail the connection after 3 attempts
        if counter < 5
          counter += 1
          puts "redo: #{counter}"
          #wait a moment
          sleep(20) 
          redo
        else
          puts "FAILED CONNECTION #{counter} TIMES"
         counter = 0
         exit(0)
        end
       end



      puts "id: #{gs.id}, gs.vers_access: #{gs.vers_access}, gi: #{gi}"
       
      
     this_seq =  NcbiSeq.find_by_vers_access gs.vers_access
      puts "this_seq: #{this_seq.inspect}"
     if this_seq.nil? 
       
       #this_seq.vers_access = gs.vers_access
       this_seq = NcbiSeq.new
       
       this_seq.id = gi
       
       this_seq.vers_access = gs.vers_access
   
       this_seq.save 
     end


    } 


    #update taxon_id field (taxid)
    NcbiSeq.connection.execute "update ncbi_seqs ns
                                set taxon_id = select taxid 
                                    from assoc_taxid_access ata
                                    where ata.vers_access = ns.vers_access"

  end 
 
  def contin_fragms

    puts "Continuing fragments..."
    
    HgtComIntContin.destroy_all
    HgtComIntContin.connection.execute "insert into hgt_com_int_contins
                                        select * from hgt_com_int_fragms"
    
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
 

  def linearize_fragms
     #recreate list of transfers
     HgtComIntTransfer.destroy_all

   
   #fragms = HgtComIntFragm.where("bs_val >= ?", 40).order("id asc")

    #all fragments from contin table 
    fragms = HgtComIntContin.order("id asc")
    
    puts "fragments to linearize: #{fragms.count}"
          
    cnt = 0
    fragms.each {|fr|
      cnt += 1
      puts "#{fr.id}"

      from_subtree = fr.from_subtree
      to_subtree = fr.to_subtree

      farr = from_subtree.split(",").collect{|x| x.lstrip}
      tarr = to_subtree.split(",").collect{|x| x.lstrip}
      puts "#{farr.inspect},#{tarr.inspect}"

      tr_nb = farr.size * tarr.size
      farr.each {|src|
        tarr.each {|dst|
          hcit = HgtComIntTransfer.new
          hcit.source_id = src
          hcit.dest_id = dst
          hcit.weight = 1/tr_nb.to_f
          hcit.confidence = fr.bs_val
          hcit.save
         
        }
      }

      

    }

  end

  def hgt_com_int_transfer_groups(thres)
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
    #  
     HgtComIntTransferGroup.connection.execute "update hgt_com_int_transfer_groups htg
                                               set htg.cnt =  select sum(ht.weight)
                                               from hgt_com_int_transfers ht
                                                left join NCBI_SEQS ns_src on ns_src.id = ht.SOURCE_ID
                                                left join TAXON_GROUPS tg_src on tg_src.ID = ns_src.TAXON_ID  
                                                left join NCBI_SEQS ns_dest on ns_dest.id = ht.DEST_ID
                                                left join TAXON_GROUPS tg_dest on tg_dest.ID = ns_dest.TAXON_ID
                                               where ht.confidence >= #{thres} and
                                                     tg_src.PROK_GROUP_ID = htg.source_id and
                                                     tg_dest.PROK_GROUP_ID = htg.dest_id
                                               group by tg_src.PROK_GROUP_ID,
                                                        tg_dest.PROK_GROUP_ID"

     
      
      RecombTransferGroup.connection.execute "update hgt_com_int_transfer_groups
                                               set CNT=nvl(CNT,0)"

  end


  #real sequences used as input for GENECONV and TREX
  #less sequences than gen_seqs or ncbi_seqs
  def scan_gene_blo_seqs
     GeneBloSeq.destroy_all

     genes = Gene.find(:all)

     genes.each { |gn|

      #assemble gene file location
      gene_blo_runs_f = "#{AppConfig.gene_blo_runs_dir}/#{gn.name}.fasta"
      gene_blo_seqs_f = "#{AppConfig.gene_blo_seqs_dir}/#{gn.name}.fasta"
      gene_blo_seqs_p = "#{AppConfig.gene_blo_seqs_dir}/#{gn.name}.phy"

        
     gene_blo_runs_oa = @ud.fastafile_to_original_alignment(gene_blo_runs_f)
     gene_blo_seqs_oa = Bio::Alignment::OriginalAlignment.new



     puts "gn.seqs_orig_nb:#{gn.seqs_orig_nb}  oa_size: #{gene_blo_runs_oa.size}"

     #schould be equal
     #should insert assertion here or make an rspec to detect source
     #puts oa.keys

      gene_blo_runs_oa.each_pair { |key, seq|
      puts key, seq
       gbs = GeneBloSeq.new
        #find corresponding gi
        ns = NcbiSeq.find_by_vers_access(key)
        #link to objects gene and gi
        gbs.gene = gn
        gbs.ncbi_seq = ns
       gbs.save
       gene_blo_seqs_oa.add_seq(seq,ns.id)

      }
       
       #save fasta file 
       @ud.string_to_file(gene_blo_seqs_oa.output(:fasta),gene_blo_seqs_f)
       #save phylip file
       @ud.string_to_file(gene_blo_seqs_oa.output(:phylip),gene_blo_seqs_p)




    }

  end 


   def hgt_com_int_transfer_groups_matrix

    FasterCSV.open("#{AppConfig.db_exports_dir}/hgt_com_int_groups_matrix.csv", "w", {:col_sep => "|"}) { |csv|
     row = []
      row << 'NAME'
      row << 'SRC_ID \ DEST_ID'
      (0..22).each { |x|
        row << x.to_s
      }
      csv << row

      #for each row
      (0..22).each { |y|
        row = []
        #name of the group
        pg = ProkGroup.find(y)
        pgtn = TaxonGroup.joins(:ncbi_seqs => :gene_blo_seq).where("prok_group_id=?",y).group("prok_group_id").select("count(distinct T\
AXON_ID) as cnt")[0]

        #select count(*)
        #from taxon_groups tg
        #join ncbi_seqs ns on ns.TAXON_ID = tg.ID
        #join GENE_BLO_SEQS gbs on gbs.NCBI_SEQ_ID = ns.ID
        #where tg.PROK_GROUP_ID=8

        #find nb of sequences in group
        pgsn = TaxonGroup.joins(:ncbi_seqs => :gene_blo_seq).where("prok_group_id=?",y).select("count(*) as cnt")[0]

         row << "#{pg.name}(#{pgtn.cnt}),[#{pgsn.cnt}]"

        row << y
         (0..22).each { |x|
          #recomb_transfer_groups
          htg = HgtComIntTransferGroup.find_by_source_id_and_dest_id(y,x)
          row << [htg.cnt== 0  ? nil : htg.cnt ]
         }
        csv << row

       }


     } #end csv

   end

 
end
