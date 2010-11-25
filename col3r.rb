#!/usr/bin/ruby

require 'digest/sha1'

@bit = 20
if @bit%4!=0
    raise('bit error')
end
@st = @bit/4
@n = 2**@bit
@na = (@n**(1/3.0)).to_i
@nr = (@n**(1/3.0)).to_i

def sha32b(str,spec=:others)
    unless @shacount[spec] then @shacount[spec] = 0 end
    @shacount[spec] += 1
    Digest::SHA1.hexdigest(str)[-@st..-1].hex
end
#2コリジョンテーブルを作成するためにN_AxN_Rのテーブルを作成
def makefortable2
    while @fortable2.size < @na
        start = goal = rand(@n)
        @nr.times do |i|
            goal = sha32b(goal.to_s,:step1)
        end
        @fortable2[goal] = start
    end
end
#2コリジョンテーブルの作成
def maketable2
    while @table2.size < @na
        s1 = g1 = rand(@n)
        @nr.times do |i|
            g1 = sha32b(g1.to_s,:step2)#とりあえずs1を一個進める
            s2 = @fortable2[g1]#tableに発見すればスタートをs2とする
            if s2
                #s2とs1を同じ位置にセットする
                (@nr-i-1).times do |j| 
                    s2 = sha32b(s2.to_s,:step2)
                end
                #s2とs1が違う値ならコリジョンしたとみなしてよい
                if s1 != s2 
                    s1next = sha32b(s1.to_s,:step2)
                    s2next = sha32b(s2.to_s,:step2)
                    #前の値は同じことがわかっていて,nextの値がだぶったら前の値2つがコリジョン
                    while s1next != s2next
                        s1 = s1next
                        s2 = s2next 
                        s1next = sha32b(s1.to_s,:step2)
                        s2next = sha32b(s2.to_s,:step2)
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
        s = rand(@n)
        g = sha32b(s.to_s,:step3)
        arr2 = @table2[g]
        if arr2
            if arr2[0] != s && arr2[1] != s
                ret = "s0:#{arr2[0]},s1:#{arr2[1]},s2:#{s},sha(s0):#{sha32b(arr2[0].to_s)}"\
                        ",sha(s1):#{sha32b(arr2[1].to_s)},sha(s2):#{sha32b(s.to_s)}"
                #puts ret
                return ret
            end
        end
    end
end

10.times do |i|
    @fortable2 = {}
    @table2 = {}
    @shacount = {}
    makefortable2
    maketable2
    search3col
    cs = @shacount
    puts "#{i} #{cs[:step1]} #{cs[:step2]} #{cs[:step3]}"
end
