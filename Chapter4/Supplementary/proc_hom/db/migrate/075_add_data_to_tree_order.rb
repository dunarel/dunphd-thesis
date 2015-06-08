require 'faster_csv'

class AddDataToTreeOrder < ActiveRecord::Migration
  def up
    self.class.update_data()
  end
  
  def down
    self.class.delete_data()
    
  end
  
  def self.update_data()
    self.delete_data()
    self.insert_data()
  end
  
  def self.update_data_csv()
    
    csv_data = FasterCSV.open("#{AppConfig.db_imports_dir}/sp-tr-cin-taxon-names.csv",:col_sep => "\t")
    
    columns = csv_data.shift
    
    csv_data.each { |row|
      
    # use row here...
    puts "row[0]: #{row[0]},row[1]: #{row[1]}, row[2]: #{row[2]}, row[3]: #{row[3]}"
    
   
    #next if row.length == 0

    #update Taxons
    
    execute "update taxons
             set tree_name = '#{row[2]}',
                 tree_order = '#{row[3]}'
             where id = '#{row[0]}'"   
    

    }
    
  end
  
  def self.insert_data()
    
   [[0,228908],
    [1,374847],
    [2,272557],
    [3,273057],
    [4,768679],
    [5,188937],
    [6,362976],
    [7,309800],
    [8,348780],
    [9,634497],
    [10,272569],
    [11,243090],
    [12,190304],
    [13,240015],
    [14,743525],
    [15,224324],
    [16,484019],
    [17,255470],
    [18,311424],
    [19,330214],
    [20,379066],
    [21,267671],
    [22,759914],
    [23,565034],
    [24,167539],
    [25,1148],
    [26,],
    [27,],
    [28,],
    [29,],
    [30,],
    [31,],
    [32,],
    [33,],
    [34,],
    [35,],
    [36,],
    [37,],
    [38,],
    [39,],
    [40,],
    [41,],
    [42,],
    [43,],
    [44,],
    [45,],
    [46,],
    [47,],
    [48,],
    [49,],
    [50,],
    [51,],
    [52,],
    [53,],
    [54,],
    [55,],
    [56,],
    [57,],
    [58,],
    [59,],
    [60,],
    [61,],
    [62,],
    [63,],
    [64,],
    [65,],
    [66,],
    [67,],
    [68,],
    [69,],
    [70,],
    [71,],
    [72,],
    [73,],
    [74,],
    [75,],
    [76,],
    [77,],
    [78,],
    [79,],
    [80,],
    [81,],
    [82,],
    [83,],
    [84,],
    [85,],
    [86,],
    [87,],
    [88,],
    [89,],
    [90,],
    [91,],
    [92,],
    [93,],
    [94,],
    [95,],
    [96,],
    [97,],
    [98,],
    [99,],
    [100,],
    [101,],
    [102,],
    [103,],
    [104,],
    [105,],
    [106,],
    [107,],
    [108,],
    [109,],
    [110,]
   ].each { |tx|
      
     execute "update taxons
              set tree_order = #{tx[0]}
              where id = #{tx[1]}"      
    }
    
  end
  
  def self.delete_data()
    execute "update taxons
             set tree_order = null"

  end
end
