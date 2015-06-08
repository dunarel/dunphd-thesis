 
require 'rubygems'
require 'bio'
require 'msa_tools'

lib_dir = File.expand_path('./', __FILE__)
puts lib_dir

tribesmcl_dir = File.expand_path('../../files/tribemcl', __FILE__)
puts tribesmcl_dir

files_dir = File.expand_path('../../files/proc', __FILE__)
filtered_stat_f = "#{files_dir}/filtered_stat.txt"
puts filtered_stat_f

results_hdl = File.open(filtered_stat_f, 'w')

ortho_dir = File.expand_path('../../files/proc/ortho', __FILE__)
puts ortho_dir



Dir.chdir(tribesmcl_dir)

ud = UqamDoc::Parsers.new


 genes_100_f = "/data/PROJETS4/proc_hom/files/proc/genes_110.csv"

 myarr = FasterCSV.read(genes_100_f)
 
 genes = myarr.collect {|e| e[0]}

 #genes = ["pulA","fliR"]


 genes.each {|gn|

                  
    fasta_f = "#{gn}.fasta"
     
     #fasta_f = ".fasta"


     sys "sh clean.sh"
     puts Dir.entries(Dir::pwd)
     #sleep 20
     sys "sh run.sh #{fasta_f}"
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
     
     
     #read alignment
     oa = ud.fastafile_to_original_alignment(fasta_f)
     deleted_keys_a.each { |k|
      oa.delete(k)                     
     }
     puts "oa_size: #{oa.size}"
     ud.string_to_file(oa.output(:fasta),"#{ortho_dir}/#{fasta_f}") 
     all_clusters_size = clusters_a.flatten.count
     first_cluster_size = clusters_a[0].count
     first_cluster_obtainedsize = oa.size
                    
     del_ratio = first_cluster_obtainedsize.to_f / all_clusters_size.to_f
     
     results_hdl.puts "#{gn},#{all_clusters_size},#{first_cluster_size},#{first_cluster_obtainedsize},#{del_ratio},#{deleted_keys_nb},#{deleted_keys_a.inspect}"
     results_hdl.flush
 }
 
 results_hdl.close
 
       
  
  