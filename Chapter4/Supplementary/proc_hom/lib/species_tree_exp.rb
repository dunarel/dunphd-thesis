require 'rubygems'
require 'bio'
require 'msa_tools'


class SpeciesTreeExp
  def initialize
    
    @tr_tid_exp_fname = "#{AppConfig.files_other_dir}/tr_tid_exp.phy"
    @tr_tid_exp_mod_fname = "#{AppConfig.files_other_dir}/tr_tid_exp_mod.phy"
    @tr_tid_exp_mod1_fname = "#{AppConfig.files_other_dir}/tr_tid_exp_mod1.phy"
    
    @ud = UqamDoc::Parsers.new
    
    @conn = ActiveRecord::Base.connection
    #connection for direct JDBC
    @jdbc_conn=@conn.jdbc_connection
    
    
  end
  
  def load_initial_tree
    str = @ud.get_file_as_string(@tr_tid_exp_fname)
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
    tnode = @t0.get_node_by_name("root")
    @t0.remove_node(tnode)
   
    @t0.root= @t0.get_node_by_name("INT131567")
    
    #eliminate nodes
    ["INT131550","INT213849","INT29547","INT1236","INT91347"].each {|nn|
      n = @t0.get_node_by_name(nn)
      remove_internal_node(n)
      
    }
      
    
    
    #add OTHA
    n1 = @t0.get_node_by_name("INT2157")
    n2 = @t0.get_node_by_name("INT51967")
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
    n3 = @t0.get_node_by_name("INT40117")
    p = @t0.parent(n3) 
    @t0.remove_edge(p,n3)
    @t0.add_edge(n2,n3)
    
    n4 = @t0.get_node_by_name("INT142182")
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
    
    @ud.string_to_file(st, @tr_tid_exp_mod_fname)
    
    
  end
  
  def reload_mod_tree()
    
    str = @ud.get_file_as_string(@tr_tid_exp_mod_fname)
    #puts "tree: #{str}"


    @t1 = Bio::Newick.new(str, nil).tree
    
    
  end
  
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
      #puts "leaf: #{lf.name}"
      #p = @t0.parent(lf)
      id = lf.name
      sciname = Taxon.find(id).sci_name
      if sciname =~ /(.+):(.+)/
        puts "sciname: #{sciname}"
        sciname = "#{$1}_#{$2}"
        puts "sciname_mod: #{sciname}"
      end
      
      #corrected names (too long)
      corname = case id
      when "321314" then
        "Salmonella enterica serovar Choleraesuis str. SC-B67"
       else
         sciname
      end
     
      lf.name = corname
      #puts "id: #{id}, lf.name: #{lf.name}"
      
      
    }
    
  end
  
  
  
end
