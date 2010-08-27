#!/usr/bin/ruby

require 'digest/sha1'

class Gnuplot
    def initialize
        @x = []
        @data = []
    end
    def plot
        @plot = Thread.new do
        Gnuplot.open do |gp|
        while true
        #Thread.stop
        Gnuplot::Plot.new(gp) do |plot|
            plot.title "test"
            plot.xlabel "x"
            plot.ylabel "y"

            @x = [1,2,3,4,5]
            @data = [[1,2],[2,4],[3,6]]

            @data.transpose.each do |dataset|
                plot.data << Gnuplot::DataSet.new([@x,dataset]) do |ds|
                    ds.with = "linespoints"
                    ds.notitle
                end
            end
        end
        sleep 100
        end
        end
        end
    end
    def adddata(x,dataarray)
        @x << x
        @data << dataarray
#@plot.run
    end
end
g = Gnuplot.new
g.plot
g.adddata(1,[2])
sleep 100

class Col3Bit
    attr_accessor :bit,:na,:nb,:nr,:keyzone,:st
    def initialize(bit)
        @bit = bit
        @na,@nb,@nr,@keyzone,@st = makeparameter(bit)
    end
    def makeparameter(bit)
        if bit%4 != 0
            raise 'bit%4 shuld be 0'
        end
        st=bit/4
        keyzonem = 2**bit
        puts "keyzone=#{keyzonem}"
        printf("keyzone?[#{keyzonem.round}]:")
        keyzone = STDIN.gets.chomp
        keyzone = keyzonem.round if keyzone == ''

        nam = keyzone**(1/3.0)
        puts "na=#{nam}"
        printf("na?[#{nam.round}]:")
        na = STDIN.gets.chomp
        na = nam.round if na == ''

        nbm = keyzone**(2/3.0)
        puts "nb=#{nbm}"
        printf("nb?[#{nbm.round}]:")
        nb = STDIN.gets.chomp
        nb = nbm.round if nb == ''

        nrm = keyzone**(1/3.0)
        puts "nr=#{nrm}"
        printf("nr?[#{nrm.round}]:")
        nr = STDIN.gets.chomp
        nr = nrm.round if nr == ''

        p na,nb,nr,keyzone

        return na,nb,nr,keyzone,st
    end
end

class Col3Base
    attr_accessor :shacount
    def initialize(bit)
        @fortable2 = {}
        @table2 = {}
        @shacount = {}
        @bit = Col3Bit.new(bit)
        p @bit
    end
    def sha32b(str,spec=:others)
        unless @shacount[spec] then @shacount[spec] = 0 end
        @shacount[spec] += 1
        Digest::SHA1.hexdigest(str)[-@bit.st..-1].hex
    end
    #2コリジョンテーブルを作成するためにN_AxN_Rのテーブルを作成
    def makefortable2
        while @fortable2.size < @bit.na
            start = goal = rand(@bit.keyzone)
            @bit.nr.times do |i|
                goal = sha32b(goal.to_s,:mkf2)
            end
            @fortable2[goal] = start
        end
    end
    #2コリジョンテーブルの作成
    def maketable2
        while @table2.size < @bit.na
            s1 = g1 = rand(@bit.keyzone)
            @bit.nr.times do |i|
                g1 = sha32b(g1.to_s,:mk2_1)#とりあえずs1を一個進める
                s2 = @fortable2[g1]#tableに発見すればスタートをs2とする
                if s2
                    #s2とs1を同じ位置にセットする
                    (@bit.nr-i-1).times do |j| 
                        s2 = sha32b(s2.to_s,:mk2_2)
                    end
                    #s2とs1が違う値ならコリジョンしたとみなしてよい
                    if s1 != s2 
                        s1next = sha32b(s1.to_s,:mk2_3)
                        s2next = sha32b(s2.to_s,:mk2_3)
                        #前の値は同じことがわかっていて,nextの値がだぶったら前の値2つがコリジョン
                        while s1next != s2next
                            s1 = s1next
                            s2 = s2next 
                            s1next = sha32b(s1.to_s,:mk2_4)
                            s2next = sha32b(s2.to_s,:mk2_4)
                        end
                        @table2[s1next] = [s1,s2]
                        #puts "s1:#{s1},s2:#{s2},sha(s1):#{sha32b(s1.to_s)},sha(s2):#{sha32b(s2.to_s)}"
                        break#この先g1を発生させても希望が持てないので次の乱数を作成する
                    end
                end
            end
        end
    end

    #2コリジョンテーブルから3コリジョンを見つける
    def search3col
        while true#almost @bit.nb
            s = rand(@bit.keyzone)
            g = sha32b(s.to_s,:s3)
            arr2 = @table2[g]
            if arr2
                if arr2[0] != s && arr2[1] != s
                    ret = "s0:#{arr2[0]},s1:#{arr2[1]},s2:#{s},sha(s0):#{sha32b(arr2[0].to_s)}"\
                            ",sha(s1):#{sha32b(arr2[1].to_s)},sha(s2):#{sha32b(s.to_s)}"
                    puts ret
                    return ret
                end
            end
        end
    end
end

c3 = Col3Base.new(20)
puts 'mk2'
c3.makefortable2
puts 'mt2'
c3.maketable2
puts 's3'
c3.search3col
puts c3.shacount
