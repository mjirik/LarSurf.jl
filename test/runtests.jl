using Revise
using Test
using Logging
using LarSurf
# using Base.Test

# write your own tests here
# @test 1 == 2

# @test hello("Julia") == "Hello, Julia"

include("block_test.jl")
include("boundary_matrix_test.jl")
include("datasets_test.jl")
include("experiment_support_test.jl")
include("face_id_reconstruction.jl")
include("inner_block_test.jl")
include("io3d_test.jl")
include("support_test.jl")
include("surface_test.jl")
