using Test
using Logging
# using Revise
using lario3d
# Logging.configure(level==Logging.Debug)


# include("../src/lario3d.jl")
# include("../src/block.jl")

@testset "Tests" begin
    b3 = lario3d.calculate_boundary3([5,5,5])
#     println(size(b3))
#     @test size(b3) =
#     slides0 = lario3d.random_image([7, 7, 7], [1,2,2], [3, 4, 5], 2)
#     Matrix(slides0)
#     @test all(slides0 .== [1, 5, 6, 10, 11, 15])

    # slides0 = lario3d.data_sub_from_block_sub([5, 5, 5], 1, [1,2,3])
    # @test all(slides0 .== [0, 6, 5, 11, 10, 16])

end


