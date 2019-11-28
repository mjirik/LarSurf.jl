#=
surface_test:
- Julia version: 1.1.0
- Author: Jirik
- Date: 2019-03-19
=#
# # using Revise
using Test
using Logging
using SparseArrays
using Distributed
if nprocs() == 1
    addprocs(3)
end

using LarSurf
# using Plasm
# using LinearAlgebraicRepresentation
# Lar = LinearAlgebraicRepresentation

# TODO repair this test
@testset "Get Fchar test" begin

    println("generate data")
    segmentation = LarSurf.data234()
    block_size = [2,2,2]
    # Flin2 = __grid_get_surface_Fchar_per_block_parallel_pmap(segmentation, block_size)

end
