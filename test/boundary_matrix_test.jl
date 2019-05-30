using Revise
using Test
using Logging
using lario3d
# Logging.configure(level==Logging.Debug)


# include("../src/lario3d.jl")
# include("../src/block.jl")

@testset "Boundary matrix shape test" begin
    grid_size = [2,3,4]
    b3, larmodel = lario3d.calculate_boundary3(grid_size)
#     println(size(b3))
#     @test size(b3) =
#     slides0 = lario3d.random_image([7, 7, 7], [1,2,2], [3, 4, 5], 2)
#     Matrix(slides0)
#     @test all(slides0 .== [1, 5, 6, 10, 11, 15])

    # slides0 = lario3d.data_sub_from_block_sub([5, 5, 5], 1, [1,2,3])
    # @test all(slides0 .== [0, 6, 5, 11, 10, 16])
    Cnum = prod(grid_size)
    Fnum = lario3d.grid_number_of_faces(grid_size)
    @test size(b3, 1) == Cnum
    @test size(b3, 2) == Fnum

    V, (VV, EV, FV, CV) = larmodel
    @test size(b3, 1) == length(CV)
    @test size(b3, 2) == length(FV)

    @test size(b3) == (24, 98)
    FV = larmodel[2][3]
    # display(FV)
    # println(Fnum)

end

@testset "reagular brick boundary matrix to image file" begin
    # using ImageView
    sz = 4
    grid_size = [sz, sz, sz]
    b3, larmodel = lario3d.calculate_boundary3(grid_size)
    barr = Matrix(b3 .> 0)
    nvoxels = sz^3
    nfaces = 3 * (sz^2 * (sz + 1) )
    @test size(barr, 1) == nvoxels
    @test size(barr, 2) == nfaces
    # imshow(barr)
end


@testset "Tests get boundary" begin
    grid_size = [2,3,4]
    lario3d.set_param(
        boundary_allow_memory=false,
        boundary_allow_read_files=false,
        boundary_allow_write_files=false
        )
    b3a, larmodel_a = lario3d.get_boundary3(grid_size)

    lario3d.set_param(boundary_allow_memory=true)
    b3b, larmodel_b = lario3d.get_boundary3(grid_size)

    @test size(b3a) == (24, 98)
    @test size(b3b) == (24, 98)

end
