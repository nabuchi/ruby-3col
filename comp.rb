#!/usr/bin/env ruby

@bit = 20
@n = 2**@bit
@a = 1/3.0
@r = 1/3.0

def calcpi
    ret = 1
    nr.times do |i|
        ret *= (@n-na*nr+i*na)/@n.to_f
    end
    return ret
end

def calccomp
    return na*2*nr+(calcpi/(1-calcpi))*na*nr
end

def allcomp
    return calccomp + na*nr + nb
end
def na
    return (@n**(@a)).to_i
end
def nr
    return (@n**(@r)).to_i
end
def nb
    return (@n**(1-@a)).to_i
end
def nanr
    return na*nr
end

#puts calccomp,allcomp

@a = 0.15
while @a < 1
    @r = 2/3.0- @a
    puts "#{@a}\t#{allcomp.to_i}"
    @a += 0.01
end
__END__
(1..@nanr).each do |na|
    puts "#{@na},#{@nr},#{calcpi}"
end
