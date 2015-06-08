require 'taxon_meta'
require 'faster_csv'

class AddHabitatDataToTaxonGroups < ActiveRecord::Migration

  def up
    
    hab = TaxonMeta.new("Habitat").habitats
    
      
    csv_data = FasterCSV.open("#{AppConfig.db_imports_dir}/habitat_db.csv",:col_sep => "|")
    
    columns = csv_data.shift
    
    csv_data.each { |row|
      
     (0..hab.length-1).each {|idx|
    
      #found entry
      if not row[idx+1].nil?
        abrev = hab[idx][0]
        pg = ProkGroup.find_by_abrev(abrev)
        taxon_id = row[0]
        
          #puts "taxon_id: #{taxon_id}, pg.id: #{pg.id}"
          execute "insert into TAXON_GROUPS
                    (prok_group_id,taxon_id)
                   values
                     (#{pg.id},#{taxon_id})"
        
      end
      
  
      
      
  } 
      
      
    # use row here...
    #  puts "difference --#{row[1]},#{row[2]}---------------------" if row[1]!=row[2]
    #next if row.length == 0

    #update Taxons
    #ar_row = Taxon.find_or_initialize_by_id(row[1])
    #ar_row.sci_name = row[3]
    #ar_row.save

    puts row.inspect

    }    
    
  end


  def down
   execute "delete
            from TAXON_GROUPS tg
            where id in (select id
                         from TAXON_GROUPS tg
                          join PROK_GROUPS pg on pg.ID = tg.PROK_GROUP_ID
                          join GROUP_CRITERS gc on gc.ID = pg.GROUP_CRITER_ID
                         where gc.NAME = 'habitat')"
   
  end

end
