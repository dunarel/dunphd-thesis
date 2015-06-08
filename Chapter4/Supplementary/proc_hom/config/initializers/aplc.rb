 require 'ostruct'
 require 'yaml'
 require 'pathname'
  
    
  #puts "rails root: #{Rails.root}"


  # Load application configuration
   config = OpenStruct.new(YAML.load_file("#{Rails.root}/config/initializers/aplc.yml"))
   ::AppConfig = OpenStruct.new(config.send(Rails.env))


  AppConfig.lib_dir = "#{Rails.root}/lib"
  AppConfig.files = Pathname.new("/root/devel/files_srv/db_files/proc_hom")
 
  #AppConfig.db_srv_dir = "#{Rails.root}/db_srv"
  #AppConfig.db_srv_files_dir = "#{Rails.root}/db_srv/db_files"

  #AppConfig.files_dir = "#{Rails.root}/files/proc"
  #AppConfig.files_other_dir = "#{Rails.root}/files/other"
  
  #Alix genes file name <> seqs_orig_nb
  #AppConfig.all_genes_file = "#{Rails.root}/files/proc/statistique_fasta.txt"
 
  #Alix gene_seqs in fasta format
  AppConfig.all_gene_seqs_dir = AppConfig.files + "proc/fasta"

  #selected genes with :vers_access as keys in fasta format
  AppConfig.gene_seqs_aa_dir = "#{AppConfig.files}/proc/gene_seqs_aa"
  
  #converted to aa selected genes with :vers_access as keys in fasta format
  AppConfig.gene_seqs_na_dir = "#{AppConfig.files}proc/gene_seqs_na"

  #current run of orthology test(TribeMCL/)
  AppConfig.gene_ortho_runs_dir = "#{AppConfig.files}/proc/gene_ortho_runs"

  #tribemcl 
  AppConfig.tribemcl_dir = "#{AppConfig.files}tribemcl"
  #puts  AppConfig.perform_authentication

  #current run of multiple alignment (muscle/)
  AppConfig.gene_msa_runs_dir = "#{AppConfig.files}proc/gene_msa_runs"

  #current run of blocking (Gblocks/)
  AppConfig.gene_blo_runs_dir = "#{AppConfig.files}/proc/gene_blo_runs"

  #sequences ready for trex, indexed by gis
  AppConfig.gene_blo_seqs_dir = "#{AppConfig.files}proc/gene_blo_seqs"
  
  #current recombination RDP4/GENECONV
  AppConfig.gene_recomb_runs_dir = "#{AppConfig.files}/proc/gene_recomb_runs"

  #hgt_com dir 
  #former location
  #AppConfig.hgt_com_dir = "#{Rails.root}/files/proc/hgt-com"
  
  #new location
  AppConfig.hgt_com_dir = "#{AppConfig.files}/hgt-com-110"
 
  #hgt_par dir
  AppConfig.hgt_par_dir = "#{AppConfig.files}/hgt-par-110"

  #remote
  AppConfig.remote_root = "/home/badescud"
  AppConfig.remote_server =  "badescud@makarenk-mp2.rqchp.ca"
  AppConfig.remote_hgt_com_dir = "#{AppConfig.remote_root}/hgt-com-110"
  AppConfig.remote_hgt_par_dir = "#{AppConfig.remote_root}/hgt-par-110"
  
  #Java threaded scheduler
  AppConfig.proc_hom_ex = "#{Rails.root}/ex_projects/proc-hom-ex/dist"
  AppConfig.remote_proc_hom_ex = "#{AppConfig.remote_root}/local/bin/proc-hom-java"

  #db import dir
  AppConfig.db_imports_dir = "#{Rails.root}/db/imports"
  
  #db export dir
  AppConfig.db_exports_dir = "#{Rails.root}/db/exports"
 
  #graphics dir
  AppConfig.db_graphics_dir = "#{Rails.root}/db/graphics"

  #datasets for import export
  AppConfig.db_datasets = "#{Rails.root}/db/datasets"
  
