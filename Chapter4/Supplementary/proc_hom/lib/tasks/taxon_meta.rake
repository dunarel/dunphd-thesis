
require 'taxon_meta'
require 'faster_csv'


namespace :taxon_meta  do

   

  desc "launch testing code"
  task :default => :environment do
   
    tm = TaxonMeta.new("Habitat")
    tm.read_overview_lst()
    
     
   
  end

  task :test => :environment do
  
    tm = TaxonMeta.new("Habitat")
    tm.ncbi_taxid = 288000
    goldstamp = tm.calc_goldstamp()
    #tm.goldstamp="Gc00454"
    
    #puts "goldstamp: #{goldstamp}"
    
    tm.calc_gold_attr()
    

    #overview_lst =  tm.calc_overview_lst
    #puts "overview_lst: #{tm.overview_lst}"

  end
  



end