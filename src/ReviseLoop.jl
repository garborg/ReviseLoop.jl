module ReviseLoop

using Dates

export edit_pos_num, more_than, looper

@noinline function more_than(x)
    pos_num = 1
    x + pos_num
end

function looper(f)
    while true
        sleep(5)
        i = rand(1:9)
        println((Dates.now(), i => f(i)))
    end
end

function edit_pos_num(n)
    open(@__FILE__, "r+") do io
        s = read(io, String)
        ns = replace(s, r"(\s+pos_num =) \d+"m => SubstitutionString("\\1 $n"))
        seekstart(io)
        write(io, ns)
    end
end

end # module
