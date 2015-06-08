class AddNodeColorDataToProkGroups < ActiveRecord::Migration
  def up
    self.class.update_data()
  end
  
  def down
    execute "update prok_groups
             set (cin_node_name,color_id) = (null,null)"
  end
  
  def self.update_data()
    
   #insert group names
   [[0,'240015',0,'Acidobacteria'],
    [1,'INT2037',1,'Actinobacteria'],
    [2,'INT28211',2,'Alphaproteobacteria'],
    [3,'224324',3,'Aquificae'],
    [4,'INT68336',4,'Bacteroidetes/Chlorobi'],
    [5,'INT28216',28,'Betaproteobacteria'],
    [6,'INT51290',6,'Chlamydiae/Verrucomicrobia'],
    [7,'INT61434',7,'Chloroflexi'],
    [8,'INT183924',8,'Crenarchaeota'],
    [9,'INT1117',9,'Cyanobacteria'],
    [10,'743525',10,'Deinococcus-Thermus'],
    [11,'INT28221',11,'Deltaproteobacteria'],
    [12,'INT72293',12,'Epsilon-proteobacteria'],
    [13,'INT28890',13,'Euryarchaeota'],
    [14,'INT1239',14,'Firmicutes'],
    [15,'190304',15,'Fusobacteria'],
    [16,'INT543',16,'Gammaproteobacteria'],
    [17,'228908',17,'Nanoarchaeota'],
    [18,'OTHA',18,'Other Archaea'],
    [19,'OTHB',19,'Other Bacteria'],
    [20,'243090',20,'Planctomycetes'],
    [21,'INT136',21,'Spirochaetes'],
    [22,'484019',22,'Thermotogae'],
   ].each { |pgd|
      
     execute "update prok_groups
             set (cin_node_name,color_id) = ('#{pgd[1]}',#{pgd[2]})
             where id = #{pgd[0]} "      
    }
    
  
  end
end
