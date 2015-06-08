require 'rubygems'
require 'bio'
require 'msa_tools'


ud = UqamDoc::Parsers.new
 str = ud.get_file_as_string('../files/tribemcl/all-vs-all.out')
 #puts "str: #{str}"
 
 rep = Bio::Blast::Report.new(str)
 puts "dblen: #{rep.db_len}"
 
 #rep.each_iteration { |iter|
   #puts iter.inspect
   #puts "--------------------------------"
   #puts rep.query_id
   
   
   #}
 
 
   
 rep.each_hit() { |hit|
   #puts "hit_id: #{hit.hit_id}, target_id: #{hit.target_id}"
   puts "num: #{hit.num}, query_def: #{hit.query_def}, target_def: #{hit.target_def}, evalue: #{hit.evalue}, bit_score: #{hit.bit_score}"
   puts "--------------------------------"  
                
   upair = [hit.query_def,hit.target_def]
   spair = upair.sort { |a,b| a.downcase <=> b.downcase }
   
   a = (upair == spair) ? hit.evalue : nil
   b = (upair == spair) ? nil : hit.evalue
                
   puts "#{spair.inspect}, a: #{a}, b: #{b}"             
   #hit.each { |hsp|
   #    puts hsp.          
   #   }
   
   }
 
