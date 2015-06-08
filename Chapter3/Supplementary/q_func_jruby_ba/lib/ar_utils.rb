class ArUtils

 #connexion 
  def connect(dolog)

    if dolog
     @logger = Logger.new $stderr
    else
      @logger = Logger.new nil
    end
    
    ActiveRecord::Base.logger = @logger
    ActiveRecord::Base.colorize_logging = false

    @config = YAML.load_file(File.join(File.dirname(__FILE__),'database.yml'))
    #ActiveRecord::Base.establish_connection(@config["development"])
    ActiveRecord::Base.establish_connection(@config["cruby"])

    ActiveRecord::Base.pluralize_table_names = false
    #ActiveRecord::Schema.verbose = false
    
    
  end

  def migrate(version)
   #version = nil
   #version = nil
   #ActiveRecord::Migration.verbose = false
   ActiveRecord::Migrator.migrate("migrate",version)
  end



end
