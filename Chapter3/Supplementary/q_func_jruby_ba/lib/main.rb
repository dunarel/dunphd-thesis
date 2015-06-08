require 'rubygems'
require 'yaml'
require 'bio'
require 'bio/io/flatfile'
require 'csv'


require '../../q_func_java_ba/dist/q_func_java_ba.jar'

require 'java'

import "q_func_java.HitFunctionQ"


hfq = HitFunctionQ.new();

puts "q_func_jruby_orig "
#hfq.input_file = "../files/gene_align_seqs_E1_.yaml"
hfq.output_file = "../files/q_e1_jruby_ba_directe.txt"

ct = ['HPV-11', 'HPV-16', 'HPV-18', 'HPV-26', 'HPV-31', 'HPV-33', 'HPV-35', 'HPV-39', 'HPV-45', 'HPV-52', 'HPV-55', 'HPV-58', 'HPV-59', 'HPV-6', 'HPV-66', 'HPV-73', 'HPV-81', 'HPV-82', 'HPV-83']
ct_al = java.util.ArrayList.new(ct)

hfq.cancero_types = ct_al
#puts ct_al.inspect

nct = ['HPV-54', 'HPV-75', 'HPV-76', 'HPV-12', 'HPV-77', 'HPV-13', 'HPV-34', 'HPV-14D', 'HPV-57', 'HPV-15', 'HPV-36', 'HPV-80', 'HPV-37', 'HPV-60', 'HPV-61', 'HPV-17', 'HPV-40', 'HPV-38', 'HPV-1', 'HPV-41', 'HPV-2', 'HPV-20', 'HPV-84', 'HPV-cand85', 'HPV-21', 'HPV-19', 'HPV-42', 'HPV-63', 'HPV-3', 'HPV-cand86', 'HPV-22', 'HPV-43', 'HPV-4', 'HPV-cand87', 'HPV-44', 'HPV-65', 'HPV-5', 'HPV-23', 'HPV-cand89', 'HPV-cand90', 'HPV-7', 'HPV-cand91', 'HPV-25', 'HPV-67', 'HPV-9', 'HPV-47', 'HPV-70', 'HPV-71', 'HPV-27', 'HPV-50', 'HPV-48', 'HPV-69', 'HPV-30', 'HPV-28', 'HPV-49', 'HPV-10', 'HPV-29', 'HPV-94', 'HPV-cand96', 'HPV-32']
hfq.non_cancero_types = nct.to_java(:string)
#puts nct.inspect

msa = {}
Bio::FlatFile.open(Bio::FastaFormat,
  '../files/gene_align_seqs_E1.tfa') { |ff|

  ff.each_entry {|x|
    msa.store(x.entry_id,x.seq)
  }
}


h = java.util.HashMap.new(msa)
hfq.align_mult_types = h

hfq.layout_seqs();

hfq.show_align_mult_types();

t=Time.now

hfq.calculate();

t0=Time.now-t
puts "temps calcul: #{t0}"
