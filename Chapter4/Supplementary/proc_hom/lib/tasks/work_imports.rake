
require 'work_imports'

namespace :work  do
   

  desc "import default"
  task :imports => :environment do
   puts "in work:imports.."
   
   wi = WorkImports.new

   wi.taxons_sci_names
      
  end
    
end
