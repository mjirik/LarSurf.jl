# run examples/numbering3d.jl to check node numbers
using Revise
using Test
using Logging
using lario3d
using SparseArrays
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
# Logging.configure(level==Logging.Debug)


# include("../src/lario3d.jl")
# include("../src/block.jl")

@testset "Block basic function Tests" begin
    slides0 = lario3d.data_sub_from_block_sub([5, 5, 5], 0, [1,2,3])
    @test all(slides0 .== [1, 5, 6, 10, 11, 15])

    # slides0 = lario3d.data_sub_from_block_sub([5, 5, 5], 1, [1,2,3])
    # @test all(slides0 .== [0, 6, 5, 11, 10, 16])

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
    @test blocks_number == 84
    @test blocks_number_axis == [4, 3, 7]


    block1, offset1, size1 = lario3d.get_block(
        data3d, block_size, margin_size, blocks_number_axis, 1
    )

    block4, offset4, size4 = lario3d.get_block(
        data3d, block_size, margin_size, blocks_number_axis, 4
    )
    # println("block1:", block1, offset1, size1)
    # println("block4:", block4, offset4, size4)
    @debug block1
    @debug block2
    @test size(block1)[1] == 5
    @test size(block1)[3] == 5
    @test size(block1)[3] == 5
    @test size(block4)[1] == 4
    @test size(block4)[2] == 5
    @test size(block4)[3] == 5
    # block12 = lario3d.get_block(
    #     data3d, block_size, 1, blocks_number_axis, 2
    # )
    lario3d.debug_array_stats(block1)
    lario3d.debug_array_stats(block4)
    lario3d.debug_array_stats(data3d)

end


@testset "Get face ID test" begin
    faces= lario3d.get_face_ids_from_cube_in_grid([1,2,3], [1,1,1], false)
    @test collect(faces) == [1, 13, 22]
    # print(faces, "\n")
    faces = lario3d.get_face_ids_from_cube_in_grid([1,2,3], [1,2,1], false)
    @test collect(faces) == [4, 16, 26]
    # print(faces, "\n")
    faces = lario3d.get_face_ids_from_cube_in_grid([1,2,3], [1,1,2], false)
    @test collect(faces) == [2, 14, 23]
    # print(faces, "\n")


    faces = lario3d.get_face_ids_from_cube_in_grid([2,3,4], [2,2,3], false)
    # print(faces, "\n")
    @test collect(faces) == [19, 59, 91]

end

@testset "Get inner small block" begin
    faces = lario3d.cube_in_block_surface([2,3,4], [1,1,1], [1,1,1])
    @test sort(collect(faces)) == sort([1, 13, 37, 41, 69, 70])
    # print(faces, "\n")
end

@testset "Get inner big block" begin
    faces = lario3d.cube_in_block_surface([2,3,4], [1,1,1], [1,2,2])
    @test sort(collect(faces)) == sort([1, 13, 2, 14, 5, 17, 6, 18, 37, 45, 38, 46, 69, 71, 74, 76])
    # print(faces, "\n")
end

# TODO test subgrid face id based on small_block_face_id...


@testset "Get inner block slope" begin

    segmentation = lario3d.generate_slope([11,12,13])
    data_size = lario3d.size_as_array(size(segmentation))
    data3d = segmentation
    block_size = [2,3,4]
    block_i = 91
    margin_size = 0

block_number, blocks_number_axis = lario3d.number_of_blocks_per_axis(data_size, block_size)
    a = Array{Int}(
        undef,
        blocks_number_axis[1],
        blocks_number_axis[2],
        blocks_number_axis[3]
    )

    bsub = CartesianIndices(a)[block_i]
#     faces = lario3d.cube_in_block_surface([1,2,3], [1,1,1], [1,2,2])
    bsub_arr = [bsub[1], bsub[2], bsub[3]]

    first = (bsub_arr .== [1, 1, 1])
    last = (bsub_arr .== blocks_number_axis)
#     print(" bsub :", bsub, "block number axis", blocks_number_axis, " first last ", first, last, "\n")
    # if ----------
    # print(" end of col, row or slice ", bsub, "\n")

    xst, xsp, yst, ysp, zst, zsp = lario3d.data_sub_from_block_sub(
        block_size, margin_size, bsub
    )
    # print("input block size ")
    lario3d.print_slice3(xst, xsp, yst, ysp, zst, zsp)
    xst, oxst, xsh = lario3d.get_start_and_outstart_ind(xst, margin_size)
    yst, oyst, ysh = lario3d.get_start_and_outstart_ind(yst, margin_size)
    zst, ozst, zsh = lario3d.get_start_and_outstart_ind(zst, margin_size)
#         print("[", xsh, ", ", ysh, ",", zsh, "]")
#     szx, szy, szz = size(data3d)
    szx, szy, szz = data_size
    bszx, bszy, bszz = block_size
    xsp, oxsp = lario3d.get_end_and_outend_ind(xst, xsp, szx, xsh)
    ysp, oysp = lario3d.get_end_and_outend_ind(yst, ysp, szy, ysh)
    zsp, ozsp = lario3d.get_end_and_outend_ind(zst, zsp, szz, zsh)
    # print("postprocessing input")
    lario3d.debug_slice3(xst, xsp, yst, ysp, zst, zsp)
    # print("postprocessing output")
    lario3d.debug_slice3(oxst, oxsp, oyst, oysp, ozst, ozsp)

    outdata = zeros(
        eltype(data3d),
        xsp,
        ysp,
        zsp
#         block_size[1] + margin_size,
#         block_size[2] + margin_size,
#         block_size[3] + margin_size
    )
    outdata[oxst:oxsp, oyst:oysp, ozst:ozsp] = data3d[
        xst:xsp, yst:ysp, zst:zsp
    ]

#     @test collect(faces) == [1, 13, 22]
    # print(faces, "\n")
end


@testset "node id in grid" begin
    grid_size = [2, 3, 4]
    @test 27 == lario3d.grid_voxel_cart_to_node_id(grid_size, [2, 2, 2])
    @test 41 == lario3d.grid_voxel_cart_to_node_id(grid_size, [3, 1, 1])
    @test 60 == lario3d.grid_voxel_cart_to_node_id(grid_size, [3, 4, 5])

end

@testset "number faces in grid" begin
    # lmodel::Lar.LARmodel = Lar.cuboidGrid(block_size, true)
    data_size = [3,4,5]
    bigV, (bigVV, bigEV, bigFV, bigCV) = Lar.cuboidGrid(data_size, true)
    @test size(bigFV)[1] == lario3d.grid_number_of_faces(data_size)

end

@testset "node ids in grid from face id - no correspondence check" begin
    data_size = [2, 3, 4]
    nodes_ids, nodes_carts = lario3d.grid_face_id_to_node_ids(data_size, 20)
    @test sort(nodes_ids) == [29, 30, 34, 35]
    @test nodes_carts[1] == [2,2,4]
    @test nodes_carts[2] == [2,3,4]
    @test nodes_carts[3] == [2,2,5]
    @test nodes_carts[4] == [2,3,5]
    # test one of last faces, there was a problem
    nodes_ids, nodes_carts = lario3d.grid_face_id_to_node_ids(data_size, 98)
    @test sort(nodes_ids) == [35, 40, 55, 60]
    nodes_carts_sorted = sort(nodes_carts)
    @test nodes_carts_sorted[1] == [2,3,5]
    @test nodes_carts_sorted[2] == [2,4,5]
    @test nodes_carts_sorted[3] == [3,3,5]
    @test nodes_carts_sorted[4] == [3,4,5]

    nodes_ids, nodes_carts = lario3d.grid_face_id_to_node_ids(data_size, 67)
    @test sort(nodes_ids) == [38, 39, 58, 59]
    nodes_carts_sorted = sort(nodes_carts)
    @test nodes_carts_sorted[1] == [2,4,3]
    @test nodes_carts_sorted[2] == [2,4,4]
    @test nodes_carts_sorted[3] == [3,4,3]
    @test nodes_carts_sorted[4] == [3,4,4]

    nodes_ids, nodes_carts = lario3d.grid_face_id_to_node_ids(data_size, 52)
    @test sort(nodes_ids) == [19,20,39,40]
    nodes_carts_sorted = sort(nodes_carts)
    @test nodes_carts_sorted[1] == [1,4,4]
    @test nodes_carts_sorted[2] == [1,4,5]
    @test nodes_carts_sorted[3] == [2,4,4]
    @test nodes_carts_sorted[4] == [2,4,5]
end

@testset "node ids in grid from face id with checking correspondence of id" begin
    # here testing also the positions
    data_size = [2,3,4]
    # data_size = [3,4,5]
    nodes_ids, nodes_carts = lario3d.grid_face_id_to_node_ids(data_size, 83)
    display(nodes_ids)
    @test sort(nodes_ids) == [15,20,35,40]
    @test lario3d.check_faces_equal(nodes_ids, [20,15,35,40])
    @test lario3d.array_equal_roll_invariant(nodes_ids, [20,15,35,40])
    nodes_carts_sorted = sort(nodes_carts)
    @test nodes_carts[findall(x->x==15, nodes_ids)[1]] == [1,3,5]
    @test nodes_carts[findall(x->x==20, nodes_ids)[1]] == [1,4,5]
    @test nodes_carts[findall(x->x==35, nodes_ids)[1]] == [2,3,5]
    @test nodes_carts[findall(x->x==40, nodes_ids)[1]] == [2,4,5]
end

@testset "get block test with fixed block size" begin
    segmentation = zeros(Int8, 5, 6, 7)
    segmentation[2:5,2:5,2:6] .= 1
    block_size = [2,2,2]
    data_size = lario3d.size_as_array(size(segmentation))
    block_number, blocks_number_axis = lario3d.number_of_blocks_per_axis(
        data_size, block_size)

    block1, offset1, block_size1 = lario3d.get_block(
        segmentation, block_size, 0,
        blocks_number_axis, 3
        ;fixed_block_size=true)
    @test size(block1,1) == 2
    @test size(block1,2) == 2
    @test size(block1,3) == 2
end
