#=
surface_test:
- Julia version: 1.1.0
- Author: Jirik
- Date: 2019-03-19
=#
using Test
using Logging
using Revise
using lario3d
using Plasm
using LinearAlgebraicRepresentation
# Lar = LinearAlgebraicRepresentation


@testset "Extract surface grid" begin

    segmentation = zeros(Int8, 5, 6, 7)

    segmentation[2:5,2:5,2:6] .= 1
    obj_sz = [4, 4, 5]
    # Plasm.view(Plasm.numbering(.6)((V,[VV, EV, filteredFV])))

    filteredFV, Flin, (V, model) = lario3d.get_surface_grid(segmentation)
    (VV, EV, FV, CV) = model
#     Plasm.View((V,[VV, EV, filteredFV]))

    expected_size = 2 * (obj_sz[1] * obj_sz[2] + obj_sz[2] * obj_sz[3] + obj_sz[1] * obj_sz[3])


    @test expected_size == expected_size
    # print(faces, "\n")
end

@testset "Extract surface grid per block full" begin

    segmentation = zeros(Int8, 5, 6, 7)

    segmentation[2:5,2:5,2:6] .= 1
    obj_sz = [4, 4, 5]
    # Plasm.view(Plasm.numbering(.6)((V,[VV, EV, filteredFV])))

    filteredFV, Flin, (V, model) = lario3d.get_surface_grid_per_block_full(segmentation, [3,3,3])
    (VV, EV, FV, CV) = model
    Plasm.View((V,[VV, EV, filteredFV]))

    bigFchar = Flin
    data_size = lario3d.size_as_array(size(segmentation))
    all_info = [
        lario3d.grid_face_id_to_node_ids(data_size, i)
        for i=1:length(bigFchar) if bigFchar[i] == 1
    ]

    filtered_bigFV2 = [all_info[i][1] for i=1:length(all_info)]
    n_nodes = lario3d.grid_number_of_nodes(data_size)
    import SparseArrays.spzeros
    # Vcomputed = spzeros(Float64, 3, n_nodes)
    Vcomputed = zeros(Float64, 3, n_nodes)
    for i=1:length(all_info)
        # all_info[i][2]
        Vcomputed[:, all_info[i][1][1]] = all_info[i][2][1]
        Vcomputed[:, all_info[i][1][2]] = all_info[i][2][2]
        Vcomputed[:, all_info[i][1][3]] = all_info[i][2][3]
        Vcomputed[:, all_info[i][1][4]] = all_info[i][2][4]
    end

    # Plasm.View((Vcomputed,[VV, EV, filtered_bigFV2]))
    Plasm.View((Vcomputed,[VV, filtered_bigFV2]))
    # expected_size = 2 * (obj_sz[1] * obj_sz[2] + obj_sz[2] * obj_sz[3] + obj_sz[1] * obj_sz[3])


    # @test expected_size == expected_size
    # print(faces, "\n")
end

@testset "Extract surface grid per block" begin

    segmentation = zeros(Int8, 5, 6, 7)

    segmentation[2:5,2:5,2:6] .= 1
    obj_sz = [4, 4, 5]
    # Plasm.view(Plasm.numbering(.6)((V,[VV, EV, filteredFV])))

    filteredFV, Flin, (V, model) = lario3d.get_surface_grid_per_block(segmentation, [3,3,3])
    (VV, EV, FV, CV) = model
    Plasm.View((V,[VV, EV, filteredFV]))

    # expected_size = 2 * (obj_sz[1] * obj_sz[2] + obj_sz[2] * obj_sz[3] + obj_sz[1] * obj_sz[3])


    # @test expected_size == expected_size
    # print(faces, "\n")
end
