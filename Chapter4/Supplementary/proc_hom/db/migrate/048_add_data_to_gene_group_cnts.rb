class AddDataToGeneGroupCnts < ActiveRecord::Migration

  def up
    self.class.insert_data()
  end
  
  
  
  def down
    
    self.class.delete_data()
  end
  
  
  #best insert sql data
  #redo with
  #require "db/migrate/048_add_data_to_gene_group_cnts.rb"
  #AddDataToGeneGroupCnts.insert_data()
  
  #rails runner 'require "db/migrate/048_add_data_to_gene_group_cnts.rb"; AddDataToGeneGroupCnts::insert_data();'

  def self.delete_data()
     execute "delete from gene_group_cnts"
  end

  def self.insert_data()
    
    execute "delete from gene_group_cnts"
    
    execute "insert into gene_group_cnts
              (gene_id,PROK_GROUP_ID,name,cnt)
             select gbs.GENE_ID,
                    tg.PROK_GROUP_ID,
                    pg.NAME,
                    count(*) as CNT
             from GENE_BLO_SEQS gbs
              join NCBI_SEQS ns on ns.ID = gbs.NCBI_SEQ_ID
              join TAXON_GROUPS tg on tg.ID = ns.TAXON_ID
              join PROK_GROUPS pg on pg.ID = tg.PROK_GROUP_ID
             group by gbs.GENE_ID,
                      tg.PROK_GROUP_ID,
                      pg.NAME
             order by gbs.GENE_ID,
                      tg.PROK_GROUP_ID"
        
  end
  
end
