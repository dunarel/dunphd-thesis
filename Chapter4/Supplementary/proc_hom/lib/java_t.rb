# This is the 'magical Java require line'.
require 'java'
require 'commons-lang3-3.1.jar'

JavaRange = org.apache.commons.lang3.Range

    
   rng_b = JavaRange.between(1.to_java,5.to_java)
   rng_a = JavaRange.between(7.to_java,25.to_java)

   connect_frag = false
   epsilon_frag = 5   

    if rng_a.is_overlapped_by(rng_b)
      #connect overlapping fragments
      connect_frag = true
      puts "rng_a: #{rng_a}, ----- intersection ---- #{rng_a.intersection_with(rng_b)} ----  rng_b: #{rng_b} "
    elsif rng_a.is_before_range(rng_b)
      dist = rng_b.get_minimum() - rng_a.get_maximum()
      connect_frag = true if dist <= epsilon_frag
      puts "rng_a: #{rng_a}, ----before ---dist: #{dist} ----  rng_b: #{rng_b} "

    elsif rng_a.is_after_range(rng_b)
      dist = rng_a.get_minimum() - rng_b.get_maximum()
      connect_frag = true if dist <= epsilon_frag
      puts "rng_a: #{rng_a}, ----after ---dist: #{dist} ----  rng_b: #{rng_b} "

    end

    puts "connected: #{connect_frag}"

