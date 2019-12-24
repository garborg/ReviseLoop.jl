println(ENV["JULIA_REVISE"])

using Revise

using ReviseLoop

using Test

# These do not influence the outcome, I just tried adding them on a lark
pre_sleep = get(ENV, "pre_sleep", nothing) !== nothing
post_sleep = get(ENV, "post_sleep", nothing) !== nothing

function revise_now()
    pre_sleep && sleep(5)
    println("revising")
    Revise.revise()
    println("revised")
    post_sleep && sleep(5)
end

function more_than_revisable(x)
    revise_now()
    # n.b. new version of `more_than` doesn't get called until second revise call
    more_than(x)
end

function revisable(f)
    return function(args...; kwargs...)
        revise_now()
        # n.b. new version of `f` doesn't get called until second revise call here, either
        f(args...; kwargs...)
    end
end

atexit(() -> edit_pos_num(1))

n = more_than(1)

@test n - 1 != 2
edit_pos_num(2)

@test more_than(1) == n
revise_now()
@test more_than(1) == 3 # Issue '1': fails when run as script, running rest in repl

rmt = revisable(more_than)

@test rmt(1) == 3
edit_pos_num(3)

# Issue '2a'
@test rmt(1) == 3 # stale
@test rmt(1) == 4 # delayed update

@test more_than_revisable(1) == 4
edit_pos_num(4)

# Issue '2b'
@test more_than_revisable(1) == 4 # stale
@test more_than_revisable(1) == 5 # delayed update
