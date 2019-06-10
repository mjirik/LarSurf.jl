#=
surface_test:
- Julia version: 1.1.0
- Author: Jirik
- Date: 2019-03-19
=#
using Distributed
if nprocs() == 1
    addprocs(3)
end
using Revise
using Test
using Logging
using SparseArrays
@everywhere using LarSurf

@testset "Init parallel surface computation" begin
    block_size = [8, 8, 8]
    LarSurf.surf_init(block_size)

end
