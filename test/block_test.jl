using Test
include("../src/lario3d.jl")
# include("../src/block.jl")

@testset "Block basic function Tests" begin
    slides0 = lario3d.data_sub_from_block_sub([5, 5, 5], 0, [1,2,3])
    @test all(slides0 .== [1, 5, 6, 10, 11, 15])

    slides0 = lario3d.data_sub_from_block_sub([5, 5, 5], 1, [1,2,3])
    @test all(slides0 .== [0, 6, 5, 11, 10, 16])

end

@testset "Block complex function Tests" begin
    block_size = [5, 5, 5]
    margin_size = 0

    ## Artifical data
    data3d = ones(Int16, 19, 15, 31)
    data3d[2:14,8:13,9:11] .= 10
    # data3d

    voxelsize_mm = [0.5, 0.9, 0.8]
    threshold=0


    blocks_number, blocks_number_axis = lario3d.number_of_blocks_per_axis(
        size(data3d), block_size)
    # print(size(data3d))
    # print("\n")
    # print(blocks_number, blocks_number_axis)
    @test blocks_number == 84
    @test blocks_number_axis == [4, 3, 7]


    block1 = lario3d.get_block(
        data3d, block_size, margin_size, blocks_number_axis, 1
    )

    block4 = lario3d.get_block(
        data3d, block_size, margin_size, blocks_number_axis, 4
    )
    @test size(block1)[1] == 5
    @test size(block1)[2] == 5
    @test size(block1)[3] == 5
    @test size(block4)[1] == 5
    @test size(block4)[2] == 5
    @test size(block4)[3] == 5
    # block11 = lario3d.get_block(
    #     data3d, block_size, margin_size, 1, 1
    # )
    lario3d.print_array_stats(block1)
    lario3d.print_array_stats(block4)
    lario3d.print_array_stats(data3d)


end

# lario3d.prepare_for_block_processing()