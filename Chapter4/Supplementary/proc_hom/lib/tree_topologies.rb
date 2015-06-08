# To change this template, choose Tools | Templates
# and open the template in the editor.


def topologies(n, cache = {})
  cache[n] =
    n == 0 ? 1 : (0..n-1).inject(0){ |sum, i| \
      sum + topologies(i, cache) * topologies(n-i-1, cache) } unless cache.has_key? n
  cache[n]
end

x = topologies(12)
puts "x: #{x}"
