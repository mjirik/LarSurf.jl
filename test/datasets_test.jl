using Test
using Logging
using Revise
using LarSurf
# Logging.configure(level==Logging.Debug)


# include("../src/LarSurf.jl")
# include("../src/block.jl")

@testset "Block basic function Tests" begin
    data3d = LarSurf.random_image([7, 7, 7], [1,2,2], [3, 4, 5], 2)
    @test maximum(data3d) > 2
    @test minimum(data3d) < 1
end


@testset "Tetris" begin
    segmentation = LarSurf.data_tetris()
    @test minimum(segmentation) == 0
    @test maximum(segmentation) == 1
end
