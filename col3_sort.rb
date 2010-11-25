#!/usr/bin/ruby

require 'digest/sha1'

@bit = 28
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
#@uniq = {}
    @fortable2 = []
    tmp = 0
    while @fortable2.size < @na
        start = goal = rand(@n)
        @nr.times do |i|
#@uniq[goal] = 1
            goal = sha32b(goal.to_s,:step1)
        end
#if @fortable2[goal] then puts "exists(step1)" end
        @fortable2.push([goal,start])
#tmp = goal
#puts start,goal
    end
    #require 'pp'
    #pp @fortable2.sort!
#p @fortable2.assoc(goal)
#puts @uniq.size/(@na*@nr).to_f
end
#2コリジョンテーブルの作成
def maketable2
    @aloop = 0
    @hitcount = 0
    @table2 = []
    while @table2.size < @na
        @aloop += 1
        s1 = g1 = rand(@n)
        @nr.times do |i|
            g1 = sha32b(g1.to_s,:step2)#とりあえずs1を一個進める
            s2 = @fortable2.assoc(g1)#tableに発見すればスタートをs2とする
            if s2
                s2 = s2[1]
#if s2.size < 2 then pp s2,g1,@fortable2 end
#p s2
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
                    #if @table2[s1next] then puts 'exists' end
                    @hitcount += 1
                    @table2.push([s1next,s1,s2])
                    #puts "s1:#{s1},s2:#{s2},sha(s1):#{sha32b(s1.to_s)},sha(s2):#{sha32b(s2.to_s)}"
                    break#この先g1を発生させても希望が持てないので次の乱数を作成する
                end
            end
        end
    end
    #puts 'loop',@aloop,@hitcount
end

#2コリジョンテーブルから3コリジョンを見つける
def search3col
    while true#almost @bit.nb
        s = rand(@n)
        g = sha32b(s.to_s,:step3)
        arr2 = @table2.assoc(g)
        if arr2
            arr2 = arr2[1,2]
            #p arr2
            if arr2[0] != s && arr2[1] != s
                ret = "s0:#{arr2[0]},s1:#{arr2[1]},s2:#{s},sha(s0):#{sha32b(arr2[0].to_s)}"\
                        ",sha(s1):#{sha32b(arr2[1].to_s)},sha(s2):#{sha32b(s.to_s)}"
                #puts ret
                return ret
            end
        end
    end
end

avg = []
3.times do |i|
    @fortable2 = []
    @table2 = []
    @shacount = {}
    makefortable2
    maketable2
    search3col
    cs = @shacount
    avg.push(cs[:step2])
    puts "#{i} #{cs[:step1]} #{cs[:step2]} #{cs[:step3]}"
end
puts avg.inject(0.0){|r,i| r+=i.to_i}/avg.size
