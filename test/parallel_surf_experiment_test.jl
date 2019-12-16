
#=
surface_test:
- Julia version: 1.1.0
- Author: Jirik
=#
using Test
using Logging
using SparseArrays
using Pio3d
using Distributed
if nprocs() == 1
    addprocs(3)
end
# # using Revise
# ENV["JULIA_DEBUG"] = "surface_extraction_parallel"
# ENV["JULIA_DEBUG"] = "all"
# using ViewerGL
# using Plasm
# using LarSurf
@everywhere using LarSurf
# @everywhere using Distributed
# global_logger(SimpleLogger(stdout, Logging.Debug))
# # set logger on all workers
# for wid in workers()
#     @spawnat wid global_logger(SimpleLogger(stdout, Logging.Debug))
# end
@testset "Init and deinit" begin
    block_size = [2, 2, 2]
    pth = Pio3d.datasets_join_path("medical/orig/sample_data/nrn4.pklz")
	datap = Pio3d.read3d(pth)
	data3d = datap["data3d"]
	voxelsize_mm = datap["voxelsize_mm"]
    @info "File path " pth
    data = LarSurf.Experiments.report_init_row(@__FILE__)
    V1, FVtri = LarSurf.Experiments.experiment_make_surf_extraction_and_smoothing(
    data3d, voxelsize_mm;
    data=data,
	output_csv_file="test_nrn4.csv"
    )
    @test length(V1) > 1
    @info "size V1 = " size(V1)
    @info "size FVtri = " size(FVtri)
    @test size(V1, 1) == 3
    @test size(V1, 2) > 10
    @test size(FVtri[1], 1) == 3
    @test size(FVtri, 1) > 10

end
