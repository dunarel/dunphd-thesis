 
require 'rubygems'
require 'bio'
require 'msa_tools'

lib_dir = File.expand_path('./', __FILE__)
puts lib_dir


files_dir = File.expand_path('../../files/proc', __FILE__)
filtered_stat_f = "#{files_dir}/verify_deletion_stat.txt"
puts filtered_stat_f


fasta_dir = "#{files_dir}/fasta"
puts fasta_dir

fasta_acces_dir = "#{files_dir}/fasta_acces"
puts fasta_acces_dir





results_hdl = File.open(filtered_stat_f, 'w')



#Dir.chdir(tribesmcl_dir)

ud = UqamDoc::Parsers.new


 genes_100_f = "#{files_dir}/genes_110.csv"

 myarr = FasterCSV.read(genes_100_f)
 
 genes = myarr.collect {|e| e[0]}

 #genes = ["pulA","fliR"]


 genes.each {|gn|

                  
    fasta_f = "#{fasta_dir}/#{gn}.fasta"
    puts "#{fasta_f}" 
     #fasta_f = ".fasta"


          
     #read alignment
     oa = ud.fastafile_to_original_alignment(fasta_f)
     oa.each_pair {
                   
                   
                   }
     puts "oa_size: #{oa.size}"
     
     results_hdl.puts "#{gn},#{oa.size}"
     results_hdl.flush
 }
 
 results_hdl.close
 
       
  
  