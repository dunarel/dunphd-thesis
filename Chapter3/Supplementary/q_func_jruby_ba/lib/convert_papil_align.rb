require 'rubygems'
require 'bio'
require 'bio/io/flatfile'
require 'csv'


#read hash from yaml file
seqs = Hash.new
File.open( "../files/gene_align_seqs_E1_.yaml" ) { 
  |yf| seqs=YAML::load( yf )

}

#fill an alignment object
oa=Bio::Alignment::OriginalAlignment.new
seqs.each { |key,value|
  oa.add_seq(value,key)

}

#output the alignment to fasta
File.open("../files/gene_align_seqs_E1.tfa","w") {|f|
  f.puts  oa.output_fasta
}


