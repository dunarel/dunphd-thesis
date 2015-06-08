
require 'web_gen'


namespace :web  do

   

  desc "generate gene_blo_runs index"
  task :gene_blo_runs => :environment do
   
   wg = WebGen.new
   wg.gene_blo_runs_index
 
   
  end



end