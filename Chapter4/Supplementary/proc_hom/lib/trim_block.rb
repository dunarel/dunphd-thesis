 
require 'rubygems'
require 'bio'
require 'msa_tools'

base_dir = File.expand_path('../../', __FILE__)
puts "base_dir: #{base_dir}"

files_dir = "#{base_dir}/files/proc"


results_f = "#{files_dir}/trim_block.out"
puts "results_f: #{results_f}"

results_hdl = File.open(results_f, 'w')
#headers
results_hdl.puts "GENE,ORIG_SIZE,ORIG_LEN,GBL_ORIG_LEN,GBL_LEN,GBL_BL,ORTHO_STD_SIZE,ORTHO_STD_LEN"

ortho_msa_dir = "#{files_dir}/ortho_msa"
puts "ortho_msa_dir: #{ortho_msa_dir}"

#Dir.chdir(ortho_msa_dir)

ortho_std_dir = "#{files_dir}/ortho_std"
puts "ortho_std_dir: #{ortho_std_dir}"





ud = UqamDoc::Parsers.new


 genes_100_f = "#{files_dir}/genes_110.csv"

 myarr = FasterCSV.read(genes_100_f)
 
 genes = myarr.collect {|e| e[0]}

 #genes = ["pulA","fliR"]


 genes.each {|gn|

                  
    fasta_f = "#{ortho_msa_dir}/#{gn}.fasta"
    gblocks_res_f = "#{ortho_msa_dir}/gblocks.res"
    
    gblocks_f = "#{ortho_msa_dir}/#{gn}.fasta-gb"
    gblocks_f_htm = "#{ortho_msa_dir}/#{gn}.fasta-gb.htm"
    ortho_std_f = "#{ortho_std_dir}/#{gn}.fasta"
 

 #    clusters_f = "all-vs-all.mclout"

  #   clusters_s = File.open(clusters_f).read
 
    
  #   clusters_a = clusters_s.split("\n")
  #   clusters_a = clusters_a.collect {|row| row.split("\t") }
     #puts clusters_a.inspect
  
     #puts clusters_a.flatten.count
     #puts clusters_a[0].count
      
   #  deleted_keys_a = clusters_a.slice(1,clusters_a.length-1).flatten
   #  deleted_keys_nb = deleted_keys_a.count
     
     
     #read alignment
     oa = ud.fastafile_to_original_alignment(fasta_f)
    orig_size = oa.size           
    #first sequence length
    key, seq = oa.shift
    orig_len = seq.length
    
    half_size = (orig_size/2).to_i + 2
               
     sys "Gblocks #{fasta_f} -t=p  -b1=#{half_size} -b2=#{half_size} -b3=10 -b4=5 -b5=h -e=-gb > #{gblocks_res_f}"
     gblocks_res  = File.open(gblocks_res_f).read
     
     gblocks_orig_len = gblocks_res.scan(/Original\salignment\:\s+(\d+)/)[0][0].to_i
     
     gblocks_len =  gblocks_res.scan(/Gblocks\salignment\:\s+(\d+)/)[0][0].to_i
     gblocks_blocks_no = gblocks_res.scan(/in\s(\d+)\sselected/)[0][0].to_i          
     puts gblocks_res
               
     #reread the gblocks alignment
     #correct for spaces introduced 
     gblocks_oa = ud.fastafile_to_original_alignment(gblocks_f)
     gblocks_oa_nospace = gblocks_oa.alignment_collect {|seq| seq.sub(/\s/, '')}
     #clean temporary files
     File.delete(gblocks_f)
     File.delete(gblocks_f_htm)
     File.delete(gblocks_res_f)
     #write corrected file to ortho_std
     ud.string_to_file(gblocks_oa_nospace.output(:fasta),ortho_std_f)           
               
      #read ortho_std alignment
      #collect sizes
      ortho_std_oa = ud.fastafile_to_original_alignment(ortho_std_f)
      
      ortho_std_size = ortho_std_oa.size
               
     key, seq = ortho_std_oa.shift
      ortho_std_len = seq.length
    
             
               
     #puts "oa_size: #{oa.size}"
    # ud.string_to_file(oa.output(:fasta),"#{ortho_dir}/#{fasta_f}") 
    # all_clusters_size = clusters_a.flatten.count
    # first_cluster_size = clusters_a[0].count
    # first_cluster_obtainedsize = oa.size
                    
    # del_ratio = first_cluster_obtainedsize.to_f / all_clusters_size.to_f
     
     results_hdl.puts "#{gn},#{orig_size},#{orig_len},#{gblocks_orig_len},#{gblocks_len},#{gblocks_blocks_no},#{ortho_std_size},#{ortho_std_len}"
     results_hdl.flush
 }
 
 results_hdl.close
 
       
  
  