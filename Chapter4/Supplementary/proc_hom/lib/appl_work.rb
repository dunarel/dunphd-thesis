
require 'rubygems'
require 'bio' 
require 'msa_tools'

class AssertError < StandardError
end

class ApplWork
  
 def initialize()
  @ud = UqamDoc::Parsers.new
 end
 

 
  
 def retrieve_naseq_for_aaseq(vers_access)

  cds_nb = 0
  loc_nb = 0
  naseq = ""
  
  puts "executing...."
  Bio::NCBI.default_email = "dunarel@gmail.com"
              #Bio::NCBI::REST::EFetch.protein("7527480,AAF63163.1,AAF63163")

             #list = [ 7527480, "AAF63163.1", "AAF63163"]
              #list = [ "YP_001804073.1"]

  list = [ vers_access]
                  #list = [ "YP_002721359.1"]
   prot_entry =  Bio::NCBI::REST::EFetch.protein(list, "gb")
   #sleep(1)


   prot_gb = Bio::GenBank.new(prot_entry)
   
   #puts prot_entry
   
   
   prot_gb.each_cds{ |feature|
     #counting cdses for verifications
     cds_nb += 1

     puts feature.feature
     puts feature.position
                 
   # puts feature.qualifiers.inspect
                   
    coded_by = feature.qualifiers.reduce("") { |result, qual|
    # puts "sum: #{result}, value: #{qual.inspect}"
     result = qual.value if qual.qualifier == "coded_by"
     result
    }
    
     puts "coded_by: #{coded_by}"
    locations = Bio::Locations.new(coded_by)
    
                  
    locations.each { |loc|
      #counting locations for verification
      loc_nb +=1

      puts "range = #{loc.from}..#{loc.to} (strand = #{loc.strand})"
      puts loc.xref_id
      #for each location recuperate na sequence
      puts "recuperate: #{coded_by}"
      
      list = [ loc.xref_id]
   
      params = {
      :strand => case loc.strand when -1 then 2
                 when 1 then 1 
                 end,
      #:seq_start => 2727695,
      #:seq_stop => 2728396
     :seq_start => loc.from,
      :seq_stop => loc.to,
      :complexity => 1
   }
                     
   puts params.inspect
   nucl_entry =  Bio::NCBI::REST::EFetch.nucleotide(list, "gb", params)
   #sleep(1)

   nucl_gb = Bio::GenBank.new(nucl_entry)
   naseq +=nucl_gb.naseq


                   
                   
                   
    } #end location
                     
                   
    # matched = /\[(.*)\].*\((HPV-.*)\)/.match(line).to_s
    #complement = //.match(coded_by).to_s
    #if matched !=''
    #      accession = $1
    #      hpv_type = $2
    #      #puts "----------> #{line}"

          #hpv_types_acces[hpv_type]=accession  unless /^NC_/ =~ hpv_types_acces[hpv_type]

          #puts "#{accession}:#{hpv_type}"

   }
   
   
   
   
   
  #puts Bio::NCBI::REST::EFetch.sequence(list, "gb")
  #puts Bio::NCBI::REST::EFetch.gene(list)
  
  #list = [ "6169716"]
  #puts Bio::NCBI::REST::EFetch.gene(list)
  #GeneID:6169716
  
  
  
#ncbi = Bio::NCBI::REST::EFetch.new
#ncbi.protein("7527480,AAF63163.1,AAF63163")
#ncbi.protein(list)
#ncbi.protein(list, "fasta")
#ncbi.protein(list, "acc")
#ncbi.protein(list, "xml")

   return [cds_nb,loc_nb,naseq]
 end

 
 def retrieve_gene_seqs_info(vers_access)

  #server = Bio::Fetch.new()
  #puts server.databases # returns "aa aax bl cpd dgenes dr ec eg emb ..."  

  #cds_nb = 0
  #loc_nb = 0
  #naseq = ""
  
#  puts "e-fetching..."
  Bio::NCBI.default_email = "dunarel@gmail.com"
              #Bio::NCBI::REST::EFetch.protein("7527480,AAF63163.1,AAF63163")

             #list = [ 7527480, "AAF63163.1", "AAF63163"]
              #list = [ "YP_001804073.1"]

  list = [ vers_access]
                  #list = [ "YP_002721359.1"]
   prot_entry =  Bio::NCBI::REST::EFetch.protein(list, "gb")
   #puts prot_entry

   orig_org_name = ""
   #sometimes name spans two lines
   if prot_entry =~ /SOURCE\s*(.+)\n(.+)\s*ORGANISM/
     orig_org_name =  $1 + $2
   end
  # puts "$1: #{$1}, $2: #{$2}"

   
   org_name= "\"#{orig_org_name}\""
   tax_id =  Bio::NCBI::REST::ESearch.taxonomy(org_name)

   #puts "tax_id: >#{tax_id}<"
   #puts tax_id.inspect

   if tax_id.empty?
    puts "second chance"
    org_name= orig_org_name
    tax_id =  Bio::NCBI::REST::ESearch.taxonomy(org_name)
   end

   if tax_id.empty?
     puts "third"
     puts orig_org_name
   end
 

 
   #puts "tax_id: #{tax_id}"

   tax_obj =  Bio::NCBI::REST::EFetch.taxonomy(tax_id,"docsum")
 
   #puts "tax_obj: #{tax_obj}"

   sci_name = ""
   group_name = ""
   #puts "tax_obj: #{tax_obj}"
   
   if tax_obj =~ /^(.+)\,\sspecies\,\s(.+)$/ then
    sci_name = $1
    group_name = $2
    #puts "with"
   elsif tax_obj =~ /^(.+)\,\s(.+)$/ then
    sci_name = $1
    group_name = $2
    #puts "without"
   end
   

   #puts "sci_name: >#{sci_name}< group_name: >#{group_name}<"
   
   sci_name.gsub!(" ","_")
   group_name.gsub!(" ","_")
   
   return [tax_id,vers_access,sci_name,group_name]
      

 end

 
 def parse_genes
  #parses Alix statistique_fasta.txt
  #contains gene name <> seqs_orig_nb
  #puts AppConfig.genes_file
  
  #
  AllGene.destroy_all
  
  myarr = FasterCSV.read(AppConfig.all_genes_file)
 
  all_genes = myarr.collect {|e| e[0].split('<>')}
  all_genes.each { |g|
    
    one_gene = AllGene.new
    one_gene.name = g[0]
    one_gene.seqs_orig_nb = g[1]
    one_gene.save
       
  }
  
  
 
 
 end
 
 def select_genes
   puts "select genes.."
   
    Gene.destroy_all
    sel_genes = AllGene.find :all, :conditions => "seqs_orig_nb >=100"
    
    sel_genes.each{ |gn|
     Gene.create(:name => gn.name, :seqs_orig_nb => gn.seqs_orig_nb)
      
      }
    
    #make room
    sys "rm -fr #{AppConfig.gene_seqs_aa_dir}/*"
    
    #move files
    genes = Gene.find(:all)
   
    genes.each { |gn|
     
    #assemble file source location
    all_gene_seqs_file = "#{AppConfig.all_gene_seqs_dir}/#{gn.name}.fasta"
   
    #assemble file dest location
    gene_seqs_aa_file = "#{AppConfig.gene_seqs_aa_dir}/#{gn.name}.fasta"
               
    #key sequences by vers_access
    sys "sed -e 's/pid|//' -e 's/|.*//' #{all_gene_seqs_file} > #{gene_seqs_aa_file}"
     
    }    
    
    
    
   
 end
 
 
 def parse_gene_seqs
   
   GeneSeq.destroy_all
   
    genes = Gene.find(:all)
   
    genes.each { |gn|
     
    #assemble gene file location
    gene_seqs_aa_file = "#{AppConfig.gene_seqs_aa_dir}/#{gn.name}.fasta"
                       
     #read alignment
     oa = @ud.fastafile_to_original_alignment(gene_seqs_aa_file)
     puts "gn.seqs_orig_nb:#{gn.seqs_orig_nb}  oa_size: #{oa.size}" 
     
     #schould be equal
     #should insert assertion here or make an rspec to detect source
     puts oa.keys
     
     oa.each_pair { |key, seq|
      puts key, seq
       new_gene_seq = GeneSeq.new 
       new_gene_seq.vers_access = key
       
       new_gene_seq.gene = gn
       new_gene_seq.save
                   
      }
                     
                       
      
      
     }
 
  
 end


  def retrieve_naseq

    puts "retrieve_naseq()..."

    #make room
    #sys "rm -fr #{AppConfig.gene_seqs_na_dir}/*"
   
    #clear updated columns
    #Rails 3 update_all is always full
    #else use named scopes
    #updated =  Gene.update_all [ 'naseq_orig_nb = ?', nil], []
   
    #puts "nullified naseq of genes: #{updated}"
 

    #updated =  GeneSeq.update_all [ 'cds_nb = ?, loc_nb = ?', nil, nil], []
  
    #puts "nullified cds_nb and loc_nb of gene_seqs: #{updated}"
 
 
   
    genes = Gene.where('naseq_orig_nb is null')
   
    puts "still to go: #{genes.count}"

    genes.each { |gn|
      puts "gene name: #{gn.name}"
        
      #for each gene
      #assemble na gene file location
      gene_seqs_na_file = "#{AppConfig.gene_seqs_na_dir}/#{gn.name}.fasta"
                       
      #construct an alignment
      oa =Bio::Alignment::OriginalAlignment.new


      gn.gene_seqs.each { |gs|

        puts "--------------->vers_access: #{gs.vers_access}"
       
        conv_res=[] 



       # Prevent Infinite Loops
       counter = 0

       begin
       #monitor naseq retrieval
       conv_res = retrieve_naseq_for_aaseq(gs.vers_access)
        

       rescue EOFError
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




        #for verification, should be 1,1  
        gs.cds_nb = conv_res[0]
        gs.loc_nb = conv_res[1]
        oa.add_seq(conv_res[2],gs.vers_access)
        gs.save
     
      }
      
      #write to disk
      @ud.string_to_file(oa.output(:fasta),gene_seqs_na_file)

      #when finished update resulted converted sequences
      gn.naseq_orig_nb=oa.size
      #sort of commit (decision is based on naseq_orig_nb not null)
      gn.save
     
    

     #puts "gn.seqs_orig_nb:#{gn.seqs_orig_nb}  oa_size: #{oa.size}" 
     
     #schould be equal
     #should insert assertion here or make an rspec to detect source
                  
                       
      
      
     }




  end

   def parse_gene_seqs_info

     gseqs = GeneSeq.find :all


     cnt = 0
     gseqs.each { |gs|
       cnt+=1
       #puts "gs.vers_access: #{gs.vers_access}"
         
       begin
       tax_id, vers_access,sci_name,group_name = retrieve_gene_seqs_info(gs.vers_access)
       rescue
         puts "rescue"
         retry
       end

       #puts tax_id.inspect

       puts "#{cnt},#{tax_id},#{vers_access},#{sci_name},#{group_name}"

     }

   end


  def ortho_run

    #go to working directory
    Dir.chdir(AppConfig.tribemcl_dir)
    
    genes = Gene.find(:all)    
    
    puts "genes to ortho_run: #{genes.count}"
    
    genes.each { |gn|

     prot_f = "#{gn.name}.fasta"

     sys "sh clean_prot.sh"
     puts Dir.entries(Dir::pwd)
     #sleep 20
     sys "sh run_prot.sh #{prot_f}"
     puts Dir.entries(Dir::pwd)
     sys "mcl matrix.mci -I 2 -o all-vs-all.mclout -use-tab proteins.index"


     clusters_f = "all-vs-all.mclout"

     clusters_s = File.open(clusters_f).read


     clusters_a = clusters_s.split("\n")
     clusters_a = clusters_a.collect {|row| row.split("\t") }
     #puts clusters_a.inspect

     #puts clusters_a.flatten.count
      #puts clusters_a[0].count
       

     deleted_keys_a = clusters_a.slice(1,clusters_a.length-1).flatten
     deleted_keys_nb = deleted_keys_a.count


     #read corresponding nucleic acid alignment 
      oa = @ud.fastafile_to_original_alignment("#{AppConfig.gene_seqs_na_dir}/#{gn.name}.fasta")
 
      #delete keys based on protein alignements
      deleted_keys_a.each { |k|
      oa.delete(k)
    }
    puts "oa_size: #{oa.size}"
      @ud.string_to_file(oa.output(:fasta),"#{AppConfig.gene_ortho_runs_dir}/#{gn.name}.fasta")
     all_clusters_size = clusters_a.flatten.count
     first_cluster_size = clusters_a[0].count
     first_cluster_obtainedsize = oa.size

   #puts "#{deleted_keys_nb},#{deleted_keys_a.inspect}"

    } 
  end 
 
     
  def msa_run

    Dir.chdir(AppConfig.files_dir)

    genes = Gene.find(:all)    
    
    puts "genes to msa_run: #{genes.count}"
    
    genes.each {|gn|

      in_f = "#{AppConfig.gene_ortho_runs_dir}/#{gn.name}.fasta"
      out_f = "#{AppConfig.gene_msa_runs_dir}/#{gn.name}.fasta"

      sys "muscle -in #{in_f} -out #{out_f}"

     #read alignment
     oa = @ud.fastafile_to_original_alignment(out_f)

      puts "oa_size: #{oa.size}"

     #report to db
     # results_hdl.puts "#{gn},#{oa.size}"
     
    }


  end


  def blo_run

    #initialize blo_run
    this_blo_run =  BloRun.find_or_initialize_by_name "first_run"
    this_blo_run.params = "-t=d  -b5=h -e=-gb"
    this_blo_run.save 
  
    puts this_blo_run.id;

    Dir.chdir(AppConfig.files_dir)

    genes = Gene.find(:all)    
    
    puts "genes to blo_run: #{genes.count}"
          
    genes.each {|gn|

      #initialize gene_blo_run
      this_gene_blo_run = GeneBloRun.find_or_initialize_by_gene_id_and_blo_run_id(gn.id,this_blo_run.id)
            

      fasta_f = "#{AppConfig.gene_msa_runs_dir}/#{gn.name}.fasta"

      gblocks_res_f = "#{AppConfig.gene_msa_runs_dir}/gblocks.res"

      gblocks_f = "#{AppConfig.gene_msa_runs_dir}/#{gn.name}.fasta-gb"
      gblocks_f_htm = "#{AppConfig.gene_msa_runs_dir}/#{gn.name}.fasta-gb.htm"
      gene_blo_runs_f = "#{AppConfig.gene_blo_runs_dir}/#{gn.name}.fasta"



    #read alignment
     oa = @ud.fastafile_to_original_alignment(fasta_f)
    orig_size = oa.size
    #first sequence length
    key, seq = oa.shift
    orig_len = seq.length

    half_size = (orig_size/2).to_i + 2

    #  sys "Gblocks #{fasta_f} -t=p  -b1=#{half_size} -b2=#{half_size} -b3=10 -b4=5 -b5=h -e=-gb > #{gblocks_res_f}"

     #use current run parameters
      sys "Gblocks #{fasta_f} #{this_blo_run.params} > #{gblocks_res_f}"
     gblocks_res  = File.open(gblocks_res_f).read

     gblocks_orig_len = gblocks_res.scan(/Original\salignment\:\s+(\d+)/)[0][0].to_i

     gblocks_len =  gblocks_res.scan(/Gblocks\salignment\:\s+(\d+)/)[0][0].to_i
     gblocks_blocks_no = gblocks_res.scan(/in\s(\d+)\sselected/)[0][0].to_i



     #reread the gblocks alignment
     #correct for spaces introduced
     gblocks_oa = @ud.fastafile_to_original_alignment(gblocks_f)
      gblocks_oa_nospace = gblocks_oa.alignment_collect {|seq| seq.sub(/\s/, '')}
     #clean temporary files
     File.delete(gblocks_f)
     File.delete(gblocks_f_htm)
     File.delete(gblocks_res_f)
     #write corrected file to ortho_std
     @ud.string_to_file(gblocks_oa_nospace.output(:fasta),gene_blo_runs_f)

      #read ortho_std alignment
      #collect sizes
      ortho_std_oa = @ud.fastafile_to_original_alignment(gene_blo_runs_f)

      ortho_std_size = ortho_std_oa.size

      key, seq = ortho_std_oa.shift
      ortho_std_len = seq.length

      #save dimension to database
      this_gene_blo_run.oa_length = gblocks_orig_len
      this_gene_blo_run.blocks_length = gblocks_len
      this_gene_blo_run.save

      puts "#{gn.name},#{orig_size},#{orig_len},#{gblocks_orig_len},#{gblocks_len},#{gblocks_blocks_no},#{ortho_std_size},#{ortho_std_len}"
      

     
    }



  end




  def recomb_run

    #initialize blo_run
    #this_blo_run =  BloRun.find_or_initialize_by_name "first_run"
    #this_blo_run.params = "-t=d  -b5=h -e=-gb"
    #this_blo_run.save 
  
    #puts this_blo_run.id;
   
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


end
