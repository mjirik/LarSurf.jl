using Test
using Logging
using Revise
using lario3d
using Plasm
using LinearAlgebraicRepresentation
# Logging.configure(level==Logging.Debug)


# include("../src/lario3d.jl")
# include("../src/block.jl")

@testset "Get inner block" begin
    faces=lario3d.cube_in_block_surface([2,3,4], [1,1,1], [1,2,3])
#     @test collect(faces) == [1, 13, 22]
    println(faces)
    # [1, 13, 2, 14, 3, 15, 5, 17, 6, 18, 7, 19, 37, 45, 38, 46, 39, 47, 69, 72, 74, 77]
end




@testset "Map inner face ID to outer ID" begin
#     @test collect(faces) == [1, 13, 22]
    # [1, 13, 2, 14, 3, 15, 5, 17, 6, 18, 7, 19, 37, 45, 38, 46, 39, 47, 69, 72, 74, 77]
end
