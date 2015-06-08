
require 'rubygems'
require 'bio' 
require 'msa_tools'
require 'faster_csv'
require 'erb'
require 'matrix'
require 'base_transfer'
#require 'manage_data'

class AssertError < StandardError
end

class Recomb
  
  include BaseTransfer
  
 
 
 
 def initialize(hgt_type, phylo_prog_p, thres)
    
    #personalize class
    @stage = "recomb"
    
    base_transfer_init(hgt_type, RecombTransferGroup, GeneGroupCnt , RecombGeneGroupsVal )
    # is this necessary in common ?
    #, HgtComIntTransfer
    
    @phylo_prog = phylo_prog_p
    @thres = thres
 
    
    #puts "@transfer_obj: #{ @transfer_obj}"
    #puts "arTransferGroup: #{ arTransferGroup}"
    #puts "@conn: #{@conn.inspect}"
    #puts "@jdbc_conn: #{@jdbc_conn.inspect}"
  
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

 
  def recomb_run
    
    #recreate list of transfers
    RecombTransfer.destroy_all

    #initialize blo_run
    #this_blo_run =  BloRun.find_or_initialize_by_name "first_run"
    #this_blo_run.params = "-t=d  -b5=h -e=-gb"
    #this_blo_run.save 
  
    #puts this_blo_run.id;
    
    puts "#gene_recomb_runs_dir: #{AppConfig.gene_recomb_runs_dir}"
   
    Dir.chdir(AppConfig.gene_recomb_runs_dir)

    genes = Gene.find :all,  :order => "name"     
    
    puts "genes to recomb_run: #{genes.count}"
          
    cnt = 0
    genes.each {|gn|
      cnt += 1
      
      #puts gn.inspect

    
      gene_blo_f = "#{AppConfig.gene_blo_runs_dir}/#{gn.name}.fasta"
      gene_recomb_f = "#{AppConfig.gene_recomb_runs_dir}/#{gn.name}.fasta"

      #output file
      gene_recomb_csv_f = "#{AppConfig.gene_recomb_runs_dir}/#{gn.name}.csv"
      
      #active file name for sikuli
      gene_name_f = "#{AppConfig.gene_recomb_runs_dir}/gene_name.conf"
  
      #calculate rdp/geneconv
           #sys "cp #{gene_blo_f} #{gene_recomb_f}"
           #sys "echo #{gn.name} > #{gene_name_f}"
           #sys "java -jar sikuli-script.jar ~/devel/proc_hom/lib/automate_first.sikuli > sikuli.log"
  
      if File.exists? gene_recomb_csv_f
        puts "#{cnt} : #{gn.name} :"
        
        arr = FasterCSV.read(gene_recomb_csv_f)
        #take out header
        arr.shift()
        arr.each {|line|
          recombinant= line[8]
          #puts "recombinant: #{recombinant}"
          next if (line[6].nil? or line[7].nil?)
          next if (line[6] =~ /Begin/)
          puts "#{line[6]},#{line[7]},#{line[8]},#{line[9]},#{line[10]},#{line[12]}"
          #puts "line: #{line.inspect}"

          start_idx = "" 
          if line[6] =~ /(.+)\*/
             start_idx = $1 
          else 
             start_idx = line[6]
          end

          puts "start_idx #{start_idx}"

          stop_idx = "" 
          if line[7] =~ /(.+)\*/
             stop_idx = $1 
          else 
             stop_idx = line[7]
          end

          puts "stop_idx #{stop_idx}"

          dest = "" 
          dest_sure = 0
          if line[8] =~ /Unknown\s\((.+)\)/
             dest = $1 
             dest_sure = 0
          else 
             dest = line[8]
             dest_sure = 1
          end

          puts "dest #{dest}, dest_sure: #{dest_sure}"


          
          parent_maj = "" 
          parent_maj_sure = 0
          if line[9] =~ /Unknown\s\((.+)\)/
             parent_maj = $1 
             parent_maj_sure = 0
          else 
             parent_maj = line[9]
             parent_maj_sure = 1
          end

          puts "parent_maj #{parent_maj}, parent_maj_sure: #{parent_maj_sure}"


          parent_min = "" 
          parent_min_sure = 0
          if line[10] =~ /Unknown\s\((.+)\)/
             parent_min = $1 
             parent_min_sure = 0
          else 
             parent_min = line[10]
             parent_min_sure = 1
          end

          puts "parent_min #{parent_min}, parent_min_sure: #{parent_min_sure}"

          
          
          [[parent_maj,parent_maj_sure],  
           [parent_min,parent_min_sure]
          ].each {|parent, parent_sure|
            
            
            
            if parent_sure == 1 and dest_sure == 1
             @confidence = 1           
            else
             @confidence = 0
            end
            
            puts "@confidence_avail_db: #{@confidence_avail_db}"
            puts "@confidence: #{@confidence}"
            if @confidence_avail_db.include? @confidence
              
              rt =  RecombTransfer.new
              rt.gene_id = gn.id
              rt.source_id = NcbiSeq.find_by_vers_access(parent).id
              rt.dest_id = NcbiSeq.find_by_vers_access(dest).id
              rt.length = (stop_idx.to_f-start_idx.to_f)
              rt.confidence = @confidence
              rt.save
              
            end
            
            
          }
        }

        #puts arr_of_arrs.inspect()
        #arr_of_arrs.shift()
        #arr_of_arrs.flatten!

        puts
        #puts "gene #{cnt} end processing: #{gn.name} ----------------------"



      else 
        puts "#{cnt} : #{gn.name} : missing"
      end
      
      #sleep 2
      

     
    }



  end

  
   def prepare_recomb_gene_groups_vals()
    
    arGeneGroupsVal.delete_all
    puts "#{arGeneGroupsVal.table_name} deleted..."
    
    #@conn.execute "delete from HGT_COM_GENE_GROUPS_VALS"

    @conn.execute \
      "insert into recomb_gene_groups_vals 
      (gene_id,PROK_GROUP_source_id,prok_group_dest_id,val)
      select  ht.GENE_ID,
              tg_src.PROK_GROUP_ID,
              tg_dest.PROK_GROUP_ID,
              count(*) as weight
      from Recomb_TRANSFERS ht
        join NCBI_SEQS ns_src on ns_src.id = ht.SOURCE_ID
        join TAXON_GROUPS tg_src on tg_src.TAXON_ID = ns_src.TAXON_ID
        join NCBI_SEQS ns_dest on ns_dest.id = ht.DEST_ID
        join TAXON_GROUPS tg_dest on tg_dest.TAXON_ID = ns_dest.TAXON_ID
      group by tg_src.PROK_GROUP_ID,
               tg_dest.PROK_GROUP_ID,
               ht.GENE_ID
      order by tg_src.PROK_GROUP_ID,
               tg_dest.PROK_GROUP_ID,
               ht.GENE_ID"
     
     
    puts "#{arGeneGroupsVal.name} inserted..."
    
    
  end
  
  
  
  def transfer_groups
     #recreate recomb_transfer_groups   
     arTransferGroup.delete_all
     sleep 5
    
     @conn.execute \
       "insert into RECOMB_TRANSFER_GROUPS rtg
         (prok_group_source_id,prok_group_dest_id)
        select pg1.ID,pg2.id
        from PROK_GROUPS pg1
         cross join PROK_GROUPS pg2 
        order by pg1.id,
                 pg2.id"

     #it is based on count not sum
      @conn.execute \
        "update RECOMB_TRANSFER_GROUPS rtg
         set rtg.cnt = select count(*)
        from Recomb_TRANSFERS ht
         join NCBI_SEQS ns_src on ns_src.id = ht.SOURCE_ID
         join TAXON_GROUPS tg_src on tg_src.TAXON_ID = ns_src.TAXON_ID
         join NCBI_SEQS ns_dest on ns_dest.id = ht.DEST_ID
         join TAXON_GROUPS tg_dest on tg_dest.TAXON_ID = ns_dest.TAXON_ID
        where  tg_src.PROK_GROUP_ID = rtg.prok_group_source_id and
               tg_dest.PROK_GROUP_ID = rtg.prok_group_dest_id
        group by tg_src.PROK_GROUP_ID,
                 tg_dest.PROK_GROUP_ID"

     
      @conn.execute \
        "update RECOMB_TRANSFER_GROUPS rtg
          set rtg.length_avg =  select avg(ht.LENGTH)
          from Recomb_TRANSFERS ht
           join NCBI_SEQS ns_src on ns_src.id = ht.SOURCE_ID
           join TAXON_GROUPS tg_src on tg_src.TAXON_ID = ns_src.TAXON_ID
           join NCBI_SEQS ns_dest on ns_dest.id = ht.DEST_ID
           join TAXON_GROUPS tg_dest on tg_dest.TAXON_ID = ns_dest.TAXON_ID
          where  tg_src.PROK_GROUP_ID = rtg.prok_group_source_id and
                 tg_dest.PROK_GROUP_ID = rtg.prok_group_dest_id
          group by tg_src.PROK_GROUP_ID,
                   tg_dest.PROK_GROUP_ID"

       @conn.execute "update RECOMB_TRANSFER_GROUPS 
                      set CNT=nvl(CNT,0),
                      length_avg = nvl(LENGTH_AVG,0)"

  end


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

  
  #works only combined with base_transfer
  #should contain paper widht, paper height, max scale
  def calc_custom_config()
    
    @custom_configs = {}
    
    case @crit  
    when :family
      @custom_configs[[:all,"geneconv",0, :abs]] = [375, 125] #
      @custom_configs[[:all,"geneconv",0, :rel]] = [415, 125] #
    
      #most restrictive
      @custom_configs[[:regular,"geneconv",0, :abs]] = [380, 125] 
      @custom_configs[[:regular,"geneconv",0, :rel]] = [415, 125, 100 ] 
    
      
    when :habitat
      @custom_configs[[:all,"geneconv",0, :abs]] = [215 ,65]
      @custom_configs[[:all,"geneconv",0, :rel]] = [215 ,65]
    
      #most restrictive
      @custom_configs[[:regular,"geneconv",0, :abs]] = [215 ,65]
      @custom_configs[[:regular,"geneconv",0, :rel]] = [215 ,65]
    
      
    end
    
    querry_arr = [@hgt_type, @phylo_prog, @thres, @calc_type] 
    puts "qer_arr: #{querry_arr.inspect}"
    puts "@custom_configs: #{@custom_configs.inspect}"
    @config = @custom_configs[querry_arr]

    
  end
  
  
  def leaf_transf_cnt()
    return RecombTransfer.count
    
  end
  
 
end
