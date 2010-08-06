#!/usr/bin/ruby

require 'digest/sha1'

class Collision3
=begin
    @@bit = 12
    @@pow2_N = 4096
    @@pow2_23N = 256
    @@pow2_13N = 16
=end

    @@bit = 16
    @@pow2_N = 65536
    @@pow2_23N = 1629
    @@pow2_13N = 40

    @@bit = 20
    @@pow2_N =
    @@pow2_23N = 
    @@pow2_13N =

=begin
    @@bit = 32
    @@pow2_N = 4294967296
    @@pow2_23N = 2654484
    @@pow2_13N = 1629
=end

    @@N_A = @@pow2_13N
    @@N_R = @@pow2_13N
    @@N_B = @@pow2_23N
    @@startarr = 40-@@bit/4+1

    def initialize()
        @fortable2 = {}
        @table2 = {}
        @shacount = 0
        @colcnt = {}
    end
    attr_accessor :shacount
private
    def sha32b(str, flag = true)
        @shacount += 1 if flag
        return Digest::SHA1.hexdigest(str)[@@startarr..40].hex
    end

public
    #2コリジョンテーブルを作成するためにN_AxN_Rのテーブルを作成
    def makefortable2
        i = 0
        while @fortable2.size < @@N_A && i += 1
            start = goal = rand(@@pow2_N)
            @@N_R.times do |j|
                goal = sha32b("#{goal}")
                @colcnt[goal] ? @colcnt[goal] += 1 : @colcnt[goal] = 1
            end
            @fortable2[goal] = start
        end
    end

    #ランダムマップを用いてN_AxN_Rのテーブルを作成
    class Anchor
        def initialize()
            @next = nil#次のAnchor
            @data = 0#値
            @dist = 0#距離
        end
    end
    def rmaptable
          
    end

    #2コリジョンテーブルの作成
    def maketable2
        while @table2.size < @@N_A
            rand = rand(@@pow2_N) 
            s1 = g1 = rand
            @@N_R.times do |i|
                g1 = sha32b("#{g1}",true)#とりあえずs1を一個進める
                s2 = @fortable2[g1]#tableに発見すればスタートをs2とする
                if s2
                    #s2とs1を同じ位置にセットする
                    (@@N_R-i-1).times do |j| 
                        s2 = sha32b("#{s2}")
                    end
                    #s2とs1が違う値ならコリジョンしたとみなしてよい
                    if s1 != s2 
                        s1next = sha32b("#{s1}")
                        s2next = sha32b("#{s2}")
                        #前の値は同じことがわかっていて,nextの値がだぶったら前の値2つがコリジョン
                        while s1next != s2next
                            s1 = s1next
                            s2 = s2next 
                            s1next = sha32b("#{s1}")
                            s2next = sha32b("#{s2}")
                        end
                        @table2[s1next] = [s1,s2]
                        #puts "ssss",s1,s2,sha32b("#{s1}"),sha32b("#{s2}"),"gggg"
                        break#この先g1を発生させても希望が持てないので次の乱数を作成する
                    end
                end
            end
        end
    end

    #2コリジョンテーブルから3コリジョンを見つける
    def search3col
        @@N_B.times do |i|
            s = rand(@@pow2_N)
            g = sha32b("#{s}")
            arr2 = @table2[g]
            if arr2
                if arr2[0] != s && arr2[1] != s
                    #puts "=ssss=",arr2[0],arr2[1],s,sha32b("#{arr2[0]}"),sha32b("#{arr2[1]}"),sha32b("#{s}"),"=gggg="
                    #puts "shacountは", @shacount
                    return 0
                end
            end

        end
    end
    def putcolcnt
        print "wariai:",@colcnt.size.to_f/(@@N_A*@@N_R).to_f, "\n"
    end
end

1.times do |p|
col3 = Collision3.new
sc = []
col3.makefortable2
sc[1] =  col3.shacount
puts sc[1] - 0
col3.maketable2
sc[2] = col3.shacount
puts sc[2] - sc[1]
col3.search3col
sc[3] = col3.shacount
puts sc[3] - sc[2]
puts col3.shacount
col3.putcolcnt
end

