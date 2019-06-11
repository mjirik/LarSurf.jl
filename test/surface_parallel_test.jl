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
global_logger(SimpleLogger(stdout, Logging.Debug))

@testset "Init parallel surface computation" begin
    block_size = [2, 2, 2]
    LarSurf.lsp_setup(block_size)
    for wid in workers()
        println("testing on $wid")
        ftr = @spawnat wid LarSurf._single_boundary3
        @test fetch(ftr) != nothing
    end

    segmentation = LarSurf.data234()
    @async LarSurf.lsp_job_enquing(segmentation)
    results = RemoteChannel(()->Channel{Array}(32));

    data_size = LarSurf.size_as_array(size(segmentation))

    for wid in workers()
        remote_do(
            LarSurf.lsp_do_work_code_multiply_decode,
            wid,
            data_size,
            LarSurf._ch_block,
            results,
        )
    end

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
