using Revise
using BenchmarkTools
using LarSurf
using Statistics
using SparseArrays
# x = 1

# paper
# Calculation of lar model (141 ms on HP) is faster than reading LARmodel from
# file (923 ms on HP)

block_size = [16,16,16]
# block_size = [64,64,64]
# pure computation
LarSurf.set_param(larmodel_allow_memory=false, larmodel_allow_write_files=false; larmodel_allow_read_files=false)
bm = @benchmark LarSurf.get_larmodel(block_size)
println("Mean time: $(mean(bm.times) * 10^-9) [s]")
# mean time [16,16,16]
# 141 ms with JLD
# 124 with JLD2
# mean time [64,64,64]
# 20.67 s with JLD2

# calculate and write
LarSurf.set_param(larmodel_allow_memory=false, larmodel_allow_write_files=true; larmodel_allow_read_files=false)
bm = @benchmark LarSurf.get_larmodel(block_size)
println("Mean time: $(mean(bm.times) * 10^-9) [s]")
# mean time [16,16,16]
# 923 ms with JLD
# 130 with JLD2
# mean time [64,64,64]
# 21.92 s with JLD2

# just read
LarSurf.set_param(larmodel_allow_memory=false, larmodel_allow_write_files=false; larmodel_allow_read_files=true)
bm = @benchmark LarSurf.get_larmodel(block_size)
println("Mean time: $(mean(bm.times) * 10^-9) [s]")
# mean time [16,16,16]
# 983 ms with JLD
# 134 with JLD2
# mean time [64,64,64]
# 20.86 s with JLD2


# Pure computation
LarSurf.set_param(larmodel_allow_memory=false, larmodel_allow_write_files=false; larmodel_allow_read_files=false)
LarSurf.set_param(boundary_allow_memory=false, boundary_allow_write_files=false; boundary_allow_read_files=false)
bm = @benchmark LarSurf.get_boundary3(block_size, false)
println("Mean time: $(mean(bm.times) * 10^-9) [s]")
# mean 16
# 214 ms



# Computation and write
LarSurf.set_param(larmodel_allow_memory=false, larmodel_allow_write_files=false; larmodel_allow_read_files=false)
LarSurf.set_param(boundary_allow_memory=false, boundary_allow_write_files=true; boundary_allow_read_files=false)
bm = @benchmark LarSurf.get_boundary3(block_size, false)
println("Mean time: $(mean(bm.times) * 10^-9) [s]")
# mean 16
# 270 ms

# Computation and read
LarSurf.set_param(larmodel_allow_memory=false, larmodel_allow_write_files=false; larmodel_allow_read_files=false)
LarSurf.set_param(boundary_allow_memory=false, boundary_allow_write_files=false; boundary_allow_read_files=true)
bm = @benchmark LarSurf.get_boundary3(block_size, false)
println("Mean time: $(mean(bm.times) * 10^-9) [s]")
# mean 16
# 139 ms
#
