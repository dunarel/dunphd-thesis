

namespace :db_srv  do
  
  desc "start server"
  task :server_start => :environment do

    #go to db_srv 
    Dir.chdir AppConfig.db_srv_dir
      
    sh %{sh server_start.sh}
      
  end

  desc "stop server"
  task :server_stop => :environment do

    #go to db_srv 
    Dir.chdir AppConfig.db_srv_dir
      
    sh %{sh server_stop.sh}
      
  end

  desc "drop devel database"
  task :devel_drop => :environment do

   
    #go to db_srv 
    Dir.chdir AppConfig.db_srv_files_dir
    
    puts "removing devel files..."  
    sh %{rm -fr devel.*}
     
    puts "removing server log..."
    Dir.chdir AppConfig.db_srv_dir
      
    sh %{rm -fr server.out}
    
  
  end

  desc "init devel database"
  task :devel_init => :environment do

    #go to db_srv 
    Dir.chdir AppConfig.db_srv_dir
      
    sh %{sh devel_init.sh}
      
  end

  desc "recreate devel database"
  task :devel_recreate => :environment do

  Rake::Task["db_srv:server_stop"].execute
  Rake::Task["db_srv:devel_drop"].execute
  Rake::Task["db_srv:server_start"].execute
  Rake::Task["db_srv:devel_init"].execute
  Rake::Task["db_srv:server_stop"].execute

      
  end

end



#return
#Dir.chdir Rails.root
#sh %{ls -ltr}
#sh 'ls', 'file with spaces'
