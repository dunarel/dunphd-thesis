require 'ar_models'
require 'faster_csv'

module ArNeisseria

  class Initialize

    def init_msa_dna
      seq = <<END
GTACTGGATACCGTTACTGTAAAAGGCGACCGCCAAGGCAGCAAAATCCGTACCAACATCGTTACGCTGCAACAAAAA
GACGAAAGCACCGCAACCGATATGCGCGAACTCTTAAAAGAAGAGCCGTCCATCGATTTCGGCGGCGGCAACGGCACG
TCCCAATTCCTGACGCTGCGCGGCATGGGTCAGAACTCTGTCGACATCAAGGTGGACAACGCCTATTCCGACAGCCAA
ATCCTTTACCACCAAGGCAGATTTATTGTCGATCCCGCTTTGGTTAAAGTCGTTTCCGTACAAAAAGGCGCGGGTTCC
GCCTCTGCCGGTATCGGCGCGACCAACGGCGCGATCATCGCCAAAACCGTCGATGCCCAAGACCTGCTCAAAGGCTTG
GATAAAAACTGGGGCGTGCGCCTCAACAGCGGCTTTGCCAGCAACGAAGGCGTAAGCTACGGCGCAAGCGTATTCGGA
AAAGAGGGCAACTTCGACGGCTTGTTCTCTTACAACCGCAACGATGAAAAAGATTACGAAGCCGGCAAAGGTTTCCGC
AAT---GTCAACGGCGGCAAAACCGTACCGTACAGCGCGCTGGACAAACGCAGCTACCTCGCCAAAATCGGAACAACC
TTCGGCGACGACGACCACCGCATCGTGTTGAGCCACATGAAAGACCAACACCGGGGCATCCGCACTGTGCGTGAAGAA
TTTACCGTCGGCGACAAAAGTTCACGGATAAAT---ATTGACCGCCAAGCCCCTGCTTACCGCGAAACTACCCAATCC
AACACCAACTTGGCGTACACGGGTAAAAACCTGGGCTTTGTCGAAAAACTGGATGCCAACGCCTATGTGTTGGAAAAA
GAACGCTATTCCGCCGATGACAGCGGCACCGGCTACGCAGGCAATGTAAAAGGCCCCAACCATACCCGAATCACCACT
CGTGGTGCGAACTTCAACTTCGACAGCCGCCTTGCCGAACAAACCCTGTTGAAATACGGTATCAACTACCGCCATCAG
GAAATCAAACCGCAAGCATTTTTGAACTCGAAATTCTCCATCCCGACGACAGAAGAG------AAAAAC---GGTCAA
AAAGTCGATAAACCGATGGAACAACAAATGAAAGACCGTGCAGATGAAGACACTGTTCACGCCTACAAACTTTCCAAC
CCGACCAAAACCGATACCGGCGTATATGTTGAAGCCATTCACGACATCGGCGATTTCACGCTGACCGGCGGGCTGCGT
TACGACCGCTTCAAGGTGAAAACCCATGACGGCAAAACCGTTTCAAGCAGCAACCTTAACCCGAGTTTCGGTGTGATT
TGGCAGCCGCACGAACACTGGAGCTTCAGCGCGAGCCACAACTACGCCAGCCGCAGCCCGCGCCTGTATGACGCGCTG
CAAACCCACGGTAAACGCGGCATCATCTCGATTGCCGACGGCACAAAAGCCGAACGCGCGCGCAATACCGAAATCGGC
TTCAACTACAACGACGGCACGTTTGCCGCAAACGGCAGCTACTTCTGGCAGACCATCAAAGACGCGCTTGCCAATCCG
CAAAACCGCCACGACTCT---GTCGCCGTCCGTGAAGCCGTCAATGCCGGTTACATCAAAAACCACGGTTACGAATTG
GGCGCGTCCTACCGCACCGGCGGCCTGACTGCCAAAGTCGGCGTCAGCCACAGCAAACCGCGCTTTTAC------GAT
ACGCACAAAGACAAGCTGTTGAGCGCGAATCCTGAATTTGGCGCACAAGTCGGCCGCACTTGGACGGCCTCCCTTGCC
TACCGCTTCCAAAATCCGAATCTGGAAATCGGCTGGCGCGGCCGTTATGTTCAAAAAGCTACGGGTTCGATATTGGCG
GCAGGTCAAAAAGAC---CGCAAAGGCAACTTGGAAAACGTTGTACGCAAAGGTTTCGGTGTGAACGATGTCTTCGCC
AACTGGAAACCGCTGGGCAAAGACACGCTCAATGTCAATCTTTCGGTTAACAACGTGTTCAACAAGTTCTACTATCCGCACAGC
END
      seq.gsub! "\n",""
      puts seq.length
      
      #test same length as seq_dna
      y = seq.gsub("-","")
      puts "_stripped: #{y.length}"
      sleep 20

      #erase msa_dna
      del_msa_dna = MsaDna.find :all
      del_msa_dna.each { |x| x.destroy }



      #insert msa_dna
      my_msa_dna = MsaDna.new
      my_msa_dna.seq = seq
      my_msa_dna.length = seq.length

      #details of msa_dna
      for idx in 0..my_msa_dna.seq.length-1
        my_msa_dna_pos = MsaDnaPos.new
        my_msa_dna_pos.idx = idx
        my_msa_dna_pos.symbol = my_msa_dna.seq[idx..idx]

        my_msa_dna.msa_dna_pos << my_msa_dna_pos
      end


      #save master with detail
      my_msa_dna.save
      puts "inserted #{my_msa_dna.id}"





    end

    def init_seq_dna
      
      seq = <<END
GTACTGGATACCGTTACTgtaaaaggcgaccgccaaggcagcaaaatccgtacc
aacatcgttacgctgcaacaaaaagacgaaagcaccgcaaccgatatgcgcgaactctta
aaagaagagccgtccatcgatttcggcggcggcaacggcacgtcccaattcctgacgctg
cgcggcatgggtcagaactctgtcgacatcaaggtggacaacgcctattccgacagccaa
atcctttaccaccaaggcagatttattgtcgatcccgctttggttaaagtcgtttccgtacaa
aaaggcgcgggttccgcctctgccggtatcggcgcgaccaacggcgcgatcatcgcc
aaaaccgtcgatgcccaagacctgctcaaaggc
TTGGATAAAAACTGGGGCGTGCGCCTCA
ACAGCGGCTTTGCCAGCAACGAAGGCGTAA GCTACGGCGC AAGCGTATTC GGAAAAGAGG
GCAACTTCGACGGCTTGTTCTCTTACAACC GCAACGATGA AAAAGATTAC GAAGCCGGCA
AAGGTTTCCGCAATGTCAACGGCGGCAAAA CCGTACCGTA CAGCGCGCTG GACAAACGCA
GCTACCTCGCCAAAATCGGAACAACCTTCG GCGACGACGA CCACCGCATC GTGTTGAGCC
ACATGAAAGACCAACACCGGGGCATCCGCA CTGTGCGTGA AGAATTTACC GTCGGCGACA
AAAGTTCACGGATAAATATTGACCGCCAAG CCCCTGCTTA CCGCGAAACT ACCCAATCCA
ACACCAACTTGGCGTACACGGGTAAAAACC TGGGCTTTGT CGAAAAACTG GATGCCAACG
CCTATGTGTTGGAAAAAGAACGCTATTCCG CCGATGACAG CGGCACCGGC TACGCAGGCA
ATGTAAAAGGCCCCAACCATACCCGAATCA CCACTCGTGG TGCGAACTTC AACTTCGACA
GCCGCCTTGCCGAACAAACCCTGTTGAAAT ACGGTATCAA CTACCGCCAT CAGGAAATCA
AACCGCAAGCATTTTTGAACTCGAAATTCT CCATCCCGAC GACAGAAGAG AAAAACGGTC
AAAAAGTCGATAAACCGATGGAACAACAAA TGAAAGACCG TGCAGATGAA GACACTGTTC
ACGCCTACAAACTTTCCAACCCGACCAAAA CCGATACCGG CGTATATGTT GAAGCCATTC
ACGACATCGGCGATTTCACGCTGACCGGCG GGCTGCGTTA CGACCGCTTC AAGGTGAAAA
CCCATGACGGCAAAACCGTTTCAAGCAGCA ACCTTAACCC GAGTTTCGGT GTGATTTGGC
AGCCGCACGAACACTGGAGCTTCAGCGCGA GCCACAACTA CGCCAGCCGC AGCCCGCGCC
TGTATGACGCGCTGCAAACCCACGGTAAAC GCGGCATCAT CTCGATTGCC GACGGCACAA
AAGCCGAACGCGCGCGCAATACCGAAATCG GCTTCAACTA CAACGACGGC ACGTTTGCCG
CAAACGGCAGCTACTTCTGGCAGACCATCA AAGACGCGCT TGCCAATCCG CAAAACCGCC
ACGACTCTGTCGCCGTCCGTGAAGCCGTCA ATGCCGGTTA CATCAAAAAC CACGGTTACG
AATTGGGCGCGTCCTACCGCACCGGCGGCC TGACTGCCAA AGTCGGCGTC AGCCACAGCA
AACCGCGCTTTTACGATACGCACAAAGACA AGCTGTTGAG CGCGAATCCT GAATTTGGCG
CACAAGTCGGCCGCACTTGGACGGCCTCCC TTGCCTACCG CTTCCAAAAT CCGAATCTGG
AAATCGGCTGGCGCGGCCGTTATGTTCAAA AAGCTACGGG TTCGATATTG GCGGCAGGTC
AAAAAGACCGCAAAGGCAACTTGGAAAACG TTGTACGCAA AGGTTTCGGT GTGAACGATG
TCTTCGCCAACTGGAAACCGCTGGGCAAAG ACACGCTCAA TGTCAATCTT TCGGTTAACA
ACGTGTTCAACAAGTTCTACTATCCGCACAGC
END
      seq.gsub! "\n",""
      puts seq.length
      seq.gsub! " ",""
      puts seq.length
      seq.upcase!
      puts seq

      #erase seq_dna
      del_seq_dna = SeqDna.find :all
      del_seq_dna.each { |x| x.destroy }

      #insert seq_dna
      my_seq_dna = SeqDna.new
      my_seq_dna.seq = seq
      my_seq_dna.length = seq.length

      #details of seq_dna
      for idx in 0..my_seq_dna.seq.length-1
        my_seq_dna_pos = SeqDnaPos.new
        my_seq_dna_pos.idx = idx
        my_seq_dna_pos.symbol = my_seq_dna.seq[idx..idx]

        my_seq_dna.seq_dna_pos << my_seq_dna_pos
      end


      #save master with detail
      my_seq_dna.save
      puts "inserted #{my_seq_dna.id}"




    end

    def init_seq_aa
      seq = <<END
vldtvtvkgdrqgskirtnivtlqqkdestatdmrell
keepsidfgggngtsqfltlrgmgqnsvdikvdnaysdsq
ilyhqgrfivdpalvkvvsvqkgagsasagigatngaiia
ktvdaqdllkg
LDKNWGVRLNSGFASNEGVSYGASVFGKEGNFDGLFSYNRNDEKDYEAGKGFRNVNGGKT
VPYSALDKRSYLAKIGTTFGDDDHRIVLSHMKDQHRGIRTVREEFTVGDKSSRINIDR
QAPAYRETTQSNTNLAYTGKNLGFVEKLDANAYVLEKERYSADDSGTGYAGNVKGPNH
TRITTRGANFNFDSRLAEQTLLKYGINYRHQEIKPQAFLNSKFSIPTTEEKNGQKVDK
PMEQQMKDRADEDTVHAYKLSNPTKTDTGVYVEAIHDIGDFTLTGGLRYDRFKVKTHD
GKTVSSSNLNPSFGVIWQPHEHWSFSASHNYASRSPRLYDALQTHGKRGIISIADGTK
AERARNTEIGFNYNDGTFAANGSYFWQTIKDALANPQNRHDSVAVREAVNAGYIKNHG
YELGASYRTGGLTAKVGVSHSKPRFYDTHKDKLLSANPEFGAQVGRTWTASLAYRFQN
PNLEIGWRGRYVQKATGSILAAGQKDRKGNLENVVRKGFGVNDVFANWKPLGKDTLNV
NLSVNNVFNKFYYPHS
END

      seq.gsub! "\n",""
      puts seq.length
      seq.gsub! " ",""
      puts seq.length
      seq.upcase!
      puts seq

      #erase seq_aa
      del_seq_aa = SeqAa.find :all
      del_seq_aa.each { |x| x.destroy }

      #insert seq_dna
      my_seq_aa = SeqAa.new
      my_seq_aa.seq = seq
      my_seq_aa.length = seq.length

      #details of seq_dna
      for idx in 0..my_seq_aa.seq.length-1
        my_seq_aa_pos = SeqAaPos.new
        my_seq_aa_pos.idx = idx
        my_seq_aa_pos.symbol = my_seq_aa.seq[idx..idx]

        my_seq_aa.seq_aa_pos << my_seq_aa_pos

        #update corresponding seq_dna_pos
        (0..2).each { |i|
          idx_dna = my_seq_aa_pos.idx * 3 + i
          my_seq_dna_pos = SeqDnaPos.find_by_idx idx_dna
          #update the link (fk)
          my_seq_dna_pos.seq_aa_pos = my_seq_aa_pos
          my_seq_dna_pos.save
           
        }




      end


      #save master with detail
      my_seq_aa.save
      puts "inserted #{my_seq_aa.id}"





    end

    def init_surface_loops_exposed


      #erase surface_loops_exposed
      del = SurfaceLoopsExposed.find :all
      del.each { |x| x.destroy }
      #
      puts `pwd`

      i=0
     FasterCSV.foreach("migrate/surface_loops_exposed.csv") do |row|
       i+=1
        next if i==1;
       
       # all indexes are one based
        SurfaceLoopsExposed.create(
        :position => row[0],
        :idx_graph_aa_begin => row[1],
        :idx_graph_aa_end => row[2],
        #aa indexes are 0 based
        :idx_seq_aa_begin => row[1].to_i + 129 -1,
        :idx_seq_aa_end => row[2].to_i + 129 -1
        )

        #aa indexes are 0 based
        tab = SeqAaPos.find_by_idx(row[1].to_i + 129 -1)
        puts "pos: #{row[1]}, symbol: #{tab.symbol}"
    
     end

    end

    def init_periplasmic_loops_exposed


      #erase surface_loops_exposed
      del = PeriplasmicLoopsExposed.find :all
      del.each { |x| x.destroy }
      #
      puts `pwd`

      i=0
     FasterCSV.foreach("migrate/periplasmic_loops_exposed.csv") do |row|
       i+=1
        next if i==1;

       # all indexes are one based
        PeriplasmicLoopsExposed.create(
        :position => row[0],
        :idx_graph_aa_begin => row[1],
        :idx_graph_aa_end => row[2],
        #aa indexes are 0 based
        :idx_seq_aa_begin => row[1].to_i + 129 -1,
        :idx_seq_aa_end => row[2].to_i + 129 -1
        )

        #aa indexes are 0 based
        tab = SeqAaPos.find_by_idx(row[1].to_i + 129 -1)
        puts "pos: #{row[1]}, symbol: #{tab.symbol}"

     end




    end

  end

  class Calculate

    def assign_msa_to_dna
      #@testassoc2 = MsaDna.new
      #puts @testassoc2.msa_dna_pos.inspect
      
      #@testassoc1 = MsaDnaPos.new

      #puts MsaDnaPos.msa_dna.inspect

      #erase msa_dna_associations

      del_asoc = MsaDnaPosSeqDnaPos.find :all
      del_asoc.each { |x| x.delete }

      #m0 = MsaDna.new
      #m0.seq = "YYY"
      #m0.save
      
      #m1 = MsaDna.find(:first)
      
      #asoc = MsaDnaPosSeqDnaPos.new
      #asoc.



      md = MsaDna.find(:first)
      #puts md.seq
      #puts md.length
      j=0
      seq = md.seq
      for i in 0..seq.length-1
        puts "i: #{i}, j: #{j}"
        mdp = MsaDnaPos.find_by_idx(i)
        sdp = SeqDnaPos.find_by_idx(j)

        # m_zero = MsaDnaPosSeqDnaPos.new
        # m_zero.msa_dna_pos = mdp
        # m_zero.save


        MsaDnaPosSeqDnaPos.create(:msa_dna_pos => mdp,
          :seq_dna_pos => sdp,
          :align => 'R')

        #puts "msa_dna_pos: #{msa_dna_pos.inspect}, msa_dna_pos_id: #{msa_dna_pos.id}"
        #zid = msa_dna_pos.id
        
        #asoc.msa_dna_pos = msa_dna_pos
        #asoc.seq_dna_pos << seq_dna_pos
        #asoc.save
        
        j = seq[i..i] != '-'? (j+1) : j
        


      end




    end


    def min_max_msa_from_aa(idx)

      #Infinity = 1.0/0
      all_indexes = []

      aa_zero = SeqAaPos.find_by_idx idx
      #puts aa_zero.seq_aa.inspect
      
      aa_zero.seq_dna_pos.each { |my_seq_dna_pos|

        my_seq_dna_pos.msa_dna_pos.each { |my_msa_dna_pos|
          puts my_msa_dna_pos.inspect
          all_indexes << my_msa_dna_pos.idx
        }

        
      }
      #puts "min: #{all_indexes.min}, max: #{all_indexes.max}"

      return {:min => all_indexes.min,
        :max => all_indexes.max
      }

    end

    def assign_surface_loops_exposed_limits

      table = SurfaceLoopsExposed.find(:all)
      table.each { |row|
        min_min = min_max_msa_from_aa(row.idx_seq_aa_begin)[:min]
        row.idx_msa_dna_begin = min_min
        max_max = min_max_msa_from_aa(row.idx_seq_aa_end)[:max]
        row.idx_msa_dna_end = max_max
        row.save
      }

      #tab = SeqAaPos.find_by_idx(row[1].to_i + 129 -1)
      #  puts "pos: #{row[1]}, symbol: #{tab.symbol}"




    end

    def assign_periplasmic_loops_exposed_limits

      table = PeriplasmicLoopsExposed.find(:all)
      table.each { |row|
        min_min = min_max_msa_from_aa(row.idx_seq_aa_begin)[:min]
        row.idx_msa_dna_begin = min_min
        max_max = min_max_msa_from_aa(row.idx_seq_aa_end)[:max]
        row.idx_msa_dna_end = max_max
        row.save
      }

      #tab = SeqAaPos.find_by_idx(row[1].to_i + 129 -1)
      #  puts "pos: #{row[1]}, symbol: #{tab.symbol}"




    end



  end

  end


