
using Distributed
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

n = 20000000
# Ordinary for loop.
let
    global sum1
    sum1 = 0
    @time for i = 1:n
         sum1 += Int(rand(Bool));
    end
end

# Parallel for loop
# @time @parallel (+) for i = 1:20000
@time sum2 = @distributed (+) for i = 1:n
    Int(rand(Bool));
end

# Predefined function.
@time sum3 =sum(rand(0:1, n))

# For a not so small amount of work:
# n = 200000000;
# n = 20000;
# @time @parallel (+) for i = 1:n
@time sum4 = @distributed (+) for i = 1:n
    Int(rand(Bool))
end

# println(sum1)
# println(sum2)
# println(sum3)
# println(sum4)

# DO NOT run sum(rand(0:1, n)) or the ordinary for loop with 'n': You may run
# out of memory.
