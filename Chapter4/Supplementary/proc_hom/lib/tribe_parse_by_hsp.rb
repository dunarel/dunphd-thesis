require 'rubygems'
require 'bio'
require 'msa_tools'


ud = UqamDoc::Parsers.new
 str = ud.get_file_as_string('../files/tribemcl/all-vs-all.out')
 #puts "str: #{str}"
 
 rep = Bio::Blast::Report.new(str)
 #puts "dblen: #{rep.db_len}"
 
 #rep.each_iteration { |iter|
   #puts iter.inspect
   #puts "--------------------------------"
   #puts rep.query_id
   
   
   #}
 
 
 #works by hsps  
 rep.each_hit() { |hit|
   #puts "hit_id: #{hit.hit_id}, target_id: #{hit.target_id}"
   #puts "num: #{hit.num}, query_def: #{hit.query_def}, target_def: #{hit.target_def}, evalue: #{hit.evalue}, bit_score: #{hit.bit_score}"
   #puts "--------------------------------"  

   #frac, exp = Math.frexp(hit.evalue)
                  
   hit.each { |hsp|
   eval = hsp.evalue.to_s
   #accepts a string of numbers in scientific notation
   #returns an array of [float,int] pairs
   pat = /([-|\+]?\d\.\d*)e-(\d+)/
   eval_arr=eval.scan(pat).map{|num,exp| [num.to_i, exp.to_i]}
   x,y = eval_arr.shift
     
   x,y = 1,200 if hit.evalue == 0
            
     #puts "#{hit.num}\t#{hsp.num}\t#{hit.query_def}\t#{hit.target_def}\t#{x}\t#{y}"
   puts "#{hit.query_def}\t#{hit.target_def}\t#{x}\t#{y}"
             
            }
   
               
               
   #puts "#{spair.inspect}, a: #{a}, b: #{b}"             
   #hit.each { |hsp|
   #    puts hsp.          
   #   }
   
   }
 
