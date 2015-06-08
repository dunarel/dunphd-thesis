 
require 'rubygems'
require 'bio'
require 'msa_tools'
require 'msa_rest_ws'

#file configurations
lib_dir = File.expand_path('./', __FILE__)
puts lib_dir


files_dir = File.expand_path('../../files/proc', __FILE__)
ortho_msa_f = "#{files_dir}/ortho_msa.csv"
puts ortho_msa_f

results_hdl = File.open(ortho_msa_f, 'w')

ortho_dir = File.expand_path('../../files/proc/ortho', __FILE__)
puts ortho_dir

ortho_msa_dir = File.expand_path('../../files/proc/ortho_msa', __FILE__)
puts ortho_msa_dir

 ud = UqamDoc::Parsers.new


 genes_100_f = File.expand_path('../../files/proc/genes_110.csv', __FILE__)
 
 
 myarr = FasterCSV.read(genes_100_f)
 
 genes = myarr.collect {|e| e[0]}

 #genes = ["pulA","fliR"]

Dir.chdir(files_dir)


 genes.each {|gn|

    in_f = "#{ortho_dir}/#{gn}.fasta"
    out_f = "#{ortho_msa_dir}/#{gn}.fasta"
     
    sys "muscle -in #{in_f} -out #{out_f}"
  
     #read alignment
     oa = ud.fastafile_to_original_alignment(out_f)

     puts "oa_size: #{oa.size}"
   
     results_hdl.puts "#{gn},#{oa.size}"
     results_hdl.flush
 }
 
 results_hdl.close
 
 
=begin
   myrestws = UqamDoc::MsaRestWs.new('muscle')
     puts myrestws.parameters.inspect
     puts myrestws.parameterdetails('order').inspect
               
     params = Hash.new
      params['email'] = 'dunarel@gmail.com'
      params['title'] = 'test_web_service'
      params['sequence'] = oa.output(:fasta)
      #clustalw2 specific params
      params['format'] = 'fasta' #
      params['order'] = 'aligned' #
      
      #params['alignment'] = 'fast' #slow
      #params['quicktree'] = 0
      #params['type'] = 'dna'
      #params['output'] = 'phylip'


      #call inherited
      jobid = myrestws.run_params(params)
      puts jobid
      puts myrestws.result_type_wait(jobid,'out')

 
 
=end
       
  
  