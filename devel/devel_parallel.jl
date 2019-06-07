
using Distributed
using TimerOutputs

to = TimerOutput()

if nprocs() == 1
    addprocs(3)
end
# Number of logical CPU cores available in the system.
# println("CPU cores: ", Sys.CPU_CORES)
Sys.cpu_summary()
# Number of available processes.
# println("nprocs: ", nprocs())
# println("nworkers: ", nworkers())
println("nprocs: ", nprocs())
println("nworkers: ", nworkers())

function prepare_data(fib_parameter, n)
    input = rand(1:fib_parameter, n)
    return input
end

# The goal is make suma of fibonaci of every element of input array


@everywhere fib(n) = n < 2 ? n : fib(n-1) + fib(n-2)
# Ordinary for loop.
function forloop(input)
    a = 0
    for i = 1:length(input)
         a += fib(input[i]);
    end
    return a
end

function parallel_forloop(input)
    a = @distributed (+) for i = 1:length(input)
         fib(input[i]);
    end
    return a
end
function parallel_pmap(input)
    pout = pmap(fib, input)
    a = 0
    for i = 1:length(pout)
        a += pout[i]
    end
    return a
end

println("Warming")
input = prepare_data(10, 10)
@timeit to "warming" begin
    @timeit to "forloop" forloop(input)
    @timeit to "parallel forloop" parallel_forloop(input)
    @timeit to "parallel pmap" parallel_pmap(input)
end

println("---")
input = prepare_data(30, 10000)
@timeit to "10000" begin
    @timeit to "forloop" forloop(input)
    @timeit to "parallel forloop" parallel_forloop(input)
    @timeit to "parallel pmap" parallel_pmap(input)
end
input = prepare_data(55, 5)

@timeit to "5" begin
    @timeit to "forloop" forloop(input)
    @timeit to "parallel forloop" parallel_forloop(input)
    @timeit to "parallel pmap" parallel_pmap(input)
end


display(to)
# Parallel for loop
# @time @parallel (+) for i = 1:20000
# @time @distributed (+) for i = 1:n
#     Int(rand(Bool));
# end
#
# # Predefined function.
# @time sum(rand(0:1, n))
#
# # For a not so small amount of work:
# # n = 200000000;
# # n = 20000;
# # @time @parallel (+) for i = 1:n
# @time @distributed (+) for i = 1:n
#     Int(rand(Bool))
# end
#
# DO NOT run sum(rand(0:1, n)) or the ordinary for loop with 'n': You may run
# out of memory.
