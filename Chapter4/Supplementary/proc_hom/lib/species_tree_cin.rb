require 'rubygems'
require 'bio'
require 'msa_tools'


class ZedCoord
  
  attr_accessor :x, :y, :nb
  
  def initialize(orig_x,orig_y, cols,rows, dx, dy)
    @orig_x,@orig_y, @cols, @rows, @dx, @dy = orig_x, orig_y, cols,rows, dx, dy
    
    @nb = 0
    @x = @orig_x
    @y = @orig_y
    
    
    
  end
  
  #
  def inc
    modulo_nb = ((@nb+1) % @cols)
    #puts "modulo_nb: #{modulo_nb}"
    
    if ((@nb+1) % @cols) == 0
      @x = @orig_x
      @y += @dy
    else
      @x += @dx
    end
    #
    @nb += 1
  end
  
  
end

class SpeciesTreeCin
  def initialize
    #personalize class
    @stage = "sp-tr-cin"
    
    #set exports dir
    @exp_dir = "#{AppConfig.db_exports_dir}/#{@stage}"  
    puts "@exp_dir #{@exp_dir}"
    
    @tr_tid_fname = "#{@exp_dir}/#{@stage}.phy"
    @tr_tid_mod_fname = "#{@exp_dir}/#{@stage}-mod.phy"
    puts "@tr_tid_fname #{@tr_tid_fname}"
    puts "@tr_tid_mod_fname #{@tr_tid_mod_fname}"
        
     
    
    @strips_fname = "#{@exp_dir}/#{@stage}-strips.csv"
 
    @colors_fname = "#{@exp_dir}/#{@stage}-colors.csv"
    
    @font_styles_fname = "#{@exp_dir}/#{@stage}-font-styles.csv"
    
    @tree_order_fname = "#{@exp_dir}/#{@stage}-tree-order.csv"
    
    

    puts "@strips_fname #{@strips_fname}"
    puts "@colors_fname #{@colors_fname}"
    
    
    #
    @legend_fname = "#{@exp_dir}/#{@stage}-legend.tex"
    
    @hgts_itol_fname = "#{@exp_dir}/#{@stage}-hgts-itol.csv"
    
      
    
    
    
    @ud = UqamDoc::Parsers.new
    
    @conn = ActiveRecord::Base.connection
    #connection for direct JDBC
    @jdbc_conn=@conn.jdbc_connection
    
    
  end
  
  def load_initial_tree
    str = @ud.get_file_as_string(@tr_tid_fname)
    #puts "tree: #{str}"


    @t0 = Bio::Newick.new(str, nil).tree
    @t0.root.name = "root"
    
  end
  
  def BFS2()
    queue = ["A"]
    visited = {"A"=>true}
    print "A "
    while(!queue.empty?)
      node = queue.pop()
      $list[node].each do |child|
        if visited[child] != true then
          print "#{child} "
          queue.push(child)
          visited[child] = true
        end
      end
    end
  end

  
  def bfs()
    
    avail_node_ids = @t0.nodes().collect{|n| n.name }
    #puts "avail_node_ids: #{avail_node_ids.inspect}"
   
   
    root_name = @t0.root.name
   
    puts "root_name: #{root_name}"
    i=0
    @lst = {}
   
   
    @lst[i] = [root_name]
   
    while !@lst[i].empty?
      @lst[i+1] = []
      #puts "lst[i+1]: #{@lst[i+1]}"
      @lst[i].each { |elem|
        tnode = @t0.get_node_by_name(elem)
          
      
        child_ids =  @t0.children(tnode).collect{|n| n.name} 
        child_ids.each { |child|
          #puts "child #{child} "
          if avail_node_ids.include?(child)
            #puts "before add lst: i: #{i}, #{lst[i+1].inspect}, child: #{child}"
            @lst[i+1] += [child]
            #puts "after add lst: #{@lst.inspect}"
            avail_node_ids.delete child
          end
          
        }
      
      }
      i += 1
      # puts "i: #{i}"
      
    end
    @lst.delete(@lst.length-1)
   
  
   
     
   
    
    
    puts "root: #{@t0.root.inspect}"
    
    @t0.each_node {|n|
      #puts n.name 
    }
    
    
    
    
  end
  
  def remove_internal_node(node)
    p = @t0.parent(node)
    c = @t0.children(node).first
    @t0.remove_edge(p,node)
    @t0.remove_edge(node,c)
    @t0.remove_node(node)
    @t0.add_edge(p,c)
  end
  
  def adjust_nodes
    
    #eliminate root and reroot
    #tnode = @t0.get_node_by_name("root")
    #@t0.remove_node(tnode)
   
    #@t0.root= @t0.get_node_by_name("INT131567")
    
    #eliminate nodes
    #["INT131550","INT213849","INT29547","INT1236","INT91347"].each {|nn|
    #  n = @t0.get_node_by_name(nn)
    #  remove_internal_node(n)
      
    #}
      
    
    
    #add OTHA
    n1 = @t0.get_node_by_name("INT2157")
    n2 = @t0.get_node_by_name("374847")
    @t0.remove_edge(n1,n2)
    n3 = Bio::Tree::Node.new("OTHA")
    @t0.add_node(n3)
    @t0.add_edge(n1,n3)
    @t0.add_edge(n3,n2)
    
    #add OTHB
    n1 = @t0.get_node_by_name("INT2")
    n2 = Bio::Tree::Node.new("OTHB")
    @t0.add_node(n2)
    @t0.add_edge(n1,n2)
    
    #detach and reconnect
    n3 = @t0.get_node_by_name("330214")
    p = @t0.parent(n3) 
    @t0.remove_edge(p,n3)
    @t0.add_edge(n2,n3)
    
    n4 = @t0.get_node_by_name("379066")
    p = @t0.parent(n4) 
    @t0.remove_edge(p,n4)
    @t0.add_edge(n2,n4)
    
        
  end
  
  def linearize
    #all remove internal nodes 
    @t0.remove_nonsense_nodes()
    
  end
  
  def save_mod_tree()
    
    st = @t0.output_newick
    
    @ud.string_to_file(st, @tr_tid_mod_fname)
    
    
  end
  
=begin  
  def reload_mod_tree()
    
    str = @ud.get_file_as_string(@tr_tid_exp_mod_fname)
    #puts "tree: #{str}"


    @t1 = Bio::Newick.new(str, nil).tree
    
    
  end
=end
  
  def adjust_branch_length_custom()
    puts "lst_length: #{@lst.length}"
    #puts "lst: #{@lst.inspect}"
    
    (1..@lst.length-1).each {|lv|
     
      dist = case lv 
      when 1
        then 8
      when 2
        then 8
      when 3
        then 5
      when 4
        then 4
      else
        0.3
      end
     
      
      @lst[lv].each {|name|
       
     
        n2 = @t0.get_node_by_name(name)
        #puts "n2: #{n2.inspect}"
        n1 = @t0.parent(n2)
        #puts "n1: #{n1.inspect}"
        ed = @t0.get_edge(n1,n2)
        #puts "n1: #{n1.inspect}, n2: #{n2.inspect} ed: #{ed.inspect}"
      
        #finetune 
        case name
        when "INT1224"
          ed.distance = 4
        else
          ed.distance = dist
        end
        
      
      }
    
    }
    
    
    @t0.edges.each {|n1,n2,e|
     
      dist = e.distance
      if not dist.nil?
        #puts "n1: #{n1.inspect}, n2: #{n2.inspect} e: #{e.inspect}"
      end
      
    }
    
  end
  
  def adjust_branch_length_unit()
    #puts "lst_length: #{@lst.length}"
    #puts "lst: #{@lst.inspect}"
    
     
    
    @t0.edges.each {|n1,n2,e|
     
      e.distance = 1
      
      puts "n1: #{n1.inspect}, n2: #{n2.inspect} e: #{e.inspect}"
      
      
    }
    
  end
  
  def relabel_leafs
    
    @t0.leaves.each {|lf|
      #skip root
      next if lf.name=="root"
      #puts "leaf: #{lf.name}"
      #p = @t0.parent(lf)
      id = lf.name
      treename = Taxon.find(id).tree_name
      #correct spaces
      col_name = treename.gsub(/\s/,'_')
      #
      #relabel colors too
      @prok_group_colors.collect! {|col|
        col["cin_node_name"] = col_name if col["cin_node_name"] == id
        # return col
        col  
      }
      
      #relabel hgts too
      @hgts_itol.collect! {|hgt|
        hgt["source_node_id"] = col_name if hgt["source_node_id"] == id
        hgt["destination_node_id"] = col_name if hgt["destination_node_id"] == id
        # return col
        hgt  
      }
     
      #puts "col: #{col.inspect}"
      #puts "trname: #{trname}, "
    
   
      
      
      
      
      #if sciname =~ /(.+):(.+)/
      #  puts "sciname: #{sciname}"
      #  sciname = "#{$1}_#{$2}"
      #  puts "sciname_mod: #{sciname}"
      #end
      
      #corrected names (too long)
      #corname = case id
      #when "321314" then
      #  "Salmonella enterica serovar Choleraesuis str. SC-B67"
      # else
      #   sciname
      #end
     
      lf.name = treename
      #puts "id: #{id}, lf.name: #{lf.name}"
      
      
    }
    
  end

  
  def reload_tree_names_csv
    require "db/migrate/075_add_data_to_tree_order.rb"
    AddDataToTreeOrder::update_data_csv()   
    
  end
  
  def reload_tree_names
   
    txns = Taxon.find :all
    txns.each { |tx|
     
      #shorten and correct names for tree display
      corname = tx.sci_name.to_s
      corname = corname.gsub(/serovar\s+\w+\s/,'')
      corname = corname.gsub(/biovar\s+\w+\s/,'')
      corname = corname.gsub(/subsp\.\s+\w+\s/,'')
      corname = corname.gsub(/'/,'')
      corname = corname.gsub(/:/,' ')
      corname = corname.gsub(/Pasteur\s/,'')
      corname = corname.gsub(/Tokyo\s/,'')
      corname = corname.gsub(/substr\.\s/,'')
      corname = corname.gsub(/str\.\s/,'')
      
      #According to the "IRPCM Phytoplasma/Spiroplasma Working Team - Phytoplasma taxonomy group" the abbreviation for Candidatus should be Ca..
      corname = corname.gsub(/Candidatus/,'Ca.')
      
      long_genus = corname.gsub(/(Ca\.\s)?(\w+\s)(.+)/,'\2')
      genus = corname.gsub(/(Ca\.\s)?(\w)(\w+)\s(.+)/,'\2.')
      
      
      #puts "long_genus: #{long_genus}, genus: #{genus}"
      
      corname = corname.sub(long_genus,genus)
      
      corname = corname.gsub(/amyloliquefaciens/,'amyloliquef.')
      corname = corname.gsub(/acetobutylicum/,'acetobut.')
      corname = corname.gsub(/branchiophilum/,'branchioph.')
      corname = corname.gsub(/autotrophicum/,'autotroph.')
      corname = corname.gsub(/diazotrophicus/,'diazotroph.')
      corname = corname.gsub(/succinogenes/,'succinog.')
      
      
      #save to corrected field
      tx.tree_name = corname
      tx.save
      
      puts "tx     : #{tx.sci_name}"
      puts "corname: #{corname}"
      
    }
   
  end
 
  def export_strips
   
    #update colors
    require "db/migrate/070_add_node_color_data_to_prok_groups.rb"
    #uncomment to change group color assignment to database
    #AddNodeColorDataToProkGroups::update_data()
   
    csvf = File.new(@strips_fname, "w")
   
    sql = "select tx.tree_name,
                  col.RGB_HEX
           from TAXONS tx
            join TAXON_GROUPS tg on tg.TAXON_ID = tx.id
            join PROK_GROUPS pg on pg.ID = tg.PROK_GROUP_ID
            join colors col on col.ID = pg.COLOR_ID
           where pg.GROUP_CRITER_ID = 0
           order by pg.ORDER_ID,
                    tx.id"
   
    colors = @conn.select_all sql
    colors.each {|col|
      #correct spaces
      trname = col["tree_name"].gsub(/\s/,'_')
     
      #puts "col: #{col.inspect}"
      puts "trname: #{trname}, "
      csvf.puts "#{trname}\t#{col["rgb_hex"]}"
    }
   
    #puts colors.inspect
    csvf.close
   
  end
  
  def export_font_styles()
    
    csvf = File.new(@font_styles_fname, "w")
    
    sql = "select tx.tree_name
           from TAXONS tx"
   
    taxons = @conn.select_all sql
    taxons.each {|tx|
      
      trname = tx["tree_name"].gsub(/\s/,'_')
      
      x,y,z = ""
      
      if trname =~ /^([a-zA-Z\.]+)\_(.+)/
        x = $1
        #reverse underscores to spaces in font styles
        y = $2.gsub(/\_/,' ')
        z = "<I>#{x}</I> #{y}"
        puts "x: #{x}, y: #{y}, z: #{z}"
      else
        z = "<I>#{tx["tree_name"]}</I>" 
      end
      
      #second_word = trname.sub(/\_+(.+)/,'\1')
      #puts "trname = >#{trname}<"
      #puts "second_word: #{second_word}"
      #first_word = trname.gsub(/(.+)\_(.+)/,'\1')
      
      #correct spaces
      
      
     
      #puts "col: #{col.inspect}"
      #puts "trname: #{trname}, first_word: #{first_word}, second_word: #{second_word}"
      
      csvf.puts "#{trname}\t#{z}"
    }
   
    #puts colors.inspect
    csvf.close
  end
  
   def export_tree_order
     
   
    csvf = File.new(@tree_order_fname, "w")
   
    sql = "select tx.tree_order,
             	    tx.TREE_NAME,
                  pg.ORDER_ID+1 as group_order,
                  pg.ID+0 as group_id,
                  pg.NAME||'' as group_name
           from taxons tx 
            join TAXON_GROUPS tg on tg.TAXON_ID = tx.id
            join PROK_GROUPS pg on pg.ID = tg.PROK_GROUP_ID
           where pg.ID between 0 and 32
           order by tx.TREE_ORDER"
   
    colors = @conn.select_all sql
    colors.each {|col|
      #correct spaces
      
     
      #puts "col: #{col.inspect}"
      #puts "trname: #{trname}, "
      csvf.puts "#{col["tree_order"]}\t#{col["tree_name"]}\t#{col["group_order"]}\t#{col["group_id"]}\t#{col["group_name"]}"
    }
   
    #puts colors.inspect
    csvf.close
   
  end
  
   
  
   
  def reload_colors
    require "db/migrate/069_add_data_to_colors"
    AddDataToColors::update_data()   
    
    
  end
  
  def load_group_colors
    sql = "select pg.CIN_NODE_NAME,
                 col.RGB_HEX,
                 pg.name
          from PROK_GROUPS pg
           join colors col on col.id = pg.COLOR_ID          
          where pg.GROUP_CRITER_ID = 0
          order by pg.ORDER_ID"
   
    @prok_group_colors = @conn.select_all sql
    #puts colors.inspect
   
  end
  
  
  def load_hgts_itol()
   sql = "select pg_src.CIN_NODE_NAME as SOURCE_NODE_ID,
                 pg_dst.CIN_NODE_NAME as DESTINATION_NODE_ID,
                 col.RGB_HEX as COLOR,
                 tgh.VAL1 as label
          from TREE_GROUPS_HGTS tgh
 join PROK_GROUPS pg_src on pg_src.ID = tgh.PROK_GROUP_SOURCE_ID
 join PROK_GROUPS pg_dst on pg_dst.id = tgh.PROK_GROUP_DEST_ID
 join COLORS col on col.ID = pg_src.COLOR_ID"
    
    @hgts_itol = @conn.select_all sql
  end
  
 
  def export_hgts_itol

    puts @hgts_itol.inspect
    
    hgts_itol = File.new(@hgts_itol_fname, "w")
   
    @hgts_itol.each {|hgt|
      #correct spaces
      #trname = col["tree_name"].gsub(/\s/,'_')
     
      #puts "col: #{col.inspect}"
      #puts "trname: #{trname}, "
      hgts_itol.puts "#{hgt["source_node_id"]}\t#{hgt["destination_node_id"]}\t#{hgt["color"]}\t#{hgt["label"]}"
    }
    hgts_itol.close
   
  end
  
  
  
 
 
  def export_group_colors
    #update colors
    #require "db/migrate/070_add_node_color_data_to_prok_groups.rb"
    #AddNodeColorDataToProkGroups::update_data()
   
   
    colf = File.new(@colors_fname, "w")
   
    @prok_group_colors.each {|col|
      #correct spaces
      #trname = col["tree_name"].gsub(/\s/,'_')
     
      #puts "col: #{col.inspect}"
      #puts "trname: #{trname}, "
      colf.puts "#{col["cin_node_name"]}\trange\t#{col["rgb_hex"]}\t#{col["name"]}"
    }
    colf.close
   
   
   
  end
  
  # http://stackoverflow.com/questions/84421/converting-an-integer-to-a-hexadecimal-string-in-ruby
  def tex_color_def(hex_color)
    tex_color = ""
      
    if hex_color =~ /#(\w\w)(\w\w)(\w\w)/
      #
      er,ge,be = $1.hex,$2.hex,$3.hex
      #puts "#{er},#{ge},#{be}"
      hex_code = hex_color.gsub(/#/,'c')
        
      tex_color = "\\definecolor{#{hex_code}}{RGB}{#{er},#{ge},#{be}}"
    end
      
    tex_color
    
  end
  
  def tex_color_code(hex_color)
           
    if hex_color =~ /#(\w\w)(\w\w)(\w\w)/
      #
      er,ge,be = $1.hex,$2.hex,$3.hex
      #puts "#{er},#{ge},#{be}"
      hex_code = hex_color.gsub(/#/,'c')
        
        
    end
      
    hex_code
    
  end
  
  
  def define_tex_colors
    @prok_group_colors.each {|col|
      #correct spaces
      #trname = col["tree_name"].gsub(/\s/,'_')
     
      #puts "col: #{col.inspect}"
      #puts "trname: #{trname}, "
      hex_color = col["rgb_hex"]
      group_name = col["name"] 
      tex_color = ""
      
      if hex_color =~ /#(\w\w)(\w\w)(\w\w)/
        #
        er,ge,be = $1.hex,$2.hex,$3.hex
        #puts "#{er},#{ge},#{be}"
        hex_code = hex_color.gsub(/#/,'')
        
        tex_color = "\\definecolor{c#{hex_code}}{RGB}{#{er},#{ge},#{be}}"
      end
      puts tex_color
    }
  end

  #tikz figure   
  def export_legend_tex
    

    #ZedCoord
    zed_coord = ZedCoord.new(5, 6, 6, 4, 900, 110)
    
    puts "zed_coord: #{zed_coord.x},#{zed_coord.y}"
    
    
    rect_orig_x = 10
    rect_orig_y = 50
    rect_dim_x = 100
    rect_dim_y = 100
    
    text_orig_x = 130
    text_orig_y = 135
    
    
    Dir.chdir "#{@exp_dir}"
    
    #clean old
    ['tex','log','out','aux','pdf'].each {|ext|
      cmd = "rm -fr #{@legend_fname}.#{ext}"
      puts cmd; `#{cmd}`
      
    }
    
    tex = File.new(@legend_fname, "w")

    
    dim_min = 1950
    dim_max = 220
    
    font_size = 25
    font_line_space = (font_size * 1.2).to_i
  
    tex.puts '\documentclass{article}'
    # tex.puts '\usepackage[utf8]{inputenc}'
    tex.puts "\\usepackage[T1]{fontenc}"
    tex.puts
    tex.puts '\usepackage[vcentering,dvips,top=5mm, bottom=5mm, left=5mm, right=5mm]{geometry}'
    #double escape char on this line with parameters
    tex.puts "\\geometry{papersize={#{dim_min}px,#{dim_max}px}}"
    tex.puts '\pagestyle {empty}'
    tex.puts '\usepackage{tikz}'
    
    tex.puts "\\usepackage[scaled]{uarial}"
    tex.puts "\\renewcommand*\\familydefault{\\sfdefault} %% Only if the base font of the document is to be sans serif"
    #tex.puts '\usepackage{scalefnt}'
    
    tex.puts
    tex.puts '\begin{document}'
    tex.puts
    tex.puts "\\fontsize{#{font_size}}{#{font_line_space}}\\selectfont"
    
    #define tex colors
    @prok_group_colors[0..22].each {|col|
      hex_color = col["rgb_hex"]
      
      tex_color_def = tex_color_def(hex_color) 
      
      #tex.puts "% rect"
      tex.puts "#{tex_color_def}"
    
    }
    
    tex.puts '\definecolor{c808080}{RGB}{128,128,128}'
    tex.puts '\definecolor{cd3d3d3}{RGB}{211,211,211}'

    #tex.puts '{\scalefont{0.8}'
    tex.puts '\begin{tikzpicture}[y=0.80pt,x=0.80pt,yscale=-1, inner sep=0pt, outer sep=0pt]'
    tex.puts '\begin{scope}% layer1'
    tex.puts '\begin{scope}[cm={{0.42708228,0.0,0.0,0.42708228,(176.5208,186.74867)}}]% ranges_legend'
    
    tex.puts '% rect189'
    #tex.puts "\\path[fill=c808080,rounded corners=0.0000cm] (0.0000,0.0000) rectangle (200,20);"
    

    tex.puts '% text191'
    tex.puts "\\path (5,15) node[above right] (text191) { Prokaryotic families:       };"

    tex.puts '% rect193'
    tex.puts "\\path[fill=cd3d3d3,rounded corners=0.0000cm] (0,25) rectangle (5550,500);"

    
    @prok_group_colors[0..22].each {|col|
      hex_color = col["rgb_hex"]
      group_name = col["name"] 
      
      tex_color_code = tex_color_code(hex_color) 
      
      rect_x =  zed_coord.x + rect_orig_x 
      rect_y =  zed_coord.y + rect_orig_y 
      
      #puts "rect_x: #{rect_x}, rect_y: #{rect_y}"
      text_x =  zed_coord.x + text_orig_x 
      text_y =  zed_coord.y + text_orig_y 
      
      tex.puts "% rect"
      tex.puts "\\path[draw=black,fill=#{tex_color_code},rounded corners=0.0000cm] (#{rect_x},#{rect_y})"
      tex.puts "  rectangle (#{rect_x + rect_dim_x},#{rect_y + rect_dim_y});"

      tex.puts "% text"
      tex.puts "\\path (#{text_x},#{text_y}) node[above right] (text#{zed_coord.nb}) {#{group_name}};"
    
      zed_coord.inc
    }
    
    
    
    
    tex.puts '\end{scope}'
    tex.puts '\end{scope}'

    tex.puts '\end{tikzpicture}'
    #tex.puts '}'

    tex.puts '\end{document}'

    tex.close

    #compile pdfs
    cmd = "pdflatex #{@legend_fname}"
    puts cmd; `#{cmd}`
    #convert
    #cmd = "convert -density 300 #{@mt_base_name}.pdf -antialias #{@mt_base_name}.png"
    #puts cmd; `#{cmd}`
    
    #cleanup    
    # ['tex','log','out','aux'].each {|ext|
    #   cmd = "rm -fr #{@mt_base_name}.#{ext}"
    #   puts cmd; `#{cmd}`
    # }
    
   


  end
 
  
end
