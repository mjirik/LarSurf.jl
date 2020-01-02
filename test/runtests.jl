# using Revise
using Test
using Logging
using LarSurf
# using Base.Test

# write your own tests here
# @test 1 == 2

# @test hello("Julia") == "Hello, Julia"

include("arr_test.jl")
include("block_test.jl")
include("boundary_matrix_test.jl")
include("datasets_test.jl")
# include("dicom_test.jl")
include("face_id_reconstruction.jl")
include("parallel_surf_experiment_test.jl")
include("inner_block_test.jl")
include("smoothing_test.jl")
include("support_test.jl")
# include("surface_parallel_channel_test.jl")
include("surface_parallel_pmap_test.jl")
include("surface_parallel_test.jl")
include("surface_per_voxel.jl")
include("surface_test.jl")
include("triangulate_test.jl")
# include("dicom_test.jl")
