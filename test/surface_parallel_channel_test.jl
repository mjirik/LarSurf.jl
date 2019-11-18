#=
surface_test:
- Julia version: 1.1.0
- Author: Jirik
- Date: 2019-03-19
=#
using Revise
using Test
using Logging
using SparseArrays
using Distributed
if nprocs() == 1
    addprocs(3)
end

@everywhere using LarSurf
# using Plasm
# using LinearAlgebraicRepresentation
# Lar = LinearAlgebraicRepresentation

@testset "Get Fchar test" begin

    segmentation = LarSurf.data234()
    block_size = [2,2,2]
    ch = RemoteChannel(()->Channel{Int}(32));
    Flin2 = LarSurf.__grid_get_surface_Fchar_per_block_parallel_channel(segmentation, block_size, ch)
    # @test nnz(Flin2) == 6*4
    # println("get fchar test 5")

    # Flin1 = LarSurf.__grid_get_surface_Fchar(segmentation, block_size)
    # println("get fchar test 2")
    # Flin1 = LarSurf.__grid_get_surface_Fchar_per_block(segmentation, block_size)
    # @test nnz(Flin1) == 6*4
    #
    # println("get fchar test 3")
    # Flin2 = LarSurf.__grid_get_surface_Fchar_per_block_parallel_pmap(segmentation, block_size)
    # @test nnz(Flin2) == 6*4
    # println("get fchar test 4")
end
