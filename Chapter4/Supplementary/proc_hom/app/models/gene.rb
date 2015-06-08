class Gene < ActiveRecord::Base
  has_many :gene_seqs
  has_many :gene_seq_clusters
  has_many :gene_ortho_runs
  has_many :hgt_par_fragms
  has_many :hgt_par_contins

end
