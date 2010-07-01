#!/usr/bin/ruby -Ku

fname = ARGV.shift
fn = fname.sub(/\.\w+$/,'')

lines = 0
step1 = File.open("#{fn}-s1.dat","w")
step2 = File.open("#{fn}-s2.dat","w")
step3 = File.open("#{fn}-s3.dat","w")
all = File.open("#{fn}-all.dat","w")
open(fname) {|file|
    while l = file.gets
        lines += 1
        if lines%4 == 1
            step1.print lines/4,"\t",l
        elsif lines%4 == 2
            step2.print lines/4,"\t",l
        elsif lines%4 == 3
            step3.print lines/4,"\t",l
        elsif lines%4 == 0
            all.print lines/4,"\t",l
        end
    end
}
step1.close
step2.close
step3.close
all.close
