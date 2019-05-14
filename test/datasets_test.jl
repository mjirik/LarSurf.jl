using Test
using Logging
using Revise
using lario3d
# Logging.configure(level==Logging.Debug)


# include("../src/lario3d.jl")
# include("../src/block.jl")

@testset "Block basic function Tests" begin
    data3d = lario3d.random_image([7, 7, 7], [1,2,2], [3, 4, 5], 2)
    @test maximum(data3d) > 2
    @test minimum(data3d) < 1
end
