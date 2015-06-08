
class ManageData

  def initialize()
    @conn = ActiveRecord::Base.connection
 
  end

  def reload_gene_group_cnts()
   
    @conn.execute \
      "delete from gene_group_cnts"
    puts "deleted gene_group_cnts..."
   
    @conn.execute \
      "insert into gene_group_cnts
       (gene_id,PROK_GROUP_ID,name,cnt)
      select gbs.GENE_ID,
             tg.PROK_GROUP_ID,
             pg.NAME,
             sum(tg.weight_pg) as CNT
      from GENE_BLO_SEQS gbs
       join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
       join TAXON_GROUPS tg on tg.TAXON_ID = ns.TAXON_ID
       join PROK_GROUPS pg on pg.ID = tg.PROK_GROUP_ID
      group by gbs.GENE_ID,
               tg.PROK_GROUP_ID,
               pg.NAME
      order by gbs.GENE_ID,
               tg.PROK_GROUP_ID"
    puts "reloaded gene_group_cnts"
   
   
  end
 
  
  def update_taxon_groups_weight_pg
   
    puts "update taxon_groups weight_pg"
   
    #select only usefull taxon_ids
    #those in gene_blo_seqs
   
    sql = "select distinct(ns.TAXON_ID)
          from GENE_BLO_SEQS gbs
           join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
           join TAXON_GROUPS tg on tg.TAXON_ID = ns.TAXON_ID
          order by taxon_id"
     
    #puts "sql: #{sql}"
    
      
    taxons = GeneBloSeq.find_by_sql(sql)
   
    taxons.each {|tx|
      #debugging
      #next if tx.taxon_id != 288681
      puts "taxon_id: #{tx.taxon_id}"
      
     
      #for each chiteria
      (0..1).each {|crit|
        sql = "select tg.ID,
                    tg.PROK_GROUP_ID,
                    pg.GROUP_CRITER_ID,
                    tg.TAXON_ID
             from TAXON_GROUPS tg 
              join PROK_GROUPS pg on pg.ID = tg.PROK_GROUP_ID
             where tg.TAXON_ID = #{tx.taxon_id} and
                   pg.GROUP_CRITER_ID = #{crit}"
        #puts "sql: \n #{sql}"
      
        tgrps = TaxonGroup.find_by_sql(sql)
        puts "taxon_groups count : #{tgrps.count}"
       
        tgrps.each { |tg|
          puts "id: #{tg.id}"
       
          #distribute evenly across taxon groups
          #update row
          upd = TaxonGroup.find(tg.id)
          upd.weight_pg = (1.0/tgrps.count).to_f
          #upd.weight_pg = 1.0
          upd.save
       
         
        }
       
       
       
      }
     
     
    }
   
   
   
   
  end

  def update_all_mrca_tables


    #update mrcas
    require "db/migrate/087_add_data_to_all_mrca_tables.rb"
    #class method with self.update_data()
    AddDataToAllMrcaTables::update_data()

  end

  def update_fen_stages_table
    require "db/migrate/102_add_data_to_fen_stages.rb"
    AddDataToFenStages::update_data()
  end
  
  def update_group_criters_table
    require "db/migrate/051_add_data_to_group_criters"
    AddDataToGroupCriters::update_data()
    
  end
 
end
