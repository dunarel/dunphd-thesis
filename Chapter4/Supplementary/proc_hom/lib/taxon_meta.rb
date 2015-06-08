require 'rubygems'
require 'nokogiri'
require 'open-uri'

class TaxonMeta
  
  attr_reader :ncbi_taxid,
    :img_taxon_oid,
    :overview_lst,
    :goldstamp,
    :habitats
  
  def initialize(crit)
    @crit = crit
    
    @habitats = [["human-resp", "Human Respiratory"] ,
          ["human-other", "Human Others"],
          ["plant", "Plant"],
          ["animal","Animal"],
          ["soil","Soil"],
          ["marine","Marine"],["freshwater","Fresh water"],
          ["extreme","Extreme"]]
    
  end
  
  
  
  
  
  def ncbi_taxid=(ncbi_taxid)
    @ncbi_taxid = ncbi_taxid
    
  end
  
  def img_taxon_oid=(img_taxon_oid)
    @img_taxon_oid = img_taxon_oid
  end

  def goldstamp=(goldstamp)
    @goldstamp = goldstamp
  end
  
  def calc_img_taxon_oid()
    
    img_taxon_oid  = 0
    # ncbi_href = "www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=#{ncbi_taxid}"
    
    ncbi_href = "http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=#{ncbi_taxid}"
    
    ncbi_text = URI.escape(ncbi_href)

    
    
    puts ncbi_href
    
    doc = Nokogiri::HTML(open(ncbi_text))
    puts "ok"

    ####
    # Search for nodes by css
    link = doc.css("a[href^='http://img.jgi.doe.gov/genome.php?']")[0]
    
    
    
    #puts "link: #{link.inspect}"
    #puts "link.value: #{link.name}
    #puts link.name
    if link.nil? 
      @img_taxon_oid = nil
      return nil
    else
      attr = link.attributes
      #puts attr.inspect

      img_href = attr["href"].to_s
      puts "img_href: ->#{img_href}<-"
      if img_href =~ /^http\:\/\/img\.jgi\.doe\.gov\/genome\.php\?id\=(\d+)/
        img_taxon_oid = $1
      end
    
      #puts "found: #{img_taxon_oid}"
      @img_taxon_oid = img_taxon_oid.to_i
       
      return @img_taxon_oid
    end
    
        
  end
  
  def calc_goldstamp()
    
    gold_taxon_oid  = 0
    # ncbi_href = "www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?id=#{ncbi_taxid}"
    
    ncbi_href = "http://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=#{ncbi_taxid}"
    
    ncbi_text = URI.escape(ncbi_href)

    
    
    puts ncbi_href
    
    doc = Nokogiri::HTML(open(ncbi_text))
    puts "ok"

    ####
    # Search for nodes by css
    link = doc.css("a[href^='http://genomesonline.org/cgi-bin/GOLD/bin/GOLDCards.cgi?goldstamp=']")[0]
    
    
    
    puts "link: #{link.inspect}"
    #puts "link.value: #{link.name}
    #puts link.name
    if link.nil? 
      @gold_taxon_oid = nil
      return nil
    else
      attr = link.attributes
      #puts attr.inspect

      img_href = attr["href"].to_s
      puts "img_href: ->#{img_href}<-"
      #if img_href =~ /^http\:\/\/genomesonline\.org\/cgi-bingenome\.php\?id\=(\d+)/
      if img_href =~ /^http\:\/\/genomesonline\.org\/cgi-bin\/GOLD\/bin\/GOLDCards\.cgi\?goldstamp\=(.+)/
        puts "$1: #{$1}"
        goldstamp = $1
      end
    
      #puts "found: #{img_taxon_oid}"
      @goldstamp = goldstamp.strip
       
      return @goldstamp
    end
    
        
  end
  
  
  
  def calc_overview_lst()

    img_href = "http://img.jgi.doe.gov/cgi-bin/w/main.cgi?section=TaxonDetail&taxon_oid=#{@img_taxon_oid}"
    #puts "img_href: #{img_href}"

    img_page = Nokogiri::HTML(open(img_href))

    # Search for nodes by css


    #img_page.css('h2:contains("Overview")+tr').each {|elem|
    #img_page.css("h2:only-child").each {|elem|
    elem = img_page.css('tr[class=img]+:first-child:contains("Habitat")')[0] #.each {|elem|
    #puts elem.inspect
    puts "---------"
    if elem.nil?
     @overview_lst = nil     
     return @overview_lst
     
    else

     puts "elem length: #{elem.children.length}"
     hab_txt = elem.children[3].children[0]
     @overview_lst = hab_txt.content
      
     return @overview_lst
     
    end  
    
    
  end
  
  def calc_gold_attr()

    gold_href = "http://genomesonline.org/cgi-bin/GOLD/bin/GOLDCards.cgi?goldstamp=#{@goldstamp}"
    #puts "img_href: #{img_href}"

    gold_page = Nokogiri::HTML(open(gold_href)) do |config|
      config.strict.noblanks
     end

    
    # Search for nodes by css


    #img_page.css('h2:contains("Overview")+tr').each {|elem|
    #img_page.css("h2:only-child").each {|elem|
    
    #elem = img_page.css('tr[class=img]+:first-child:contains("Habitat")')[0] #.each {|elem|
    #//*[@id='outer']/div/div/div/div[a[@href='www.blah.com']]

    elem = gold_page.xpath("//tr/th/b[text()='HABITAT']/parent::*/parent::*/td/b/child::text()").each {|elem|
      
      #puts elem.content
      #puts "11111111"
      #elem.children.each { |ch|
       # puts "22222222222222"
       
       # //h:h2[re:test(., 'chapter|section', 'i')]
        
        
        #puts "ch: #{ch.inspect}"
        
        
        
      #}
     
    }
    
    
    
    habitat = gold_page.xpath("//tr/th/b[contains(text(), 'HABITAT')]/parent::*/parent::*/td/b/child::text()").first.content
    puts habitat
    
    
    isolation_site = gold_page.xpath("//tr/th/b[contains(text(), 'ISOLATION SITE')]/parent::*/parent::*/td/b/child::text()").first.content
    puts isolation_site
    
    host_name = gold_page.xpath("//tr/th/b[contains(text(), 'HOST NAME')]/parent::*/parent::*/td/b/child::text()").first.content
    puts host_name
    
    host_taxon_id = gold_page.xpath("//tr/th/b[contains(text(), 'HOST TAXON ID')]/parent::*/parent::*/td/b/child::text()").first.content
    puts host_taxon_id
    
        
    #puts "---------"
    #if elem.nil?
    # @overview_lst = nil     
    # return @overview_lst
     
    #else

    # puts "elem length: #{elem.children.length}"
    # hab_txt = elem.children[3].children[0]
    # @overview_lst = hab_txt.content
    #  
    # return @overview_lst
     
    #end  
    
    
  end
  
  
  def test
    tm = TaxonMeta.new("Habitat")

    
    tm.ncbi_taxid = 561275

    img_taxon_oid = tm.calc_img_taxon_oid()
    puts "taxon_oid: #{img_taxon_oid}"

    overview_lst =  tm.calc_overview_lst
    puts "overview_lst: #{tm.overview_lst}"

    #img_taxon_oid = 643692001


      
    #txt =  elem.children[0]
    #puts "txt: #{txt.inspect}"
    #puts "txt.content: #{txt.content}"
    #puts "elem.to_s: #{elem.to_s}"
  
  
    #}


    #puts img_page.content

    #puts "doc: #{img_page.inspect}"
  end
  
  #desc "launch testing code"
  def update_img_taxon_oid()
   
      
    nst = NcbiSeqsTaxon.where('img_taxon_oid is null')
    nst.each { |it|  
      @ncbi_taxid = it.taxon_id
      
      
      it.img_taxon_oid = @calc_img_taxon_oid || nil
      it.save
      sleep 2
      
    }
    
    

    #img_taxon_oid = tm.calc_img_taxon_oid()
    #puts "taxon_oid: #{img_taxon_oid}"

    #overview_lst =  tm.calc_overview_lst
    #puts "overview_lst: #{tm.overview_lst}"

 
   
  end
  
  #desc "launch testing code"
  def read_overview_lst()
   
      
    nst = NcbiSeqsTaxon.find(:all)
     
    nst.each { |it|  
      
 
      @img_taxon_oid = it.img_taxon_oid
      calc_overview_lst

      
       overview_lst = @overview_lst || "Other Habitat"
       it.habitat = overview_lst
       it.save
       
       
       overview_arr = overview_lst.split(",").collect{|e| e.strip}.uniq
      
  
        overview_arr.each {|gr_name|
          
          pg = ProkGroup.find_or_create_by_name_and_group_criter_id(gr_name, 1)

          tg = TaxonGroup.find_or_create_by_prok_group_id_and_taxon_id(pg.id, it.taxon_id)
    
          puts "x: #{overview_lst.inspect}, pg: #{pg.inspect}, tg: #{tg.inspect}"          

         }
      

      
      #it.img_taxon_oid = tm.calc_img_taxon_oid || nil
      #it.save
      sleep 5
      
    }
    
    

    #img_taxon_oid = tm.calc_img_taxon_oid()
    #puts "taxon_oid: #{img_taxon_oid}"

    #overview_lst =  tm.calc_overview_lst
    #puts "overview_lst: #{tm.overview_lst}"

 
   
  end
  
    
  def export_habitat()
   
    pgs = ProkGroup.where('group_criter_id = 1').order('id')
    pgs_arr = pgs.collect{|e| [e.id, e.name]}

    head = ['TAXON_ID\CATEG']    
    FasterCSV.open("#{AppConfig.db_exports_dir}/habitat.csv", "w", {:col_sep => ","}) { |csv|
     
      pgs_arr.each {|pg|
        head << pg[1]
      }
      puts "head: #{head}"
      csv << head

      nsts =  NcbiSeqsTaxon.select("taxon_id").order("taxon_id")
      
      nsts.each { |nst|
        
        puts "nst: #{nst.inspect}" 

        row = [nst.taxon_id]

        pgs_arr.each { |pg|
        

          tg =  TaxonGroup.find_by_prok_group_id_and_taxon_id(pg[0], nst.taxon_id)
          fnd = tg.nil? ? 0 : 1

          row << fnd
          puts "pg[0]: #{pg[0]}, fnd: #{fnd}"
         
        }
        csv << row
      }
    }
   
  end

  
  
  
end






