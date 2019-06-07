using Debugger

println("hello")
function hhh(uio)
    println("hhh in ")

    println(uio + 5)
    retval = 4
    return retval
end

# this line will run debugger in console
# @enter hhh(4)

# this line  should be called from REPL
# Juno.@enter hhh(4)
