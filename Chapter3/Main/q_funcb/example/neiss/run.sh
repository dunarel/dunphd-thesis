#!/bin/sh

../../q_funcp --msa_fasta feta_alleles.fa --x_ident_csv x_ident_feta.csv --q_func_csv q_func_feta.csv --calc_type auto  --f_opt_max 4 --align_type dna --dist ham --winl 9 --win_step 9 --optim km
