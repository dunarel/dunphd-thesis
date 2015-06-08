require 'rubygems'
require 'yaml'
require 'bio'
require 'bio/io/flatfile'
require 'csv'

require '../../q_func_java_ba/dist/q_func_java_ba.jar'

require 'java'

import "q_func_java.HitFunctionQ"

hfq = HitFunctionQ.new();

puts "q_func_jruby_neisseria "

hfq.output_file = "../files/q_jruby_ba_neisseria.csv"

#ct = ['HPV-11', 'HPV-16', 'HPV-18', 'HPV-26', 'HPV-31', 'HPV-33', 'HPV-35', 'HPV-39', 'HPV-45', 'HPV-52', 'HPV-55', 'HPV-58', 'HPV-59', 'HPV-6', 'HPV-66', 'HPV-73', 'HPV-81', 'HPV-82', 'HPV-83']
ct = ["fetA-76", "fetA-13", "fetA-34", "fetA-55", "fetA-77", "fetA-56", "fetA-80", "fetA-15", "fetA-36", "fetA-57", "fetA-16", "fetA-37", "fetA-38", "fetA-59", "fetA-17", "fetA-40", "fetA-20", "fetA-18", "fetA-41", "fetA-39", "fetA-19", "fetA-01", "fetA-22", "fetA-43", "fetA-02", "fetA-44", "fetA-03", "fetA-24", "fetA-45", "fetA-67", "fetA-04", "fetA-46", "fetA-05", "fetA-26", "fetA-47", "fetA-27", "fetA-48", "fetA-06", "fetA-49", "fetA-07", "fetA-30", "fetA-08", "fetA-29", "fetA-52", "fetA-10", "fetA-09", "fetA-53", "fetA-11", "fetA-32", "fetA-33", "fetA-54"]
ct_al = java.util.ArrayList.new(ct)

hfq.cancero_types = ct_al

nct = ["fetA-14", "fetA-35", "fetA-78", "fetA-81", "fetA-79", "feta-69", "fetA-60", "fetA-58", "fetA-61", "fetA-62", "fetA-42", "fetA-63", "fetA-21", "fetA-64", "fetA-23", "fetA-65", "fetA-66", "fetA-25", "fetA-70", "fetA-68", "fetA-71", "fetA-50", "fetA-72", "fetA-28", "fetA-51", "fetA-73", "fetA-31", "fetA-74", "fetA-75", "fetA-12"]

hfq.non_cancero_types = nct.to_java(:string)

msa = {}
Bio::FlatFile.open(Bio::FastaFormat,
  '../files/fetA_alleles.tfa') { |ff|

  ff.each_entry {|x|
    msa.store(x.entry_id,x.seq)
  }
}



h = java.util.HashMap.new(msa)
hfq.align_mult_types = h


hfq.layout_seqs();

t=Time.now

hfq.calculate();

t0=Time.now-t
puts "temps calcul: #{t0}"
