
require 'rubygems'
require 'bio' 
require 'msa_tools'
require 'faster_csv'

class WorkExport
  
 def initialize()
  @ud = UqamDoc::Parsers.new
 end
 
 
  
  def taxon_ids
     
    #
    taxids = NcbiSeq.select("distinct taxon_id as taxid").order("taxon_id")
    
    FasterCSV.open("#{AppConfig.db_exports_dir}/recomb_transfer_groups_matrix_certif.csv", "w") { |csv|
     csv << ['taxid']
      taxids.each { |t|
        csv << [t.taxid]
      }
    }

    
    #taxids.each { |tid| puts "taxid: #{tid.taxid}" }
       

  end 

 
  def taxids_gis

   #"select ns.taxon_id,
   #       ns.id,
   #    t.sci_name,
   #    ns.vers_access
   # from ncbi_seqs ns 
   # join taxons t on t.ID = ns.TAXON_ID
   #order by ns.taxon_id,
    #      ns.id"


    #taxids_gis = NcbiSeq.includes(:taxon).order("taxon_id,id").limit(10)
    taxids_gis = NcbiSeq.includes(:taxon).order("taxon_id,id")
 
    taxids_gis.each { |tg|
      puts "#{tg.taxon_id},#{tg.id},#{tg.taxon.sci_name},#{tg.vers_access}"
    }

    FasterCSV.open("#{AppConfig.db_exports_dir}/taxids_gis.csv", "w", {:col_sep => "|"}) { |csv|
     csv << ['TAXID','GI','SCI_NAME','VERS_ACCESS']
      taxids_gis.each { |tg|
        csv << [tg.taxon_id,tg.id,tg.taxon.sci_name,tg.vers_access]
      }
    }


  end


  def recomb_transfer_groups_matrix

    FasterCSV.open("#{AppConfig.db_exports_dir}/prok_groups_matrix_certif.csv", "w", {:col_sep => "|"}) { |csv|
     row = []
      row << 'NAME'
      row << 'SRC_ID \ DEST_ID'
      (0..22).each { |x|
        row << x.to_s
      }
      csv << row

      #for each row    
      (0..22).each { |y|
        row = []
        #name of the group
        pg = ProkGroup.find(y)
        #find nb of species in group
        #pgn = Taxon.joins(:taxon_group).group("prok_group_id").where("prok_group_id=?",y).select("prok_group_id,count(*) as cnt")[0]
        #prok group taxon number
        #select count(distinct TAXON_ID),
       #PROK_GROUP_ID
       #from taxon_groups tg
        #join ncbi_seqs ns on ns.TAXON_ID = tg.ID
         #join GENE_BLO_SEQS gbs on gbs.NCBI_SEQ_ID = ns.ID
         #where tg.PROK_GROUP_ID=16
          #group by tg.PROK_GROUP_ID

        pgtn = TaxonGroup.joins(:ncbi_seqs => :gene_blo_seq).where("prok_group_id=?",y).group("prok_group_id").select("count(distinct TAXON_ID) as cnt")[0]

        #select count(*)
        #from taxon_groups tg
        #join ncbi_seqs ns on ns.TAXON_ID = tg.ID
        #join GENE_BLO_SEQS gbs on gbs.NCBI_SEQ_ID = ns.ID
        #where tg.PROK_GROUP_ID=8
        
        #find nb of sequences in group
        pgsn = TaxonGroup.joins(:ncbi_seqs => :gene_blo_seq).where("prok_group_id=?",y).select("count(*) as cnt")[0]

        row << "#{pg.name}(#{pgtn.cnt}),[#{pgsn.cnt}]"

        row << y

        (0..22).each { |x|
          #recomb_transfer_groups
          rtg = RecombTransferGroup.find_by_source_id_and_dest_id(y,x)
          row << [rtg.certif_cnt== 0  ? nil : rtg.certif_cnt ]
        }
        csv << row

      }


    } #end csv

    #all

    FasterCSV.open("#{AppConfig.db_exports_dir}/prok_groups_matrix_all.csv", "w", {:col_sep => "|"}) { |csv|
     row = []
      row << 'NAME'
      row << 'SRC_ID \ DEST_ID'
      (0..22).each { |x|
        row << x.to_s
      }
      csv << row

      #for each row    
      (0..22).each { |y|
        row = []
        #name of the group
        pg = ProkGroup.find(y)
        
        pgtn = TaxonGroup.joins(:ncbi_seqs => :gene_blo_seq).where("prok_group_id=?",y).group("prok_group_id").select("count(distinct TAXON_ID) as cnt")[0]

        #find nb of sequences in group
        pgsn = TaxonGroup.joins(:ncbi_seqs => :gene_blo_seq).where("prok_group_id=?",y).select("count(*) as cnt")[0]

        row << "#{pg.name}(#{pgtn.cnt}),[#{pgsn.cnt}]"

        row << y

        (0..22).each { |x|
          #recomb_transfer_groups
          rtg = RecombTransferGroup.find_by_source_id_and_dest_id(y,x)
          row << [rtg.all_cnt== 0  ? nil : rtg.all_cnt ]
        }
        csv << row

      }


    } #end csv
      #.select("prok_group_id as id, count(*) as cnt")
    
  end

end
