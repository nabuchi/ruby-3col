#!/usr/bin/env ruby

require 'digest/sha1'

def sha32a(str)
    return str.to_s.crypt('aa')[2..13]
end
def sha32d(str)
    return sha32a(sha32a(str))
end
puts 'JGqODal/EdI'.crypt('aa')
puts 'JGqODal/HBE'.crypt('aa')
__END__
seed = 'aaa'
normal = sha32a(seed)
double = sha32d(seed)
while normal != double
    normal = sha32a(normal)
    double = sha32d(double)
end
puts normal,double
while normal != seed
    seed2 = seed
    normal2 = normal
    seed = sha32a(seed)
    normal = sha32a(normal)
end
puts seed,normal
puts '---'
puts "#{seed2}&#{normal2}collision to #{sha32a(seed2)},#{sha32a(normal2)}"
