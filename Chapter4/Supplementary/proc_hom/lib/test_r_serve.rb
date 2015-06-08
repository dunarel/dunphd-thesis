# To change this template, choose Tools | Templates
# and open the template in the editor.

puts "Hello World"
require 'rserve'
con=Rserve::Connection.new

# Evaluation retrieves a <tt>Rserve::REXP</tt> object
cmd = "source(\"/root/devel/proc_hom/files/statet/workspace/gaussian_kernel/transfers_density.R\")"
con.void_eval(cmd)

cmd = "dens_plot_r(\"/root/devel/proc_hom/files/statet/workspace/gaussian_kernel/from_ruby_plot.pdf\")"
con.void_eval(cmd)




=begin
x = con.eval('x<-rnorm(1)')
#=> #<Rserve::REXP::Double:0x000000010a81f0 @payload=[(4807469545488851/9007199254740992)], @attr=nil>

# You could use specific methods to retrieve ruby objects
puts "x.as_doubles:#{x.as_doubles}" # => [0.533736337958596]
x.as_strings #=> ["0.533736337958596"]

# Every Rserve::REXP could be converted to Ruby objects using
# method <tt>to_ruby</tt>
x.to_ruby #=> (4807469545488851/9007199254740992)

# The API could manage complex recursive list

x=con.eval('list(l1=list(c(2,3)),l2=c(1,2,3))').to_ruby
#=> #<Array:19590368 [#<Array:19590116 [[(2/1), (3/1)]] names:nil>, [(1/1), (2/1), (3/1)]] names:["l1", "l2"]>

# You could assign a REXP to R variables

con.assign("x", Rserve::REXP::Double.new([1.5,2.3,5]))
#=> #<Rserve::Packet:0x0000000136b068 @cmd=65537, @cont=nil>
con.eval("x")
#=> #<Rserve::REXP::Double:0x0000000134e770 @payload=[(3/2), (2589569785738035/1125899906842624), (5/1)], @attr=nil>

# Rserve::REXP::Wrapper.wrap allows you to transform Ruby object to
# REXP, could be assigned to R variables

Rserve::REXP::Wrapper.wrap(["a","b",["c","d"]])

#=> #<Rserve::REXP::GenericVector:0x000000010c81d0 @attr=nil, @payload=#<Rserve::Rlist:0x000000010c8278 @names=nil, @data=[#<Rserve::REXP::String:0x000000010c86d8 @payload=["a"], @attr=nil>, #<Rserve::REXP::String:0x000000010c85c0 @payload=["b"], @attr=nil>, #<Rserve::REXP::String:0x000000010c82e8 @payload=["c", "d"], @attr=nil>]>>
=end