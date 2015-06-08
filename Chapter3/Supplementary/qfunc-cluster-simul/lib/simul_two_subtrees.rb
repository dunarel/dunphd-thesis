#!/usr/bin/env jruby


 #parameters load
 machine_id = ARGV[0]
 test_suit = ARGV[1]
 
 puts machine_id
 puts test_suit

#global configuration
$project_folder = "/dev/shm/abdiallo/dunarel/#{machine_id}/simul_ruby"

require 'rubygems'
require 'simul_dna'

require 'simul_prot'





puts "RUBY_ENGINE.to: #{RUBY_ENGINE.to_s}"

#sleep 5
time_start = Time.now     # Current time


up = UqamDoc::Parsers.new;
#res = up.get_random_seq_aa(10);
#puts res

#up.parse_prot_matrix();

sa = UqamDoc::SimulDna.new
#sa = UqamDoc::SimulProt.new


 all_tests = {
  "f06_LSP" => [:test6],
  "f06_LSM" => [:test7],
  "f06_EPP" => [:test8],
  "f06_EPM" => [:test9],

  "f05_LSP" => [:test10],
  "f05_LSM" => [:test11],
  "f05_EPP" => [:test12],
  "f05_EPM" => [:test13],

  "f04_LSP" => [:test14],
  "f04_LSM" => [:test15],
  "f04_EPP" => [:test16],
  "f04_EPM" => [:test17],
  "test_debug" => [:test_debug]
 }

 
 sa.test_cases(test_suit, all_tests[test_suit])
 sa.export_simul_results(test_suit,machine_id)



time_end = Time.now

time_lapsed = time_end - time_start

puts "time_lapsed: #{time_lapsed}"









#test_array = [1, 1.3 , 1,1, 1.8, 2,2,2, 34, 31, 100]
#test_values = [0.0, 0.25, 0.5, 0.75, 1.0]


#test_values.each do |value|
#  puts value.to_s + ": " + UqamDoc::Calc::percentile(test_array, value).to_s
#end




#ud = UqamDoc::Parsers.new
#ud.fastafile_to_csvfile("/data/COURS/INF7565/projet_article/kmeans_rproj/lv3.fa", "/data/COURS/INF7565/projet_article/kmeans_rproj/lv3.csv")


#sa.test_random_seqs()
