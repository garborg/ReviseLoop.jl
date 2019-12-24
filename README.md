# ReviseLoop

I'm having issues getting [Revise.jl](https://github.com/timholy/Revise.jl) processing/propogating changes in my package code in the case where my function is passed to another package's function, which basically runs my function on loop.

My initial solution was to pass in a wrapper function e.g.

```julia
# Revise set to "manual" update mode
function wrapped(x)
    Revise.revise()
    wrapped_fun(x)
end

ThirdParty.looper(wrapped)
```

In looking at why that didn't work, I hit the testcases in this standalone example, which I think are at the root of my misunderstanding of Revise.

Running `JULIA_REVISE=manual JULIA_PROJECT="@." julia src/script.jl` (once env has been `Pkg.instantiate`d) hits [Issue '1' (line 44)](https://github.com/garborg/ReviseLoop.jl/blob/e417d2f9d5522b95d06ba552fbdc5237359911e5/src/script.jl#L44): revision happens if code is pasted into repl but fails when run as script.

Pasting the same into the repl (`JULIA_REVISE=manual JULIA_PROJECT="@." julia src/script.jl`), hits [Issue '2'(duplicated on lines 51 and 58 out of paranoia)](https://github.com/garborg/ReviseLoop.jl/blob/e417d2f9d5522b95d06ba552fbdc5237359911e5/src/script.jl#L51-L60): revised code doesn't kick in until after the second call (tested only in repl, beause Issue '1').

I'd love any explanation on why this is happening, and how I should change my approach.
