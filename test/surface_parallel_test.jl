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
@everywhere using Distributed

@testset "Init parallel surface computation" begin
    block_size = [8, 8, 8]
    LarSurf.lsp_setup(block_size)
    for wid in workers()
        println("testing on $wid")
        ftr = @spawnat wid LarSurf._single_boundary3
        @test fetch(ftr) != nothing
    end

    segmentation = LarSurf.data234()
    LarSurf.lsp_job_enquing(segmentation)


end

# @testset "Job enquing parallel surface computation" begin
#     block_size = [8, 8, 8]
#     LarSurf.lsp_job_enquing(block_size)
#

    # for wid in workers()
    #     println("testing on $wid")
    #     ftr = @spawnat wid LarSurf._single_boundary3
    #     @test fetch(ftr) != nothing
    # end


# end
