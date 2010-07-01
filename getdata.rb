#!/usr/bin/ruby1.9 -Ku

lines = 0
step1 = File.open("step1.dat","w")
step2 = File.open("step2.dat","w")
step3 = File.open("step3.dat","w")
all = File.open("all.dat","w")
open("data_all.dat") {|file|
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
