using Test
using Logging
# using Revise
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
    segmentation = LarSurf.tetris_brick()
    @test minimum(segmentation) == 0
    @test maximum(segmentation) == 1
end

@testset "data234" begin
    segmentation = LarSurf.data234()
    @test minimum(segmentation) == 0
    @test maximum(segmentation) == 1
end

@testset "half sphere generation" begin
    segmentation = LarSurf.generate_truncated_sphere(10, [20,20,20])
    @test minimum(segmentation) == 0
    @test maximum(segmentation) == 1

    segmentation = LarSurf.generate_truncated_sphere(10)
    @test minimum(segmentation) == 0
    @test maximum(segmentation) == 1
end
