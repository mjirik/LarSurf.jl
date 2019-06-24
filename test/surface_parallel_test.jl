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
# using Revise
using Test
using Logging
using SparseArrays
using ViewerGL
# using Plasm
@everywhere using LarSurf
# @everywhere using Distributed
# global_logger(SimpleLogger(stdout, Logging.Debug))
# # set logger on all workers
# for wid in workers()
#     @spawnat wid global_logger(SimpleLogger(stdout, Logging.Debug))
# end
@testset "Init and deinit" begin
    block_size = [2, 2, 2]
    # println("Channel type apriori $(typeof(LarSurf._ch_block))")
    LarSurf.lsp_setup(block_size)
    # println("Channel type aposteriori: $(typeof(LarSurf._ch_block))")
    # println("channel aposteriori $(LarSurf._ch_block)")
    LarSurf.lsp_deinit_workers()
end

@testset "Setup parallel surface computation" begin
    block_size = [2, 2, 2]
    LarSurf.lsp_setup(block_size)
    for wid in workers()
        # println("testing on $wid")
        ftr = @spawnat wid LarSurf._single_boundary3
        @test fetch(ftr) != nothing
    end
end

#
@testset "parallel surface extraction " begin
    block_size = [2, 2, 2]
    segmentation = LarSurf.data234()

    LarSurf.lsp_setup(block_size)

    @debug "Setup done"
    larmodel = LarSurf.lsp_get_surface(segmentation)
    @test LarSurf.check_surface_euler(larmodel[2])
    FVtri = LarSurf.triangulate_quads(larmodel[2])
    # @test LarSurf.check_surface_euler(FVtri)
    # LarSurf.check_LARmodel(larmodel)
    # Plasm.view()
    # Plasm.view( Plasm.numbering(.6)(larmodel) )
	V, FV = larmodel
	# FV1 = [[f[1], f[3], f[4]] for f in FV]
	# FV2 = [[f[1], f[3], f[2]] for f in FV]
	FV1 = [[f[1], f[3], f[4]] for f in FV]
	FV2 = [[f[1], f[3], f[2]] for f in FV]
	FVtri = vcat(FV1, FV2)
ViewerGL.VIEW([
    ViewerGL.GLGrid(V,FVtri,ViewerGL.Point4d(1,1,1,0.1))
	ViewerGL.GLAxis(ViewerGL.Point3d(-1,-1,-1),ViewerGL.Point3d(1,1,1))
])
# ViewerGL.VIEW([
#     ViewerGL.GLGrid(V,FV,ViewerGL.Point4d(1,1,1,0.1))
# 	ViewerGL.GLAxis(ViewerGL.Point3d(-1,-1,-1),ViewerGL.Point3d(1,1,1))
# ])


end

@testset "run on local" begin

    block_size = [2, 2, 2]
    segmentation = LarSurf.data234()
    block_id = 3

    data_size = LarSurf.size_as_array(size(segmentation))

    LarSurf.lsp_setup(block_size)
    # b3, larmodel = LarSurf.get_boundary3(block_size)
    # LarSurf.set_single_boundary3(b3, block_size)
    n, bgetter = LarSurf.block_getter(segmentation, block_size;fixed_block_size=true)
    block = LarSurf.get_block(block_id, bgetter...)
    # outdata, offset, sz =block
    data_for_channel = (block..., block_id)

    # tm_put = @elapsed put!(LarSurf._ch_block, data_for_channel)
    # fbl = take!(LarSurf._ch_block)
    # alternativelly can be channel step skipped with:
    fbl = data_for_channel
    faces = LarSurf.code_multiply_decode(data_size, fbl...)
    @test length(faces) == 16

end
#

# @testset "parallel surface extraction big" begin
#     block_size = [64, 64, 64]
#     # segmentation = LarSurf.data234()
#     segmentation = LarSurf.generate_cube(512)
#
#     LarSurf.lsp_setup(block_size)
#     # for wid in workers()
#     #     # println("testing on $wid")
#     #     ftr = @spawnat wid LarSurf._single_boundary3
#     #     @test fetch(ftr) != nothing
#     # end
#
#     @debug "Setup done"
#     tt = @elapsed LarSurf.lsp_get_surface(segmentation)
#     println("time: $tt")
#
#
# end
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
