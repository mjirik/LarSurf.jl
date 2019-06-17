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
    n, bgetter = LarSurf.lsp_setup_data(segmentation)
    @async LarSurf.lsp_job_enquing(n, bgetter)
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

    # print("===== Output Faces =====")
    numF = LarSurf.grid_number_of_faces(data_size)

    bigFchar = spzeros(Int8, numF)
    @elapsed for i=1:n
        @debug "Collecting the information for block $i"
        faces_per_block = take!(results)
        println(faces_per_block)
        # for  block_i=1:block_number
            for big_fid in faces_per_block
                # median time 31 ns
                # bigFchar[big_fid] = (bigFchar[big_fid] + 1) % 2
                # median time 14 ns
                bigFchar[big_fid] = if (bigFchar[big_fid] == 1) 0 else 1 end
            end
        # end

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
