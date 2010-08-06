#!/usr/bin/ruby
require 'set'

class Risou
    @@kazu = 1048576
    def initialize()
        @shuffle = (1..@@kazu).to_a.sort_by{rand}
        @risou = {}
    end
    attr_accessor :risou,:shuffle

    def makerisou
        start = @shuffle.shift
        seed = start
        @shuffle.each do |i|
            @risou[seed] = i
            seed = i
        end
        @risou[seed] = start
        puts @risou.size
    end
end
r = Risou.new
r.makerisou
Marshal.dump(r.risou,File.open('dump.dat','w'))
