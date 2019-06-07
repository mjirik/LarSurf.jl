
using Distributed
using TimerOutputs
using SparseArrays

to = TimerOutput()

if nprocs() == 1
    addprocs(3)
end
# Number of logical CPU cores available in the system.
# println("CPU cores: ", Sys.CPU_CORES)
# Number of available processes.
# Sys.cpu_summary()
println("nprocs: ", nprocs())
println("nworkers: ", nworkers())
println("positive numbers are the faces, negative is the end of block")

@everywhere fib(n) = n < 2 ? n : fib(n-1) + fib(n-2)


ch = RemoteChannel(()->Channel{Int}(32));
@everywhere function process_block(channel, i)
    print(".")
    for j=1:rand(1:4)
        # simulate extracting usefull faces from the brick
        sleep(rand())
        # fib(rand(10:40))
        put!(channel, i*10 + j)
    end
    put!(channel, -i)
end

number_of_blocks = 10

@distributed for i = 1:number_of_blocks
    process_block(ch, i)
end


Fchar = spzeros(Int64, 1000)
# Read all the values
n = 0
while n < number_of_blocks
    global n
    val = take!(ch)
    print("$val ")
    if val < 0
        n += 1
    else
        Fchar[val] = 1
    end
end
