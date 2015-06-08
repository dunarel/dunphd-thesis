
require 'appl_work'
require 'db_admin_ms'

namespace :lib  do

   

  desc "launch regular work task"
  task :run => :environment do
   
   pc = ApplWork.new
   #pc.parse_genes
   #pc.select_genes
   #pc.parse_gene_seqs

   #pc.parse_gene_seqs_info
 
  #pc.retrieve_naseq
   #pc.ortho_run
   #pc.msa_run
   pc.blo_run
   #pc.recomb_run
    

   #pc.execute
 
   
  end



  desc "launch master tasks"
  task :ms_launch => :environment do
    #print "How many fake people do you want?"
    #num_people = $stdin.gets.to_i
 
    # num_people.times do
    #  Person.create(:first_name => Faker::Name.first_name,
    #                :last_name => Faker::Name.last_name)
    #end
    #print "#{num_people} created.\n"

    hsa = HsqlMasterAdmin.new
    #hsa.erase()
    #hsa.create()

    puts 'just finished the environement....'
    puts Time.now


    hsa.populate_job_description()
    
  end

end