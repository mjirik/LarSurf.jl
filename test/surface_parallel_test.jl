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
# global_logger(SimpleLogger(stdout, Logging.Debug))
# # set logger on all workers
# for wid in workers()
#     @spawnat wid global_logger(SimpleLogger(stdout, Logging.Debug))
# end

@testset "Setup parallel surface computation" begin
    block_size = [2, 2, 2]
    LarSurf.lsp_setup(block_size)
    for wid in workers()
        # println("testing on $wid")
        ftr = @spawnat wid LarSurf._single_boundary3
        @test fetch(ftr) != nothing
    end
end

@testset "parallel surface extraction " begin
    block_size = [2, 2, 2]
    segmentation = LarSurf.data234()

    LarSurf.lsp_setup(block_size)
    # for wid in workers()
    #     # println("testing on $wid")
    #     ftr = @spawnat wid LarSurf._single_boundary3
    #     @test fetch(ftr) != nothing
    # end

    @debug "Setup done"
    LarSurf.lsp_get_surface(segmentation)


end


# ch = RemoteChannel(()->Channel{Int}(32));


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
