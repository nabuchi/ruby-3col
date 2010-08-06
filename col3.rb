#!/usr/bin/ruby1.9 -Ku

require 'digest/sha1'

#12bitを想定
class Collision3
    #@@bitは4の倍数
=begin
    @@bit = 12
    @@pow2_N = 4096
    @@pow2_23N = 256
    @@pow2_13N = 16
=end
=begin
    @@bit = 16
    @@pow2_N = 65536
    @@pow2_23N = 1625
    @@pow2_13N = 40
=end
#=begin
    @@bit = 20
    @@pow2_N = 1048576
    @@pow2_23N = 10321
    @@pow2_13N = 102
#=end
=begin
    @@bit = 32
    @@pow2_N = 4294967296
    @@pow2_23N = 2642246
    @@pow2_13N = 1625
=end

   @@N_A = @@pow2_13N
    #@@N_A = 10
    @@N_R = @@pow2_13N
    #@@N_R = 10159
    @@N_B = @@pow2_23N
    #@@N_B = 103212
    @@startarr = 40-@@bit/4

    def initialize()
        @fortable2 = {}
        @table2 = {}
        @shacount = 0
        @allhash = {}
        @colcnt = {}
        @shacount2 = {}
        @count = 0
        #@mar = Marshal.load(File.open('dump.dat'))
    end
    attr_accessor :shacount,:shacount2
#private
    def sha32b(str, flag = true, moji = '')
        #puts moji unless moji == ''
        @shacount += 1 if flag
        @shacount2[moji] = 0 unless shacount2[moji]
        @shacount2[moji] += 1
        return Digest::SHA1.hexdigest(str)[@@startarr..39].hex
    end
=begin
    def sha32b(str, flag = true, moji = '')
        @shacount += 1 if flag
        @shacount2[moji] = 0 unless @shacount2[moji]
        @shacount2[moji] += 1
        return @mar[str.to_i]
    end
    def sha32b(str, flag = true)
        @shacount += 1 if flag
        return str.to_i + 1
    end
=end

#public
    def chkall
        (1..@@pow2_N).to_a.each do |i|
            h = sha32b("#{i}")
            @allhash[h] = 0 if !@allhash[h]
            @allhash[h] += 1
        end
    end
    #2コリジョンテーブルを作成するためにN_AxN_Rのテーブルを作成
    def makefortable2
        ret = @shacount
        i = 0
        while @fortable2.size < @@N_A && i += 1
            start = goal = rand(@@pow2_N)
            @@N_R.times do |j|
                goal = sha32b("#{goal}")
                @colcnt[goal] ? @colcnt[goal] +=1 : @colcnt[goal] = 1
                #print goal,','
            end
            #puts;puts
            @fortable2[goal] = start
        end
        @shacount - ret
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
        ret = @shacount
        while @table2.size < @@N_A
            rand = rand(@@pow2_N) 
            s1 = g1 = rand
            @@N_R.times do |i|
                g1 = sha32b("#{g1}",true, 'mk1')#とりあえずs1を一個進める
                s2 = @fortable2[g1]#tableに発見すればスタートをs2とする
                if s2
                    puts @count += 1
                    #s2とs1を同じ位置にセットする
                    (@@N_R-i-1).times do |j| 
                        s2 = sha32b("#{s2}",true,'set')
                    end
                    #s2とs1が違う値ならコリジョンしたとみなしてよい
                    if s1 != s2 
                        s1next = sha32b("#{s1}",true,'s1n')
                        s2next = sha32b("#{s2}",true,'s2n')
                        #前の値は同じことがわかっていて,nextの値がだぶったら前の値2つがコリジョン
                        while s1next != s2next
                            s1 = s1next
                            s2 = s2next 
                            s1next = sha32b("#{s1}",true,'cols1n')
                            s2next = sha32b("#{s2}",true,'cols2n')
                        end
                        while @table2[s1next]
                            s1next = s1next.succ
                            #p s1next
                            puts 'aa'
                        end
                        @table2[s1next] = [s1,s2]
                        #puts "ssss",s1,s2,sha32b("#{s1}"),sha32b("#{s2}"),"gggg"
                        break#この先g1を発生させても希望が持てないので次の乱数を作成する
                    end
                end
            end
        end
        @shacount - ret
    end

    #2コリジョンテーブルから3コリジョンを見つける
    def search3col
        ret = @shacount
       (@@N_B+10000).times do |i|
            s = rand(@@pow2_N)
            g = sha32b("#{s}",true,'bb')
            arr2 = @table2[g]
            if arr2
                if arr2[0] != s && arr2[1] != s
                    #puts "=ssss=",arr2[0],arr2[1],s,sha32b("#{arr2[0]}"),sha32b("#{arr2[1]}"),sha32b("#{s}"),"=gggg="
                    #puts "shacountは", @shacount
                    return @shacount - ret
                end
            end

        end
        @shacount - ret
    end
    def putcolcnt
        puts @colcnt.size
        print "wariai:",@colcnt.size.to_f/(@@N_A*@@N_R).to_f, "\n"
    end

    def watchall
        chkall
        @allhash.sort.each do |k,v|
            print k,':',v,"\n"
        end
        puts
        puts @allhash.size
        puts
    end
end

1.times do |p|
    col3 = Collision3.new
    puts col3.makefortable2
    puts col3.maketable2
    puts col3.search3col
    puts col3.shacount
   puts col3.shacount2
    #col3.putcolcnt
    #col3.watchall
end
