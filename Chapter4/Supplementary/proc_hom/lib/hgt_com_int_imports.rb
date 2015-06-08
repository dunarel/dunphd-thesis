
require 'rubygems'
require 'bio' 
require 'msa_tools'
require 'faster_csv'

class HgtComIntImports
  
 def initialize()
  @ud = UqamDoc::Parsers.new
 end
 
 
  def fragms
     
    HgtComIntFragm.destroy_all
    
    Dir.chdir "#{AppConfig.hgt_com_int_dir}"
    
    cnt = 0
    files = `cat values.txt`
    files.each { |fl|
       cnt += 1
       #next if cnt >1
       
      
       if fl =~ /^(\S+)\s+(\S+)/
         @gene=$2
         @hgt_com_int_dir = "hgt-com-int_gene#{@gene}_id#{$1}.BQ"

       end

      puts @hgt_com_int_dir
      @hgt_com_int_output_f = "#{@hgt_com_int_dir}/output.txt"

       
      if File.exists?(@hgt_com_int_output_f) 
       File.open(@hgt_com_int_output_f,"r") { |hci|
         #parse results file
          hci.each { |ln|
            #puts ln
            if ln =~ /^\|\sIteration\s\#(\d+)\s:/
              #puts "------------#{$1}---------->#{ln}"
              @iter_no = $1
            elsif ln =~ /^\|\sHGT\s(\d+)\s\/\s(\d+).+Trivial/
              #puts "------Trivial-------------->#{ln}"
              @hgt_no = $1
              @bs_val = 0.0
            elsif ln =~ /^\|\sHGT\s(\d+)\s\/\s(\d+)\s\(bootstrap\svalue\s=\s([\d|\.]+)\%\)/
               # puts "------#{$1}--#{$3}------------>#{ln}"
               @hgt_no= $1
               @bs_val = $3.to_f
             elsif ln =~ /^\|\sFrom\ssubtree\s\(([\d|\,|\s]+)\)\sto\ssubtree\s\(([\d|\,|\s]+)\)/
              #puts "------#{$1}---#{$2}----------->#{ln}"
               @from_subtree=$1
               @to_subtree = $2
               #insert row in interior loop
               if @bs_val !=0
                frgm = HgtComIntFragm.new
                puts "#{@iter_no},#{@hgt_no},#{@from_subtree},#{@to_subtree},#{@bs_val}" 
                frgm.gene = Gene.find_by_name(@gene)
                frgm.iter_no=@iter_no.to_i
                frgm.hgt_no=@hgt_no.to_i

                frgm.from_subtree=@from_subtree
                #update nb of source gi-s
                frgm.from_cnt = @from_subtree.split(",").length

                frgm.to_subtree=@to_subtree
                frgm.to_cnt = @to_subtree.split(",").length
                frgm.bs_val=@bs_val.to_f
                frgm.save
               end
            else
             #puts ln
            end

            


          }
       }
      end 

     

      

      
    
    }



    #columns = csv_data.shift
    
    #csv_data.each { |row|
    # use row here...
    #  puts "difference --#{row[1]},#{row[2]}---------------------" if row[1]!=row[2]
    #next if row.length == 0

    #update Taxons
    #ar_row = Taxon.find_or_initialize_by_id(row[1])
    #ar_row.sci_name = row[3]
    #ar_row.save#

    #puts row.inspect

    #}
  
  end


end
