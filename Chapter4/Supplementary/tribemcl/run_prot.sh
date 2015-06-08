#activefile=pulA.fasta
activefile=$1


#sed -e 's/pid|//' -e 's/|.*//' ../proc/fasta/$activefile > ./$activefile
cp ../proc/gene_seqs_aa/$activefile ./$activefile

makeblastdb -in $activefile -dbtype prot -out my_prot_blast_db
blastp -db my_prot_blast_db -query $activefile -outfmt 6 -out all-vs-all.out -num_threads 2 -use_sw_tback -evalue 1e-4




#makeblastdb -in $activefile -dbtype nucl -out my_nucl_blast_db
#blastn -db my_nucl_blast_db -query $activefile -outfmt 6 -out all-vs-all.out -num_threads 2 -evalue 1e-6


jruby tribe_parse.rb > all-vs-all.mclparsed
./tribe-matrix all-vs-all.mclparsed

#I= 1.4, 2, 4, 8
#mcl matrix.mci -I 1.4 -o all-vs-all.mclout -use-tab proteins.index

#{240,163,255},
#{0,117,220},
#{153,63,0},
#{76,0,92},
#{25,25,25}
#{0,92,49}
#{43,206,72}
#{255,204,153}
#{128,128,128}
#{148,255,181}
#{143,124,0}
#{157,204,0}
#{194,0,136}
#{0,51,128}
#{255,164,5}
#{255,168,187}
#{66,102,0}
#{255,0,16}
#{94,241,242}
#{0,153,143}
#{224,255,102}
#{116,10,255}
#{153,0,0}
#{255,255,128}
#{255,255,0}
#{255,80,5}