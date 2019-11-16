
#=
surface_test:
- Julia version: 1.1.0
- Author: Jirik
=#
using Distributed
if nprocs() == 1
    addprocs(3)
end
# using Revise
using Test
using Logging
using SparseArrays
# ENV["JULIA_DEBUG"] = "surface_extraction_parallel"
# ENV["JULIA_DEBUG"] = "all"
# using ViewerGL
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
    pth = Io3d.datasets_join_path("medical/orig/sample-data/nrn4.pklz")
    data = LarSurf.Experiments.report_init_row(@__FILE__)
    V1, FVtri = LarSurf.Experiments.experiment_make_surf_extraction_and_smoothing(
    pth;
    show=false
    )

end
