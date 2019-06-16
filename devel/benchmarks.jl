using BenchmarkTools
x = 1
@benchmark if (x == 1) 0 else 1 end
# BenchmarkTools.Trial:
#   memory estimate:  0 bytes
#   allocs estimate:  0
#   --------------
#   minimum time:     13.090 ns (0.00% GC)
#   median time:      14.061 ns (0.00% GC)
#   mean time:        15.288 ns (0.00% GC)
#   maximum time:     126.545 ns (0.00% GC)
#   --------------
#   samples:          10000
#   evals/sample:     1000
#

@benchmark (x + 1) % 2
# BenchmarkTools.Trial:
#   memory estimate:  0 bytes
#   allocs estimate:  0
#   --------------
#   minimum time:     28.121 ns (0.00% GC)
#   median time:      31.515 ns (0.00% GC)
#   mean time:        33.316 ns (0.00% GC)
#   maximum time:     152.727 ns (0.00% GC)
#   --------------
#   samples:          10000
#   evals/sample:     1000
