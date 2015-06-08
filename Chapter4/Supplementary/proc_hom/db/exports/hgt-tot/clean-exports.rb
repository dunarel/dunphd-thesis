#!/usr/bin/env ruby
 
require 'pathname'
 
here = Pathname.new Dir.pwd()

 ["family","habitat"].each {|crit|
   
    fld  = here + crit + "data"
    cmd = "rm -fr #{fld}/*"; puts cmd; puts `#{cmd}`
                           

  ["rel"].each {|ct|
    
   ["csv","dat","emf","pdf","png","svg","xls"].each {|ext|
      fld  = here + crit + ct + ext
 
      #puts "fld: #{fld}"

      cmd = "rm -fr #{fld}/*"; puts cmd; puts `#{cmd}`

                                                    
      
                                                    
    }

  }

} 

   
