#!/usr/bin/env ruby

bit=36
n=2**bit
na=2**(bit*1/3.0)
nar=2**(bit*2/3.0)


sum = 1
(na.to_i-1).times do |k|
    sum = sum*(n-0.70*(nar-k*na))/n.to_f
end

puts na*2*na+na*na*sum/(1-sum)
puts 2+sum/(1-sum)
