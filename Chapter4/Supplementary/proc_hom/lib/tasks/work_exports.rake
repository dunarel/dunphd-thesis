
require 'work_exports'

namespace :work  do
   

  desc "export default"
  task :exports => :environment do
   puts "in work:exports.."
   
   we = WorkExport.new

   #we.taxon_ids
   #we.taxids_gis
    we.recomb_transfer_groups_matrix
      
  end
    
end
