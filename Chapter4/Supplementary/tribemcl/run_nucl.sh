#activefile=pulA.fasta
activefile=$1


#sed -e 's/pid|//' -e 's/|.*//' ../proc/fasta/$activefile > ./$activefile
cp ../proc/gene_seqs_na/$activefile ./$activefile

#makeblastdb -in $activefile -dbtype prot -out my_prot_blast_db
#blastn -db my_prot_blast_db -query $activefile -outfmt 6 -out all-vs-all.out -num_threads 2 -use_sw_tback -evalue 1e-4




makeblastdb -in $activefile -dbtype nucl -out my_nucl_blast_db
blastn -db my_nucl_blast_db -query $activefile -outfmt 6 -out all-vs-all.out -num_threads 2 -evalue 1e-5


jruby tribe_parse.rb > all-vs-all.mclparsed
./tribe-matrix all-vs-all.mclparsed

#I= 1.4, 2, 4, 8
#mcl matrix.mci -I 1.4 -o all-vs-all.mclout -use-tab proteins.index





