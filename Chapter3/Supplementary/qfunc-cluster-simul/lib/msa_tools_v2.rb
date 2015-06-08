

Inf = 1.0/0

#mixin for current method name
#mixin for sys command
module Kernel

  def sys(cmd)
    puts cmd
    puts `#{cmd}`

  end

  private
  def this_method
    caller[0] =~ /`([^']*)'/ and $1
  end
end


module UqamDoc

  require 'rubygems'
  require 'bio'
  require 'bio/io/flatfile'
  require 'bio/db'
  require 'bio/db/newick'

  class Calc



    def self.fraction?(number)
      number - number.truncate
    end

    #http://stackoverflow.com/questions/2609597/calculating-percentiles-ruby
    def self.percentile(param_array, percentage)
      another_array = param_array.to_a.dup
      another_array.push(-1.0/0.0)                   # add -Infinity to be 0th index
      another_array.sort!
      another_array_size = another_array.size - 1    # disregard -Infinity
      r = percentage.to_f * (another_array_size - 1) + 1 #Excel, R
      #r = percentage.to_f * (another_array_size + 1) #wikipedia

      if r <= 1 then return another_array[1]
      elsif r >= another_array_size then return another_array[another_array_size]
      end
      ir = r.truncate
      fr = fraction? r
      another_array[ir] + fr*(another_array[ir+1] - another_array[ir])
    end

  end

  class Parsers

    def get_file_as_string(filename)
      return File.open(filename).read
      #data = ''
      #f = File.open(filename, "r")
      #f.each_line do |line|
      #  data += line
      #end
      #return data
    end


    def fastafile_to_original_alignment(filename)
      oa = Bio::Alignment::OriginalAlignment.new()
      #load sequences from file
      Bio::FlatFile.open(Bio::FastaFormat, filename) { |ff|
        #store sequence from file
        ff.each_entry { |x| oa.add_seq(x.seq,x.entry_id) }
      }
      return oa

    end
    
    #parse fasta file to string
    def fastafile_to_fastastring(filename)
      oa = Bio::Alignment::OriginalAlignment.new()
      #load sequences from file
      Bio::FlatFile.open(Bio::FastaFormat, filename) { |ff|
        #store sequence from file
        ff.each_entry { |x| oa.add_seq(x.seq,x.entry_id) }
      }
      return oa.output(:fasta)

    end

    #write string to file
    def string_to_file(st,filename)
      f = File.new(filename,"w")
      f.puts st
      f.close
    end

    #return fasta string from phylip string
    def phylipstring_to_fastastring(phystr)
      ph=Bio::Phylip::PhylipFormat.new(phystr)
      return ph.alignment.output(:fasta) #output_fasta

    end

    #hash of sequences to fastafile
    def seqshash_to_fastafile(seqs,filename)
      oa = Bio::Alignment::OriginalAlignment.new(seqs)
      string_to_file(oa.output(:fasta),filename)

    end

    #convert to csv
    def fastafile_to_csvfile(fa_f, csv_f)

      oa = fastafile_to_original_alignment(fa_f)
      hs = oa.to_hash
      csv = FasterCSV.open(csv_f, "w")

      arr = hs.to_a.sort {|x,y| x[0].to_i <=> y[0].to_i }
      puts "arr: #{arr[0].inspect}"

      arr.each {|elem|
        puts "#{elem[0]} is #{elem[1]}"
        csv << [elem[0],elem[1]]


      }
      csv.close()

    end

    #extract ids to csv
    def fastafile_to_ids_csvfile(fa_f, csv_f, header = false, quotes = false)
      oa = fastafile_to_original_alignment(fa_f)
      hs = oa.to_hash
      arr = hs.to_a.sort {|x,y| x[0].to_i <=> y[0].to_i }

      csv = FasterCSV.open(csv_f, "w",{:force_quotes => quotes})

      title = %Q!ids!.to_s
      puts title
      csv << [title] if header == true

      arr.each {|elem|
        puts "#{elem[0]} is #{elem[1]}"
        csv << [elem[0]]

      }
      csv.close()

    end

    #read ids to array
    def csvfile_to_array(csv_f, header=true)
      arr_of_arrs = FasterCSV.read(csv_f)
      #puts arr_of_arrs.inspect()
      arr_of_arrs.shift() if header
      arr_of_arrs.flatten!

      return arr_of_arrs
    end

    #write ids
    def array_to_ids_csvfile(arr , csv_f, header = true, quotes = true)

      csv = FasterCSV.open(csv_f, "w",{:force_quotes => quotes})

      title = %Q!ids!.to_s
      #puts title
      csv << [title] if header == true
      arr.each {|key|
        #puts "#{key}"
        csv << [key] 

      }
      csv.close()


    end


    #array to name
    def array_to_name(arr)
      arr = []
      arr = arr.collect{|x| x.to_i}
      txt = arr.sort().join(sep="_")
      return txt
    end

    ##########################   ############################


    def phylipstring_to_phylipfile(phystr,filename)
      #write phylip align
      f = File.new(filename,"w")
      f.puts phystr
      f.close;

    end

    def phylipstring_to_fastafile(phystr,filename)
      ph=Bio::Phylip::PhylipFormat.new(phystr)

      #resultat en fasta
      #puts ph.alignment.output_fasta

      #fasta sur le disque
      f = File.new(filename,"w")
      f.puts ph.alignment.output_fasta
      f.close

    end

    def get_uniform_seq(car,len)
      seq = ""
      (1..len).each {
        seq << car
      }
      return seq
    end
    

    def get_random_seq_na(len, a_rate = 0.25, c_rate = 0.25 , g_rate = 0.25 , t_rate = 0.25)
      s = Bio::Sequence::NA.new("")
      a_nb = (len*a_rate).to_i
      c_nb = (len*c_rate).to_i
      g_nb = (len*g_rate).to_i
      t_nb = len - a_nb -c_nb -g_nb
      equal_composition = {'a' => a_nb, 'c' => c_nb, 'g' => g_nb, 't' => t_nb}
      #puts equal_composition.inspect
      return s.randomize(equal_composition)       #=> "ttaa"  (for example)

    end

    def get_random_seq_aa(len)
      
      #JTT composition
      composition = { 
      'A' => 0.076862,
      'R' => 0.051057,
      'N' => 0.042546, 
      'D' => 0.051269, 
      'C' => 0.020279,
      'Q' => 0.041061,
      'E' => 0.061820,
      'G' => 0.074714,
      'H' => 0.022983,
      'I' => 0.052569,
      'L' => 0.091111,
      'K' => 0.059498,
      'M' => 0.023414,
      'F' => 0.040530,
      'P' => 0.050532,
      'S' => 0.068225,
      'T' => 0.058518,
      'W' => 0.014336,
      'Y' => 0.032303,
      'V' => 0.066374
      }
      
      
      comp = composition.inject({}) { |h, (k, v)| h[k] = (v * 1000000).to_i; h }

     #This last version has the added benefit that you could transform the keys too.
     
          
     s = Bio::Sequence::NA.new("")
     s = s.randomize(comp).subseq(1,len)
     
     
                          
     return s

       


    

    end



    ###################################################################################
    #input:
    #      filename '../alignement/sequences/sequences.gbwithparts'
    def accession_gene_limits(filename)


      ff = Bio::FlatFile.open(Bio::GenBank, filename)

      ff.each_entry do |x|
        puts ''
        #puts x.definition
        #puts x.accession
        #puts x.gi
        #puts x.organism

        x.each_cds() do |feature|

          gene = ''
          product = ''
          translation = ''
          note = ''
          debut = ''
          fin = ''

          feature.each do |qualifier|
            if qualifier.qualifier == 'product'
              #puts "- " + qualifier.qualifier
              product= qualifier.value

            end

            if qualifier.qualifier == 'gene'
              gene= qualifier.value
            end

            if qualifier.qualifier == 'note'
              note= qualifier.value
            end

            if qualifier.qualifier == 'translation'
              translation = qualifier.value
            end
          end


          matched = /[ELXYZ]\d?\w?/.match(gene).to_s

          if matched == ''
            matched = /[ELXYZ]\d?\w?/.match(product).to_s
          end

          if matched == ''
            matched = /[ELXYZ]\d?\w?/.match(note).to_s
          end

          matched.capitalize()



          position= case feature.position
          when /join\((\d+).*\.\.(\d+)\)/:  $1 +'..' + $2
          else feature.position
          end



          debut = position.split("..")[0]
          debut = debut.gsub('<','')

          fin = position.split("..")[1]
          fin = fin.gsub('>','')

          puts " #{x.gi} \t  #{x.accession} \t #{debut}  \t #{fin} \t  #{matched} \t #{product} \t #{translation}"

          
         
        end



      end

    end

    def retrieve_hpv_types_acces()
      #get
      url = 'http://phene.cpmc.columbia.edu/Ictv/fs_papil.htm#Genus01'
      #The URL should not contain illegeal characters. Hence the query parameter which, in many cases,
      #will be accepted as user input, needs to be encoded using the URI.encode method.
      #url = "http://search.yahooapis.com/WebSearchService/V1/webSearch?appid=YahooDemo&query=#{URI.encode("premshree pillai")}&results=1"
      begin
        resp = Net::HTTP.get_response(URI.parse(url)) # get_response takes an URI object



      rescue Exception => e
        puts 'Connection error: ' + e.message
      end

      #parsing de la page web
      hpv_types_acces = {}

      txt= resp.body
      #print resp.to_s + "\n"

      txt.each { |line|
        matched = /\[(.*)\].*\((HPV-.*)\)/.match(line).to_s
        if matched !=''
          accession = $1
          hpv_type = $2
          #puts "----------> #{line}"

          hpv_types_acces[hpv_type]=accession  unless /^NC_/ =~ hpv_types_acces[hpv_type]

          puts "#{accession}:#{hpv_type}"


        end


      }

      return hpv_types_acces
    end

    def parse_ictv_hpv_adn(asked_gene)
    

      # Retrieve the sequence of accession number M33388 from the EMBL
      # database.
      #server = Bio::Fetch.new()  #uses default server
      #puts server.fetch('embl','M33388')

      # Do the same thing without creating a Bio::Fetch object. This method always
      # uses the default dbfetch server: http://bioruby.org/cgi-bin/biofetch.rb
      #puts Bio::Fetch.query('embl','M33388')

      # To know what databases are available on the bioruby dbfetch server:
      #server = Bio::Fetch.new()
      #puts server.databases

      # Some databases provide their data in different formats (e.g. 'fasta',
      # 'genbank' or 'embl'). To check which formats are supported by a given
      # database:
      #puts '-----------------'
      #puts server.formats('embl')

      hpv_types_acces= retrieve_hpv_types_acces()

      ncbi = Bio::NCBI::REST.new
      Bio::NCBI.default_email=('dunarel@gmail.com')

      #recuperate proteins
      hpv_types_prot_seq = {}

      hpv_types_acces.each_pair { |name, val|
        #name = 'HPV-18'
        #val = hpv_types_acces[name]
        #val = hpv_types_acces['HPV-81']
        # entry is a string containing only one entry contents
        entry = ncbi.efetch(val, {"db"=>"nucleotide", "rettype"=>"gb", "retmode" => "text"})
        gb = Bio::GenBank.new(entry)
      

        # shows accession and organism
        #puts "# #{gb.accession} - #{gb.organism}"

        # iterates over each element in 'features'
        gb.features.each do |feature|
          position = feature.position
          hash = feature.assoc            # put into Hash

          # skips the entry if "/translation=" is not found
          next unless hash['translation']

          # collects gene name and so on and joins it into a string
          gene_info = [
            hash['gene'], hash['product'], hash['note'], hash['function']
          ].compact.join(', ')

        
          if hash['gene'] == asked_gene
            # shows nucleic acid sequence
            #puts "gene: #{hash['gene']} => #{gb.naseq.splicing(position)}"
            # shows amino acid sequence translated from nucleic acid sequence
            #puts "gene: #{hash['gene']} => #{gb.naseq.splicing(position).translate}"

            #for proteins
            #hpv_types_prot_seq[name]=gb.naseq.splicing(position).translate
            #for adn
            hpv_types_prot_seq[name]=gb.naseq.splicing(position)

          end
          # shows nucleic acid sequence
          #puts ">NA splicing('#{position}') : #{gene_info}"
          #puts gb.naseq.splicing(position)

          # shows amino acid sequence translated from nucleic acid sequence
          #puts ">AA translated by splicing('#{position}').translate"
          #puts gb.naseq.splicing(position).translate

          # shows amino acid sequence in the database entry (/translation=)
          #puts ">AA original translation"
          #puts hash['translation']
        end



      }
      #ncbi.efetch("J00231", {"db"=>"nuccore", "rettype"=>"gb", "retmode"=>"xml"})
      #ncbi.efetch("AAA52805", {"db"=>"protein", "rettype"=>"gb"})

      return hpv_types_prot_seq
    end

    #using bioruby tutorial
    def parse_ictv_hpv_prot(asked_gene)


      hpv_types_acces= retrieve_hpv_types_acces()

      ncbi = Bio::NCBI::REST.new
      Bio::NCBI.default_email=('dunarel@gmail.com')

      #recuperate proteins
      hpv_types_prot_seq = {}

      hpv_types_acces.each_pair { |name, val|
        #name = 'HPV-18'
        #val = hpv_types_acces[name]
        #val = hpv_types_acces['HPV-81']
        # entry is a string containing only one entry contents
        entry = ncbi.efetch(val, {"db"=>"nucleotide", "rettype"=>"gb", "retmode" => "text"})
        gb = Bio::GenBank.new(entry)


        # shows accession and organism
        #puts "# #{gb.accession} - #{gb.organism}"

        # iterates over each element in 'features'
        gb.features.each do |feature|
          position = feature.position
          hash = feature.assoc            # put into Hash

          # skips the entry if "/translation=" is not found
          next unless hash['translation']

          # collects gene name and so on and joins it into a string
          gene_info = [
            hash['gene'], hash['product'], hash['note'], hash['function']
          ].compact.join(', ')


          if hash['gene'] == asked_gene
            # shows nucleic acid sequence
            #puts "gene: #{hash['gene']} => #{gb.naseq.splicing(position)}"
            # shows amino acid sequence translated from nucleic acid sequence
            #puts "gene: #{hash['gene']} => #{gb.naseq.splicing(position).translate}"

            #for proteins
            hpv_types_prot_seq[name]=gb.naseq.splicing(position).translate
            #for adn
            #hpv_types_prot_seq[name]=gb.naseq.splicing(position)

          end
          # shows nucleic acid sequence
          #puts ">NA splicing('#{position}') : #{gene_info}"
          #puts gb.naseq.splicing(position)

          # shows amino acid sequence translated from nucleic acid sequence
          #puts ">AA translated by splicing('#{position}').translate"
          #puts gb.naseq.splicing(position).translate

          # shows amino acid sequence in the database entry (/translation=)
          #puts ">AA original translation"
          #puts hash['translation']
        end



      }
      #ncbi.efetch("J00231", {"db"=>"nuccore", "rettype"=>"gb", "retmode"=>"xml"})
      #ncbi.efetch("AAA52805", {"db"=>"protein", "rettype"=>"gb"})

      return hpv_types_prot_seq
    end

    #parse the ictv_page for hpv
    #using my original technique
    def parse_ictv_hpv(asked_gene)
      #get
      url = 'http://phene.cpmc.columbia.edu/Ictv/fs_papil.htm#Genus01'
      #The URL should not contain illegeal characters. Hence the query parameter which, in many cases,
      #will be accepted as user input, needs to be encoded using the URI.encode method.
      #url = "http://search.yahooapis.com/WebSearchService/V1/webSearch?appid=YahooDemo&query=#{URI.encode("premshree pillai")}&results=1"
      begin
        resp = Net::HTTP.get_response(URI.parse(url)) # get_response takes an URI object



      rescue Exception => e
        puts 'Connection error: ' + e.message
      end

      #parsing de la page web
      hpv_types_acces = {}

      txt= resp.body
      #print resp.to_s + "\n"

      txt.each { |line|
        matched = /\[(.*)\].*\((HPV-.*)\)/.match(line).to_s
        if matched !=''
          accession = $1
          hpv_type = $2
          #puts "----------> #{line}"

          hpv_types_acces[hpv_type]=accession  unless /^NC_/ =~ hpv_types_acces[hpv_type]

          puts "#{accession}:#{hpv_type}"


        end

              
      }

      puts hpv_types_acces.inspect

      # Retrieve the sequence of accession number M33388 from the EMBL
      # database.
      #server = Bio::Fetch.new()  #uses default server
      #puts server.fetch('embl','M33388')

      # Do the same thing without creating a Bio::Fetch object. This method always
      # uses the default dbfetch server: http://bioruby.org/cgi-bin/biofetch.rb
      #puts Bio::Fetch.query('embl','M33388')

      # To know what databases are available on the bioruby dbfetch server:
      #server = Bio::Fetch.new()
      #puts server.databases

      # Some databases provide their data in different formats (e.g. 'fasta',
      # 'genbank' or 'embl'). To check which formats are supported by a given
      # database:
      #puts '-----------------'
      #puts server.formats('embl')

      ncbi = Bio::NCBI::REST.new
      Bio::NCBI.default_email=('dunarel@gmail.com')

      #recuperate proteins
      hpv_types_prot_seq = {}

      hpv_types_acces.each_pair { |name, val|
        #val = hpv_types_acces['HPV-41']
        #val = hpv_types_acces['HPV-81']
        # entry is a string containing only one entry contents
        entry = ncbi.efetch(val, {"db"=>"nucleotide", "rettype"=>"gb", "retmode" => "text"})
        gb = Bio::GenBank.new(entry)

        gb.each_cds() {|feature|
          gene = ''
          product = ''
          translation = ''
          note = ''
          debut = ''
          fin = ''
          matched =''

          feature.each do |qualifier|
            if qualifier.qualifier == 'product'
              #puts "- " + qualifier.qualifier
              product= qualifier.value

            end

            if qualifier.qualifier == 'gene'
              gene= qualifier.value
            end

            if qualifier.qualifier == 'note'
              note= qualifier.value
            end

            if qualifier.qualifier == 'translation'
              translation = qualifier.value
            end
          end

          #puts "product: #{product}, gene: #{gene}, note: #{note}, translation: #{translation}"

          matched = /[ELXYZ]\d?\w?/.match(gene).to_s

          if matched == ''
            matched = /[ELXYZ]\d?\w?/.match(product).to_s
          end

          matched = /[ELXYZ]\d?\w?/.match(note).to_s if matched == ''

          matched.capitalize()



          position = case feature.position
          when /join\((\d+).*\.\.(\d+)\)/ then  $1 +'..' + $2
          else feature.position
          end



          debut = position.split("..")[0]
          debut = debut.gsub('<','')

          fin = position.split("..")[1]
          fin = fin.gsub('>','')

          if matched == asked_gene
            puts " #{val} \t#{debut}:#{fin} \t gene:#{gene} \t product:#{product} \t note:#{note} \t matched#{matched}  \t #{translation}"

            hpv_types_prot_seq[name]=translation
          end


        }

      }
      #ncbi.efetch("J00231", {"db"=>"nuccore", "rettype"=>"gb", "retmode"=>"xml"})
      #ncbi.efetch("AAA52805", {"db"=>"protein", "rettype"=>"gb"})

      return hpv_types_prot_seq

    end

    #input:
    #      dir: directory
    #      msa_orig_file: msa original alignment
    #      seqs_rand_file: nonaligned random sequences
    #      msa_rand_file: realigned random sequences
    # output:
    #       seqs_rand_file: random aligned file
    # usage:
    #       dir = '/data/PROJETS2/q_func_cpp_68/files/'
    #       dir = '/data/PROJETS2/q_func_ruby_parsing/files/'
    #       msa_orig_file = 'orig_E1.fasta'
    #       seqs_rand_file = 'noalign_random_E1.fasta'
    #       msa_rand_file = 'aligned_E1.fasta'
    def msa_replace_random(dir,msa_orig_file,seqs_rand_file,msa_rand_file)


      rs=PValues::RandomSequences.new


      #all files in same directory
      msa_orig = dir + msa_orig_file
      seqs_rand = dir + seqs_rand_file
      msa_rand =  dir +  msa_rand_file


      rs.gen_random_seqs(msa_orig,seqs_rand)

      parser = UqamDoc::Parsers.new
      seqs = parser.fastafile_to_fastastring(seqs_rand)

      #align
      maf = UqamDoc::Mafft.new #cw2=UqamDoc::ClustalW2.new
      job_id = maf.submit_dna(seqs) #job_id= cw2.submit_dna(seqs)
      #recuperate
      fasta_str = maf.get_msa_wait(job_id) #fasta_str = cw2.get_msa_wait(job_id)
      #puts fasta_str


      parser.string_to_file(fasta_str,msa_rand)






    end



    def parse_prot_matrix()
      matrix_txt = get_file_as_string("/data/PROJETS3/q_func_simul/create_tree/BLOSUM62");
     
      matrix_txt.each { |line|

        #1)
        matched = /(^[A-Za-z\*])(\s+)(.*)/.match(line).to_s
        if matched !=''
          key = $1
          matrix_line = $3
          #puts "----------> #{line}"
        #  puts "key: >#{key}<, matrix_line: >#{matrix_line}<"

          res = matrix_line.split(/\s+/)
          
          res.map! { |item| item.to_i }


          res.map! { |item| "(#{item.to_i})" }


          ln =  "mat_prot_ += list_of #{res.join};"
          puts ln
          #convert to c++ static definition


          #line.scan(/(.)(.)/) {|x,y| print y, x }
          #print "\n"



        end



        #2)


      }

    end



  end
end
