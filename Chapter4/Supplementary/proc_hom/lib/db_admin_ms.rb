
#require 'ruby_checks'
#require 'rubygems'
#require 'active_record'
require 'ostruct'
#require 'logger'
#require 'ar_models'

class HsqlMasterAdmin

  def initialize()
=begin
    #global configuration
    #
    #project is 4 levels up
    $project_folder = File.expand_path(File.dirname(__FILE__+"/../../../.."))

    $db_server_folder = "#{$project_folder}/db_srv"
    $db_server_exports = "#{$db_server_folder}/exports"
    
    $db_client_folder = "#{$project_folder}/simul_ruby_ms/db_client"

    puts "$db_server_folder: #{$db_server_folder}"
    puts "$db_client_folder: #{$db_client_folder}"



    $hsqldb_jar_file = "#{$db_client_folder}/hsqldb.jar"
    require "#{$hsqldb_jar_file}"

    ActiveRecord::Base.establish_connection(:adapter => 'jdbc',
      :driver => 'org.hsqldb.jdbcDriver',
   #   :host => 'localhost',
      :host => 'trex_cluster.labunix.uqam.ca',
  #    :url => 'jdbc:hsqldb:hsql://184.160.120.188/simuls',
      :url => 'jdbc:hsqldb:hsql://trex_cluster.labunix.uqam.ca:9001/simuls',
      :username => 'SA',
      :password => '');
    ActiveRecord::Base.logger = Logger.new(File.open("#{$db_client_folder}/simuls.log", 'w'))
    $connect_obj = ActiveRecord::Base.connection

    ActiveRecord::Base.pluralize_table_names = false
=end
  end

  def erase()
     ActiveRecord::Migrator.down("#{$db_client_folder}/migrate", 0)
  end


  def create()
     ActiveRecord::Migrator.up("#{$db_client_folder}/migrate", 0)

  end

  def recreate()

    erase()
    create()

   
    #puts "#{$sqlite_folder}/migrate"

   
  end

  def populate_job_description()

    #suite parameters
     nb_tests = 30
     dim_batch = 1
     test_suite_name = "suite_ari"

    #only one test suite
     SimulSuite.destroy_all :test_name => test_suite_name

     @simul_suite = SimulSuite.create(:test_name => test_suite_name,
                                       :nb_replic => nb_tests)

#     tests_to_go = ["f05_EPM","f05_LSM","f04_EPP","f06_LSP"]
      #tests_to_go = ["f04_EPP"]
      #tests_to_go = ["f04_EPP","f06_LSP"]
      tests_to_go = ["f04_EPM","f04_LSM","f04_EPP","f04_LSP",
                     "f05_EPM","f05_LSM","f05_EPP","f05_LSP",
                     "f06_EPM","f06_LSM","f06_EPP","f06_LSP"]

   
     nb_times = (nb_tests/dim_batch).to_i

     tests_to_go.each { |ttg|

      #create tests
      @simul_test = @simul_suite.simul_test.create(:test_ident => ttg)

      (1..nb_times).each { |slice|


        @job_description = @simul_test.job_description.create(:nb_replic => dim_batch)
      }


    }

      # @simul_results_hdl = File.open(@simul_results_csv,'a')
      # output_header()


  end


  #export as csv
  def calc_simul_results(test_name)

    
      suite = SimulSuite.find_by_test_name test_name
      SimulParamResult.delete_all

      if not suite.nil?

        suite.simul_test.each { |test|

          
          test.simul_param.each { |param|



        row = OpenStruct.new
        row.test_name = suite.test_name
        row.test_ident = test.test_ident
        row.nb_replic = suite.nb_replic
        row.nb_species = param.nb_species
        row.f_opt_max = param.f_opt_max
        row.scaling_factor0 = param.scaling_factor0
        row.scaling_factor1 = param.scaling_factor1
        row.scaling_factor2 = param.scaling_factor2


      #calculate 5 values percentiles
      perc_five_sup = param.perc_five_sup
      perc_five_inf = param.perc_five_inf
     
      #calculate positive_predictive_value
      pred_val = param.pred_val
  
      #save results
      #create independent
      @simul_param_result = SimulParamResult.new
      #link to master table
      @simul_param_result.simul_param =param
      
      @simul_param_result.pval_sup_q0 = perc_five_sup.q0
      @simul_param_result.pval_sup_q25 = perc_five_sup.q25
      @simul_param_result.pval_sup_q50 = perc_five_sup.q50
      @simul_param_result.pval_sup_q75 = perc_five_sup.q75
      @simul_param_result.pval_sup_q100 = perc_five_sup.q100
      #
      @simul_param_result.pval_inf_q0 = perc_five_inf.q0
      @simul_param_result.pval_inf_q25 = perc_five_inf.q25
      @simul_param_result.pval_inf_q50 = perc_five_inf.q50
      @simul_param_result.pval_inf_q75 = perc_five_inf.q75
      @simul_param_result.pval_inf_q100 = perc_five_inf.q100
      @simul_param_result.pred_val_ppv01 = pred_val.ppv01
      @simul_param_result.pred_val_ppv05 = pred_val.ppv05
      #
      @simul_param_result.save


        #one_simul_param_result = SimulParamResult.find
        #one_simul_param_result = param.simul_param_result
        row.pval_sup_q0 = param.simul_param_result.pval_sup_q0
        row.pval_sup_q25 = param.simul_param_result.pval_sup_q25
        row.pval_sup_q50 = param.simul_param_result.pval_sup_q50
        row.pval_sup_q75 = param.simul_param_result.pval_sup_q75
        row.pval_sup_q100 = param.simul_param_result.pval_sup_q100
        row.pval_inf_q0 = param.simul_param_result.pval_inf_q0
        row.pval_inf_q25 = param.simul_param_result.pval_inf_q25
        row.pval_inf_q50 = param.simul_param_result.pval_inf_q50
        row.pval_inf_q75 = param.simul_param_result.pval_inf_q75
        row.pval_inf_q100 = param.simul_param_result.pval_inf_q100
        row.pred_val_ppv01 = param.simul_param_result.pred_val_ppv01
        row.pred_val_ppv05 = param.simul_param_result.pred_val_ppv05

           puts "row: #{row.inspect}"
         

          } unless test.simul_param.nil?


      }  unless suite.simul_test.nil?


    end


  end #end proc

  #proxy to data aware classes
  def export_csv(test_name, filename)
     SimulSuite.export_csv(test_name, filename)
  end


end #end class
