#!/usr/bin/env ruby

require 'rubygems'
require 'pathname'

puts "I'm ok"

here_d = Pathname.new Dir.pwd 
puts "here_d: #{here_d}"

#pdfs_d = here_d + "ol.pdf"

here_d.each_entry {|fl| 
    puts "#{fl}" 
      res =  /(.+)\.pdf/.match(fl.to_s)
   if not res.nil?
      f_name = res[1]
     
 cmd = "pstoedit #{f_name}.pdf #{f_name}.emf -f \"emf:-m -drawbb -OO\""
  
 puts cmd; puts `#{cmd}`
      
   end

 
}

