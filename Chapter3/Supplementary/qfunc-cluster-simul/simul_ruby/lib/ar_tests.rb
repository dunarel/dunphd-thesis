
require 'ruby_checks'
require 'rubygems'
require 'active_record'
require 'ostruct'
require 'logger'


puts `pwd`
puts $project_folder


$db_folder = "#{$project_folder}/db"

#dbconf = YAML::load(File.open("#{$sqlite_folder}/config/database.yml"))

#ActiveRecord::Base.establish_connection(dbconf)
#ActiveRecord::Base.establish_connection(:adapter => "sqlite3",
#  :database  => "#{$sqlite_folder}/db/abd_tests.sqlite",
#  :wait_timeout => 0.25,
#  :timeout => 250
#)

#ActiveRecord::Base.establish_connection(:adapter => "mysql",
#  :encoding => "utf8",
#  :database => "simul_ruby_abd",
#  :username => "root",
#  :password => "mysql1234"
#)

=begin
puts "RUBY_ENGINE.to: #{RUBY_ENGINE.to_s}"

case RUBY_ENGINE.to_s
  when 'ruby'
ActiveRecord::Base.establish_connection(:adapter => 'postgresql',
                                        :host => 'localhost',
                                        :username => 'postgres',
                                        :database => 'simul_ruby_abd');
 when 'jruby'
   ActiveRecord::Base.establish_connection(:adapter => 'jdbcpostgresql',
                                           :host => 'localhost',
                                        :username => 'postgres',
                                        :database => 'simul_ruby_abd');
end

=end

$derbyclient_jar_file = "#{$db_folder}/derby/lib/derbyclient.jar"
require "#{$derbyclient_jar_file}"

ActiveRecord::Base.establish_connection(:adapter => 'jdbc',
                                            :driver => 'org.apache.derby.jdbc.ClientDriver',
                                           :host => 'localhost',
                                           :url => 'jdbc:derby://localhost:1527/simul_ruby_db',
                                        :username => 'app',
                                        :password => 'app');

=begin
  ActiveRecord::Base.establish_connection(:adapter => 'jdbcderby',
                                           :url => 'jdbc:derby://localhost:1527/simul_ruby_db');
=end

ActiveRecord::Base.logger = Logger.new(File.open("#{$db_folder}/database.log", 'w'))

ActiveRecord::Migrator.down("#{$db_folder}/migrate", 0)
#puts "#{$sqlite_folder}/migrate"

ActiveRecord::Migrator.up("#{$db_folder}/migrate", 0)

$connect_obj = ActiveRecord::Base.connection

ActiveRecord::Base.pluralize_table_names = false

#models

class SimulSuite < ActiveRecord::Base
  has_many :simul_test, :dependent => :destroy

  #export as csv
  def self.export_csv(test_name, filename)
   puts "export_csv, test_name: #{test_name}, filename: #{filename}"
     
    FasterCSV.open(filename, "w") do |csv|
      #header
      csv << ["test_name",
               "test_ident",
                "nb_replic",
                "nb_species",
                "f_opt_max",
                "scaling_factor0",
                "scaling_factor1",
                "scaling_factor2",
                "pval_sup_q0",
                "pval_sup_q25",
                "pval_sup_q50",
                "pval_sup_q75",
                "pval_sup_q100",
                "pval_inf_q0",
                "pval_inf_q25",
                "pval_inf_q50",
                "pval_inf_q75",
                "pval_inf_q100",
                "pred_val_ppv01",
                "pred_val_ppv05"]

      suite = self.find_by_test_name test_name

      if not suite.nil?

        suite.simul_test.each { |test|

          
          test.simul_param.each { |param|



        row = OpenStruct.new
        row.test_name = test_name
        row.test_ident = test.test_ident
        row.nb_replic = param.nb_replic
        row.nb_species = param.nb_species
        row.f_opt_max = param.f_opt_max
        row.scaling_factor0 = param.scaling_factor0
        row.scaling_factor1 = param.scaling_factor1
        row.scaling_factor2 = param.scaling_factor2

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

        csv <<

              [row.test_name,
                row.test_ident,
                row.nb_replic,
                row.nb_species,
                row.f_opt_max,
                row.scaling_factor0,
                row.scaling_factor1,
                row.scaling_factor2,
                row.pval_sup_q0,
                row.pval_sup_q25,
                row.pval_sup_q50,
                row.pval_sup_q75,
                row.pval_sup_q100,
                row.pval_inf_q0,
                row.pval_inf_q25,
                row.pval_inf_q50,
                row.pval_inf_q75,
                row.pval_inf_q100,
                row.pred_val_ppv01,
                row.pred_val_ppv05
                ]


          } unless test.simul_param.nil?


      }  unless suite.simul_test.nil?



      end
      
      

      #res = SimulTestElem.avg_pvals
      #res.each { |row|
      #  puts "row: #{row.inspect}"
      #  csv << [row.test_name,row.test_ident,row.nb_replic,row.nb_species,row.f_opt_max,
      #    row.scaling_factor0,row.scaling_factor1,row.scaling_factor2,
      #    row.avg_pval_sup,row.avg_pval_inf]
      #}
    end

  end

end

class SimulTest < ActiveRecord::Base
  belongs_to :simul_suite
  has_many :simul_param, :dependent => :destroy
end

class SimulParam < ActiveRecord::Base
  belongs_to :simul_test
  has_many :simul_test_elem, :dependent => :destroy
  has_one :simul_param_result, :dependent => :destroy #, :class_name => "SimulParamResult"

  def perc_five_sup

    pval_sup_arr = self.simul_test_elem.collect {|x| x.pval_sup }
   
    res = OpenStruct.new
    res.q0 =UqamDoc::Calc::percentile(pval_sup_arr, 0.0).to_s 
    res.q25 = UqamDoc::Calc::percentile(pval_sup_arr, 0.25).to_s 
    res.q50 = UqamDoc::Calc::percentile(pval_sup_arr, 0.5).to_s 
    res.q75 = UqamDoc::Calc::percentile(pval_sup_arr, 0.75).to_s 
    res.q100 = UqamDoc::Calc::percentile(pval_sup_arr, 1.0).to_s

    return res
  end

  def perc_five_inf

    pval_inf_arr = self.simul_test_elem.collect {|x| x.pval_inf }

    res = OpenStruct.new
    res.q0 =UqamDoc::Calc::percentile(pval_inf_arr, 0.0).to_s
    res.q25 = UqamDoc::Calc::percentile(pval_inf_arr, 0.25).to_s
    res.q50 = UqamDoc::Calc::percentile(pval_inf_arr, 0.5).to_s
    res.q75 = UqamDoc::Calc::percentile(pval_inf_arr, 0.75).to_s
    res.q100 = UqamDoc::Calc::percentile(pval_inf_arr, 1.0).to_s

    return res
  end

 def pred_val
  
   arr = self.simul_test_elem.collect {|x| x.pval_sup }
   puts "arr: #{arr}"
   
   res = OpenStruct.new
   res.ppv01 = ((arr.count{|x| x <= 0.01}).to_f / arr.length.to_f).to_s
   res.ppv05 = ((arr.count{|x| x <= 0.05}).to_f / arr.length.to_f).to_s
   
   puts "res.ppv01: #{res.ppv01}, res.ppv05: #{res.ppv05}"
   return res

 end

end

class SimulParamResult < ActiveRecord::Base
  belongs_to :simul_param #, :class_name => "SimulParam", :foreign_key => "simul_param_id"
end


class SimulTestElem < ActiveRecord::Base
  belongs_to :simul_param
  #averages pvalues
  def self.avg_pvals

=begin
    sql= "select test_name,
                  test_ident,
                  nb_replic,
                  nb_species,
                  f_opt_max,
                  scaling_factor0,
                  scaling_factor1,
                  scaling_factor2,
                  avg(pval_sup) as avg_pval_sup,
                  avg(pval_inf) as avg_pval_inf
           from simul_test_elem
           group by test_name,
                  test_ident,
                  nb_replic,
                  nb_species,
                  f_opt_max,
                  scaling_factor0,
                  scaling_factor1,
                  scaling_factor2"
=end
    sql="select * from simul_test_elem_avg_v"
    SimulTestElem.find_by_sql(sql)
  end


end


class QFuncCsv < ActiveRecord::Base

end



 
