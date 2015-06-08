
module PValues

  require 'rubygems'
  require 'bio'
  require 'bio/io/flatfile'
  require 'bio/db'
  require 'bio/db/newick'

  require 'mathn'

  require 'soap/wsdlDriver'
  require 'base64'

  require 'msa_rest_ws'
  require 'msa_tools'

  class RandomSequences

    def gen_rand_dna_seq(len)
      rand_dna_seq = ''
      dna_alphabet = 'ACGT'
      (1..len).each { |i|
        nucl_idx = rand() * dna_alphabet.length
        rand_dna_seq += dna_alphabet[nucl_idx,1]



      }
      #puts rand_dna_seq

      return rand_dna_seq
    end

    #Take a msa file and generate a nonaligned random fasta file of equivalent length
    #input: 
    #       msa file
    #output: 
    #       nonalign random file
    #       
    def gen_random_seqs(msa_file,noalign_random_file)

      #read simple fasta file
      puts `pwd`


      len_align = 0;

      #create new OriginalAlignment
      oa = Bio::Alignment::OriginalAlignment.new()
      #load sequences from file
      Bio::FlatFile.open(Bio::FastaFormat, msa_file) { |ff|
        #store sequence from file
        ff.each_entry { |x| oa.add_seq(x.seq,x.entry_id) }
      }

      #remove gaps
      oa.remove_all_gaps!
      #determine ungaped length
      #oa.each_seq { |seq| len_align=[len_align,seq.length].max }
      #show it
      len_align = oa.alignment_length

      #store random sequence
      oa = oa.alignment_collect {|key| key = gen_rand_dna_seq(len_align) }

      #puts oa.output(:fasta)

      #puts result on disk
      simple_seqs_file = File.new(noalign_random_file,"w")
      simple_seqs_file.puts(oa.output_fasta)
      simple_seqs_file.close;
    
    end


=begin
      #oa.each_entry { |x| seqs._store_(x.entry_id,gen_rand_dna_seq(20))}


      #prepare container for sequences
      #seqs = Bio::Alignment::SequenceHash.new



          

      #create new OriginalAlignment
      #oa = Bio::Alignment::OriginalAlignment.new(seqs)
      #seqs= oa.remove_all_gaps.to_hash

      #seqs.each_value { |value| len_align=[len_align,value.length].max }
      #puts len_align

      #change sequeces
      #oa.each_pair { |k,s| puts k  oa[k]=s<< "bla" }

      #show output
      #oa = Bio::Alignment::OriginalAlignment.new(seqs)
      #puts oa.output(:fasta)

      #


=end

    def mult_align_soap()

      #create new OriginalAlignment
      oa = Bio::Alignment::OriginalAlignment.new()
      #load sequences from file
      Bio::FlatFile.open(Bio::FastaFormat, '/data/PROJETS2/q_func_cpp_68/files/gene_noalign_random_E1.fasta') { |ff|
        #store sequence from file
        ff.each_entry { |x| oa.add_seq(x.seq,x.entry_id) }
      }

      #puts oa.output(:fasta)

      #on aligne les sequences
      # URL for the service WSDL
      #wsdl = 'http://www.ebi.ac.uk/Tools/webservices/wsdl/WSFasta.wsdl'
      wsdl = 'http://www.ebi.ac.uk/Tools/webservices/wsdl/WSClustalW.wsdl'

      # Get the object from the WSDL
      #fastaSoap = SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
      clustalw_soap = SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver

      # set the necessary parameters
      params = Hash.new
      # params['program'] = 'blastp'
      # params['database'] = 'swissprot'
      params['email'] = 'dunarel@gmail.com'
      params['async'] = 1
      params['align'] = 1
      params['alignment'] = 'full'
      #params['quicktree'] = 0
      params['output'] = 'phylip'

      # Read in input sequence from a file called sequence.fasta
      #inFile = File.new('sequence.fasta', 'r')
      #sequence = inFile.gets(nil)

      # data = [{'type'=>'sequence', 'content'=>sequence}]
      content = [{'type'=>'sequence', 'content'=>oa.output(:fasta)}]

      #jobId = fastaSoap.runFasta(params, data)
      job_id = clustalw_soap.runClustalW(params, content)

      puts "job_id: #{job_id}"
      
      puts "---------------00000000000000000000-------------"
      # the server returns a job identifier
      # you can use it to check the status of your job
      nr = 0
      result = 'RUNNING'
      while result=='RUNNING'
        sleep 30
        nr += 1
        #result = fastaSoap.checkStatus(argHash['jobid'])
        result = clustalw_soap.checkStatus(job_id)

        puts "result: #{result}, nr: #{nr}"
      end

      if result=='DONE'
        # puts fastaSoap.polljob(jobId, 'tooloutput')
        #results = fastaSoap.getResults(jobId)
        results0 = clustalw_soap.getResults(job_id)
        puts results0.inspect

        #tooloutput = clustalwSoap.poll(jobId, 'tooloutput')
        #to = Base64.decode64(tooloutput)
        #puts to

        toolaln = clustalw_soap.poll(job_id, 'toolaln')
        ta = Base64.decode64(toolaln)

        #write phylip align
        f = File.new('/data/PROJETS2/q_func_cpp_68/files/gene_align_random_E1.phy',"w")
        f.puts ta
        f.close;


        ph=Bio::Phylip::PhylipFormat.new(ta)

        #resultat en fasta
        #puts ph.alignment.output_fasta

        #fasta sur le disque
        f = File.new('/data/PROJETS2/q_func_cpp_68/files/gene_align_random_E1.fasta',"w")
        f.puts ph.alignment.output_fasta
        f.close;


        #tooldnd = clustalwSoap.poll(jobId, 'tooldnd')
        #td = Base64.decode64(tooldnd)
        #puts td
      end





    end

    def mult_align_clustalw2_soap()

      #create new OriginalAlignment
      oa = Bio::Alignment::OriginalAlignment.new()
      #load sequences from file
      Bio::FlatFile.open(Bio::FastaFormat, '/data/PROJETS2/q_func_cpp_68/files/gene_noalign_random_E1.fasta') { |ff|
        #store sequence from file
        ff.each_entry { |x| oa.add_seq(x.seq,x.entry_id) }
      }

      #puts oa.output(:fasta)

      #on aligne les sequences
      # URL for the service WSDL
      wsdl = 'http://www.ebi.ac.uk/Tools/services/soap/clustalw2?wsdl'

      # Get the object from the WSDL
      #fastaSoap = SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
      clustalw_soap = SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver


      # set the necessary parameters
      params = Hash.new
      # params['program'] = 'blastp'
      # params['database'] = 'swissprot'
      params['email'] = 'dunarel@gmail.com'
      #params['async'] = 1
      #params['align'] = 1
      params['alignment'] = 'fast' #slow
      params['type']= 'dna' #protein
      #params['quicktree'] = 0
      params['output'] = 'phylip' #aln1 aln2 gcg pir gde
      params['outorder'] = 'aligned'
      params['sequence'] = oa.output(:fasta)
      # Read in input sequence from a file called sequence.fasta
      #inFile = File.new('sequence.fasta', 'r')
      #sequence = inFile.gets(nil)

      # data = [{'type'=>'sequence', 'content'=>sequence}]
      #content = [{'type'=>'sequence', 'content'=>oa.output(:fasta)}]

      run_params = InputParameters
      run_params['email'] = 'dunarel@gmail.com'
      #run_params['title'] = 'alignment_test'
      run_params['parameters'] = params

           
      get_par= clustalw_soap.getParameters([])
      
      puts get_par.inspect

      par_det = clustalw_soap.getParameterDetails({'parameterId' => 'sequence'})
      puts par_det.inspect

      #job_id = clustalw_soap.run(run_params)
     
=begin
      

      puts "job_id: #{job_id}"

      puts "---------------00000000000000000000-------------"
      # the server returns a job identifier
      # you can use it to check the status of your job
      nr = 0
      result = 'RUNNING'
      while result=='RUNNING'
        sleep 30
        nr += 1
        #result = fastaSoap.checkStatus(argHash['jobid'])
        result = clustalw_soap.checkStatus(job_id)

        puts "result: #{result}, nr: #{nr}"
      end

      if result=='DONE'
        # puts fastaSoap.polljob(jobId, 'tooloutput')
        #results = fastaSoap.getResults(jobId)
        results0 = clustalw_soap.getResults(job_id)
        puts results0.inspect

        #tooloutput = clustalwSoap.poll(jobId, 'tooloutput')
        #to = Base64.decode64(tooloutput)
        #puts to

        toolaln = clustalw_soap.poll(job_id, 'toolaln')
        ta = Base64.decode64(toolaln)

        #write phylip align
        f = File.new('/data/PROJETS2/q_func_cpp_68/files/gene_align_random_E1.phy',"w")
        f.puts ta
        f.close;


        ph=Bio::Phylip::PhylipFormat.new(ta)

        #resultat en fasta
        #puts ph.alignment.output_fasta

        #fasta sur le disque
        f = File.new('/data/PROJETS2/q_func_cpp_68/files/gene_align_random_E1.fasta',"w")
        f.puts ph.alignment.output_fasta
        f.close;


        #tooldnd = clustalwSoap.poll(jobId, 'tooldnd')
        #td = Base64.decode64(tooldnd)
        #puts td
      end



=end

    end

    def mult_align_clustalw2_soap4r()


      #create new OriginalAlignment
      oa = Bio::Alignment::OriginalAlignment.new()
      #load sequences from file
      Bio::FlatFile.open(Bio::FastaFormat, '/data/PROJETS2/q_func_cpp_68/files/gene_noalign_random_E1.fasta') { |ff|
        #store sequence from file
        ff.each_entry { |x| oa.add_seq(x.seq,x.entry_id) }
      }

      


      wsdl = 'http://www.ebi.ac.uk/Tools/services/soap/clustalw2?wsdl'
      clust_soap4r = SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver
      #clust_soap4r.wiredump_dev = STDOUT



      # set the necessary parameters
      params = Hash.new
      # params['program'] = 'blastp'
      # params['database'] = 'swissprot'
      params['email'] = 'dunarel@gmail.com'
      #params['async'] = 1
      #params['align'] = 1
      params['alignment'] = 'fast' #slow
      params['type']= 'dna' #protein
      #params['quicktree'] = 0
      params['output'] = 'phylip' #aln1 aln2 gcg pir gde
      params['outorder'] = 'aligned'
      params['sequence'] = oa.output(:fasta)
      # Read in input sequence from a file called sequence.fasta
      #inFile = File.new('sequence.fasta', 'r')
      #sequence = inFile.gets(nil)

      # data = [{'type'=>'sequence', 'content'=>sequence}]
      #content = [{'type'=>'sequence', 'content'=>oa.output(:fasta)}]

      run_params = {}
      run_params['email'] = 'dunarel@gmail.com'
      run_params['title'] = 'alignment_test'
      run_params['parameters'] = params

      puts run_params.inspect


      get_par= clust_soap4r.getParameters([])

      puts get_par.inspect

      par_det = clust_soap4r.getParameterDetails({'parameterId' => 'sequence'})
      puts par_det.inspect

      job_id =   clust_soap4r.run(run_params)


    end

    def  clustalw2_info()
      wsdl = 'http://www.ebi.ac.uk/Tools/services/soap/clustalw2?wsdl'
      clustalw2 = SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver


      get_par= clustalw2.getParameters([])

      puts get_par.inspect

      par_det = clustalw2.getParameterDetails({'parameterId' => 'sequence'})
      puts par_det.inspect

    end

    #like first clustalw
    def clustalw2_rpc()


      oa = Bio::Alignment::OriginalAlignment.new()
      #load sequences from file
      Bio::FlatFile.open(Bio::FastaFormat, '/data/PROJETS2/q_func_cpp_68/files/gene_noalign_random_E1.fasta') { |ff|
        #store sequence from file
        ff.each_entry { |x| oa.add_seq(x.seq,x.entry_id) }
      }

      wsdl = 'http://www.ebi.ac.uk/Tools/webservices/wsdl/WSClustalW2.wsdl'
      clustalw2 = SOAP::WSDLDriverFactory.new(wsdl).create_rpc_driver

      # set the necessary parameters
      params = Hash.new
      # params['program'] = 'blastp'
      # params['database'] = 'swissprot'
      params['email'] = 'dunarel@gmail.com'
      params['async'] = 1
      params['align'] = 1
      params['alignment'] = 'full'
      #params['quicktree'] = 0
      params['output'] = 'phylip'

      # Read in input sequence from a file called sequence.fasta
      #inFile = File.new('sequence.fasta', 'r')
      #sequence = inFile.gets(nil)

      # data = [{'type'=>'sequence', 'content'=>sequence}]
      content = [{'type'=>'sequence', 'content'=>oa.output(:fasta)}]

      #jobId = fastaSoap.runFasta(params, data)
      job_id = clustalw_soap.runClustalW(params, content)

      puts "job_id: #{job_id}"

    end


    def example_rest()


      #get
      url = 'http://search.yahooapis.com/WebSearchService/V1/webSearch?appid=YahooDemo&query=madonna&results=1'
      #The URL should not contain illegeal characters. Hence the query parameter which, in many cases,
      #will be accepted as user input, needs to be encoded using the URI.encode method.
      url = "http://search.yahooapis.com/WebSearchService/V1/webSearch?appid=YahooDemo&query=#{URI.encode("premshree pillai")}&results=1"
      begin
        resp = Net::HTTP.get_response(URI.parse(url)) # get_response takes an URI object



      rescue Exception => e
        puts 'Connection error: ' + e.message
      end

      #print resp.body
      #print resp.to_s + "\n"

      #post
      url = URI.parse('http://search.yahooapis.com/ContentAnalysisService/V1/termExtraction')
      appid = 'YahooDemo'

      context = 'Italian sculptors and painters of the renaissance favored
the Virgin Mary for inspiration'
      query = 'madonna'

      post_args = {
        'appid' => appid,
        'context' => context,
        'query' => query
      }

      resp, data = Net::HTTP.post_form(url, post_args)

      #puts resp.body
      puts resp.inspect


      #authentication
=begin
require 'net/https'
http = Net::HTTP.new('api.del.icio.us', 443)
http.use_ssl = true
http.start do |http|
   req = Net::HTTP::Get.new('/v1/tags/get')

   # we make an HTTP basic auth by passing the
   # username and password
   req.basic_auth 'username', 'password'

   resp, data = http.request(req)
end

=end
    end





  end

end



 parser = UqamDoc::Parsers.new
 #parser.msa_replace_random('/data/PROJETS2/q_func_ruby_parsing/files/nucl/', 'orig_E1.fasta', 'noalign_random_E1.fasta','aligned_random_E1.fasta')
 #maf = UqamDoc::Mafft.new
    #puts  maf.parameters.inspect
    #puts maf.parameterdetails('matrix').inspect



seqs = parser.parse_ictv_hpv('E6')
puts seqs.inspect

seqs.delete('HPV-42')
seqs.delete('HPV-cand91')
seqs.delete('HPV-cand96')


parser.seqshash_to_fastafile(seqs, '/data/PROJETS2/q_func_cpp_68/files/amino/hpv_proteins_E6.fasta')

seqs_file = '/data/PROJETS2/q_func_cpp_68/files/amino/hpv_proteins_E6.fasta'
msa_file = '/data/PROJETS2/q_func_cpp_68/files/amino/msa_hpv_proteins_E6.fasta'
parser = UqamDoc::Parsers.new
seqs = parser.fastafile_to_fastastring(seqs_file)

      #align
      maf = UqamDoc::Mafft.new #cw2=UqamDoc::ClustalW2.new
      job_id = maf.submit_protein(seqs, 'jtt100') #job_id= cw2.submit_dna(seqs)
      #recuperate
      fasta_str = maf.get_msa_wait(job_id) #fasta_str = cw2.get_msa_wait(job_id)
      #puts fasta_str


      parser.string_to_file(fasta_str,msa_file)





