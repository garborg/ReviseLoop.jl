println(ENV["JULIA_REVISE"])

using Revise

using ReviseLoop

using Test

function revise_now()
    println("revising")
    Revise.revise()
    println("revised")
end

function revise_on_call(f)
    return function(args...; kwargs...)
        revise_now()
        # invokelatest to get around world age issue (world age set previous to revise call)
        Base.invokelatest(f, args...; kwargs...)
    end
end

atexit(() -> edit_pos_num(1))

@assert more_than(1) == 2
edit_pos_num(2)

@test more_than(1) == 2
revise_now()
if isinteractive()
    @test more_than(1) == 3
else
    @test more_than(1) == 2
    @test Base.invokelatest(more_than, 1) == 3 # failing if !isinteractive()
end

rmt = revise_on_call(more_than)

@test rmt(1) == 3 # failing if !isinteractive()
edit_pos_num(3)
@test rmt(1) == 4 # failing if !isinteractive()

# looper(rmt) # output updates when source is edited
