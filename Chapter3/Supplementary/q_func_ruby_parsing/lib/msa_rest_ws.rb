
module UqamDoc
  require 'net/http'
  require 'xmlsimple'
  require 'msa_tools'

  class MsaRestWs

    attr_accessor :base_url,
      :tool,
      :job_id

    def initialize(tool)
      @base_url = 'http://www.ebi.ac.uk/Tools/services/rest/'
      @tool= tool
    end

    #List parameter names.
    # input: none
    #output: list of parameters
    #usage: puts cw2.parameters().inspect
    def parameters()

      url = "#{@base_url}/#{@tool}/parameters/"
      uri = URI.parse(url)
      resp = Net::HTTP.get_response(uri)
      params = XmlSimple.xml_in(resp.body)

      return params

    end

    # Get detailed information about a parameter.
    # input: parameter_id
    # output: parameter details
    # usage: puts cw2.parameterdetails('sequence').inspect
    def parameterdetails(parameter_id)

      url= "#{@base_url}/#{@tool}/parameterdetails/#{URI.encode(parameter_id)}"
      uri =  URI.parse(url)
      resp = Net::HTTP.get_response(uri)

      paramdetails = XmlSimple.xml_in(resp.body)

      return paramdetails

    end


    #Submit a job with the specified parameters.
    #input:  already has parameters
    #output: job_id
    def run_params(params)
      #puts "running with #{params.inspect}"

      url="#{@base_url}/#{@tool}/run/"
      uri = URI.parse(url)

      resp, data = Net::HTTP.post_form(uri, params)

      #puts resp.body
      puts data.inspect
   
      #sets a default @job_id
      @job_id= resp.body
    
      return @job_id
      

    end
    
    #Get the status of a submitted job.
    #input: job_id or default @job_id
    def status(*job_id)
      #take default job_id if not specified
      if job_id.empty?
        job_id = @job_id
      else
        job_id = job_id[0]
      end

    
      url="#{@base_url}/#{@tool}/status/#{URI.encode(job_id)}"
      uri = URI.parse(url)

      resp = Net::HTTP.get_response(uri)
      #puts resp.body

      #params = XmlSimple.xml_in(resp.body)

      return resp.body


    end
    
    #input:
    #        job_id
    # usage:
    #        result_types = cw2.resulttypes('clustalw2-R20100126-182328-0939-39161757')
    #        result_types.inspect
    def resulttypes(job_id)
      url="#{@base_url}/#{@tool}/resulttypes/#{URI.encode(job_id)}"
      uri = URI.parse(url)

      resp = Net::HTTP.get_response(uri)
      
      #puts resp.body
      resulttypes = XmlSimple.xml_in(resp.body)
      puts resulttypes.inspect

    end

    
    # get the result
    #input : $jobId: job identifier
    #         result_type: out / aln-phylip
    def result(job_id, result_type)

      url="#{@base_url}/#{@tool}/result/#{URI.encode(job_id)}/#{URI.encode(result_type)}"
      uri = URI.parse(url)

      resp = Net::HTTP.get_response(uri)
      
      return resp.body


    end

    #input: 
    #       job_id
    #       result_type
    #output: 
    #       requested result_type for the job_id
    def result_type_wait(job_id,result_type)
      
      #wait for the result
      nr = 0
      stat = status(job_id)
      until stat == 'FINISHED'
        nr += 1
        puts "status: #{stat}, nr: #{nr}"
        sleep 30
        stat = status(job_id)
      end
      #return requested result_type

      puts resulttypes(job_id).inspect
 
      return result(job_id,result_type)



    end


  end


  class ClustalW2 < MsaRestWs


    def initialize()
      super('clustalw2')

    end
  


       #Submit a dna sequence
    #        sequence
    #output: job_id
    def submit_dna(sequence)


      params = Hash.new
      params['email'] = 'dunarel@gmail.com'
      params['title'] = 'test_web_service'
      params['sequence'] = sequence
      #clustalw2 specific params
      params['format'] = 'fasta' #
      params['alignment'] = 'fast' #slow
      #params['quicktree'] = 0
      params['type'] = 'dna'
      params['output'] = 'phylip'


      #call inherited
      return run_params(params)


    end

    #Submit a protein sequence
    #        sequence
    #output: job_id
    #usage:
    #
    def submit_protein(sequence)


     params = Hash.new
      params['email'] = 'dunarel@gmail.com'
      params['title'] = 'test_web_service'
      params['sequence'] = sequence
      #clustalw2 specific params
      params['format'] = 'fasta' #
      params['alignment'] = 'fast' #slow
      #params['quicktree'] = 0
      params['type'] = 'protein'
      params['output'] = 'phylip'


      #call inherited
      return run_params(params)

    end



    #input:
    #       job_id
    #output: msa fasta string
    def get_msa_wait(job_id)


      aln_phy= result_type_wait(job_id,'aln-phylip')
      #need convertion
      parser = UqamDoc::Parsers.new
      return parser.phylipstring_to_fastastring(aln_phy)



    end




  end

    
  
  
  
  class Mafft < MsaRestWs

    def initialize()
      super('mafft')

    end



    #Submit a dna sequence
    #        sequence
    #output: job_id
    def submit_dna(sequence)


      #clustalw2 specific params
      params = Hash.new
	    params['email'] = 'dunarel@gmail.com'
      params['title'] = 'test_web_service'
      params['sequence'] = sequence
      
 
      #call base class
      return run_params(params)

    end
    
    #Submit a protein sequence
    #        sequence
    #        matrix: jtt100
    #output: job_id
    #usage:
    #
    def submit_protein(sequence,matrix)


      #clustalw2 specific params
      params = Hash.new
	    params['email'] = 'dunarel@gmail.com'
      params['title'] = 'test_web_service'
      params['sequence'] = sequence
      #protein specific
      params['matrix'] = matrix
      
    
      #call base class
      return run_params(params)

    end 

    #input:
    #       job_id
    #output: msa fasta string
    def get_msa_wait(job_id)

      #fasta output exists

      return result_type_wait(job_id,'out')
    

    end




  end


end