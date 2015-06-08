module Bio
  #mixin for Tree class
  class Tree
    def output_rooted(tr,nroot,npred)
      res = ""
      c = tr.adjacent_nodes(nroot)
      c.delete(npred)
      if c.size() == 0 then
        #puts "leaf: #{nroot.inspect}, distance: #{tr.distance(nroot,npred)}"
        res += "#{nroot.name}:#{tr.distance(nroot,npred)}"
      else #2 children
        i = 0
        c.each {|n|
          i = i+1
          #puts "child: #{n.inspect}, distance: #{tr.distance(nroot,n)}, out_degree: #{tr.out_degree(n)}"
          if i==1
            #res += "(#{n.name}:#{tr.distance(nroot,n)},"
            res += "(#{output_rooted(tr,n,nroot)},"
          else
            res += "#{output_rooted(tr,n,nroot)}):#{tr.distance(nroot,npred)}"
          end

        }
      end
      return res
    end

    def output_unrooted()


      n3 = Bio::Tree::Node.new
      self.each_node {|n|
        puts "node: #{n.inspect}, out_degree: #{self.out_degree(n)}"
        if self.out_degree(n)==3
          n3=n
          break
        end

      }

      #3 sous arbres
      c = self.adjacent_nodes(n3)

      res = "("
      i=0
      c.each {|nadj|
        i=i+1
        #puts "sousarbre #{i}"
        res += output_rooted(self,nadj,n3)
        if i==3
          res += ");"
        else
          res += ","
        end
      }


      return res



    end

  end
end