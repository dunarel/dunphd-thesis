
require 'rubygems'
require 'bio' 
require 'msa_tools'
require 'faster_csv'

class WorkImports
  
 def initialize()
  @ud = UqamDoc::Parsers.new
 end
 
 
  def taxons_sci_names

    csv_data = FasterCSV.open("#{AppConfig.db_imports_dir}/taxids_scinames.csv",:col_sep => "\t|\t")
    
    columns = csv_data.shift
    
    csv_data.each { |row|
    # use row here...
    #  puts "difference --#{row[1]},#{row[2]}---------------------" if row[1]!=row[2]
    #next if row.length == 0

    #update Taxons
    ar_row = Taxon.find_or_initialize_by_id(row[1])
    ar_row.sci_name = row[3]
    ar_row.save

    puts row.inspect

    }
  
  end


end
