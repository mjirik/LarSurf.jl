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

    segmentation = zeros(Int8, 2, 3, 4)

    segmentation[1:2,2:3,3:4] .= 1
    obj_sz = [2, 2, 2]
    # Plasm.view(Plasm.numbering(.6)((V,[VV, EV, filteredFV])))

    filteredFV, Fchar, (V, model) = lario3d.get_surface_grid_per_block_full(segmentation, [2,2,2])
    (VV, EV, FV, CV) = model
    Plasm.View((V,[VV, EV, filteredFV]))

    # second implementation
    V2, FV2 = lario3d.grid_Fchar_to_V_FVreduced(Fchar, size(segmentation))
    Plasm.view( Plasm.numbering(.6)((V2,[VV, EV, FV2])) )

    # third implementation
    data_size = lario3d.size_as_array(size(segmentation))

    # all_info = [
    #     lario3d.grid_face_id_to_node_ids(data_size, i)
    #     for i=1:length(Fchar) if Fchar[i] == 1
    # ]
    function count_F_from_Fchar(Fchar)
        countF = 0
        for i=1:length(Fchar)
            if Fchar[i] == 1
                countF
                countF = countF + 1
            end
        end
        return countF
    end
    countF = count_F_from_Fchar(Fchar)

    FV3 = Array{Array{Int64,1},1}(undef, countF)

    node_carts_dict = Dict()
    fv_i = 0
    for i=1:length(Fchar)
        global fv_i
        if Fchar[i] == 1
            face_ids, nodes_carts = lario3d.grid_face_id_to_node_ids(data_size, i)
            node_carts_dict[face_ids[1]] = nodes_carts[1]
            node_carts_dict[face_ids[2]] = nodes_carts[2]
            node_carts_dict[face_ids[3]] = nodes_carts[3]
            node_carts_dict[face_ids[4]] = nodes_carts[4]
            fv_i += 1
            FV3[fv_i] = face_ids
        end
    end
    ks = keys(node_carts_dict)
    node_ids = Dict(zip(ks, collect(1:length(ks))))

    for i=1:length(FV3)

        for j=1:length(FV3[i])
            FV3[i][j] = node_ids[FV3[i][j]]
        end
    end

    Plasm.view( Plasm.numbering(.6)((V2,[VV, EV, FV3])) )

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
