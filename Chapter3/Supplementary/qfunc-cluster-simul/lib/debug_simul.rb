

#global configuration
$project_folder = "/home/abdiallo/dunarel/simul_ruby"

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

test_suit = [:test6]

sa.test_cases("simple_func",test_suit)
sa.export_simul_results("simple_func")



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