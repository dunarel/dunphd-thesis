#!/home/badescud/local/bin/ruby

 require 'yaml'
 require 'pathname'
 require 'optparse'

class GenTreeplCfg

 def initialize
   self.load_mrcas_yaml
   @mrca_activ = []
   @mrcas.length.times { @mrca_activ << false } 

   puts "@mrca_activ: #{@mrca_activ.inspect}"

   parse_cmdline()

 end

  def parse_cmdline
    #config
    $options = {}
    option_parser = OptionParser.new do |opts|

      opts.on("--align-len NB") do |it|
       $align_len = it
      end

    end
    #parse
    option_parser.parse!
    puts $options.inspect
    puts "$align_len: #{$align_len}"
  end

  def load_mrcas_yaml
   mrcas_f = "mrcas.yaml"
   puts "mrcas_f: #{mrcas_f}"

    mrcas_yaml = File.read(mrcas_f)
    #mrcas_yaml = mrcas_yaml.gsub("!ruby/object:HgtParFen","")
    @mrcas = YAML.load(mrcas_yaml)

    puts @mrcas.inspect


    @dated_tree_f = Pathname.new "dated_tree.nwk"

 end

 def write_file


   treepl_cfg_f = "gene_res.cfg"
   nb_threads = 1
   align_len = 100

  
   #Start with small error probability
   max_rnd = 20

   #test activate constraints
   (0..@mrcas.length-1).each do |x|

        
    #for each constraint take maximum dynamic probability
     nb_rnd = max_rnd
     passed = false
          
    while (passed == false && nb_rnd >= 0 ) do
         
    mrcas_str = ""
    #include previous activated constraints
    (0..x-1).each { |prev_idx|
     if (@mrca_activ[prev_idx] == true ) 
       mrcas_str += @mrcas[prev_idx]
       mrcas_str += "\n"
     end
    }

    #all cases include current step 
    mrcas_str += @mrcas[x]
    #test current constraints 
    out = File.open(treepl_cfg_f, 'w')
    
    out.puts "treefile  = gene_rooted.nwk"
    out.puts "smooth = 100" 
    out.puts "numsites = #{$align_len}"
    out.puts 
    #add all current constrains
    out.puts mrcas_str
    out.puts "outfile = dated_tree.nwk"
    out.puts "nthreads = #{nb_threads}"

    #add final optimisation
    out.puts "thorough"
    out.close
    #give disk time to flush
    sleep 0.2
    #execute
    begin
     @mrca_activ[x] = true
     puts "Activated constraint #{x}"
     res = `treePL gene_res.cfg`
     #puts "res: #{res}"
     #activate constraint if execution successfull
     #decision is based on process not result 
     #as in complete transfers jruby version
    rescue
      @mrca_activ[x] = false
      puts "Error constraint #{x}"
    end

    if @dated_tree_f.size?
      puts "file succeeded"
    else
      puts "file zero"
      @mrca_activ[x] = false
      puts "Error constraint #{x}"

    end
    #      Pattern p = Pattern.compile("(problem)\\s(initializing)");
    #        stdout.flush();
    #        Matcher m = p.matcher(stdout.toString());
    #             if (m.find()) {
    #            System.out.println("g0: " + m.group(0));
    #            //inactivate mrca
    #            mrcaActiv[x] = false;
    #            System.out.println("Problem constraint " + x);
    #               };#

    #skip retry if activated
    if ( @mrca_activ[x] == true) 
     passed = true
    else 
     nb_rnd -= 1
     puts "Go into retry: #{nb_rnd}"
    end
   end #end while retry passed
   
   #if activated after some work
   if ( @mrca_activ[x] == true && nb_rnd != max_rnd) 
     #next activations more difficult
     #so give more chances
     max_rnd += 5
     puts "Increased maxRnd to: #{max_rnd}"
   
   end
      
   
  end #end each x

   #
   puts "final constraints: #{@mrca_activ.inspect}"
   

   mrcas_str = ""      
   (0..@mrcas.length-1).each { |i|
     if (@mrca_activ[i] == true )
       mrcas_str += @mrcas[i]
     else
       mrcas_str += @mrcas[i].split("\n").collect{ |z| "# #{z}"}.join("\n")
     end
     mrcas_str += "\n"
   }
   #
    #test current constraints 
    out = File.open(treepl_cfg_f, 'w')
    
    out.puts "treefile  = gene_rooted.nwk"
    out.puts "smooth = 100" 
    out.puts "numsites = #{$align_len}"
    out.puts 
    #add all current constrains
    out.puts mrcas_str
    out.puts "outfile = dated_tree.nwk"
    out.puts "nthreads = #{nb_threads}"

    #add final optimisation
    out.puts "thorough"
    out.close
    #give disk time to flush
    sleep 0.2
    #execute
    puts "Final execution"    
    nb_rnd = 40
    passed = false
    while (passed == false && nb_rnd >= 0 ) do
    
     begin
      res = `treePL gene_res.cfg`
      #puts "res: #{res}"
      #activate constraint if execution successfull
      #decision is based on process not result 
      #as in complete transfers jruby version
     rescue
       puts "Error final execution"
     end
     
     if @dated_tree_f.size?
       passed = true
     else
       passed = false 
       puts "Final execution, retry !"
     end
    
   end


 end

end

 gtc = GenTreeplCfg.new
 gtc.write_file

 puts "ok"

