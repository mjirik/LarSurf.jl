#=
surface_extraction:
- Julia version: 1.1.0
- Author: Jirik
- Date: 2019-03-19
=#
function get_surface_grid(segmentation)
    segClin = lario3d.block_to_linear(segmentation, 0)

    block_size = size(segmentation)

    b3, V, model = lario3d.get_boundary3(block_size)

    # Matrix(b3)

    Flin = segClin' * b3
    # Matrix(Flin)
    lario3d.sparse_filter!(Flin, 1, 1, 0)
    dropzeros!(Flin)

    (VV, EV, FV, CV) = model
    # Flin = segClin' * b3

    filteredFV = [FV[i] for i=1:length(Flin) if (Flin[i] == 1)]
    return filteredFV, Flin, V, model
end

function get_surface_grid_per_block(segmentation, block_size)
    # block_size::Array{Integer, 1}

    data_size = lario3d.size_as_array(size(segmentation))


    # filteredFV, Flin, V, model = lario3d.get_surface_grid(segmentation)
    # (VV, EV, FV, CV) = model
    # Plasm.View((V,[VV, EV, filteredFV]))

    bigV, (bigVV, bigEV, bigFV, bigCV) = Lar.cuboidGrid(data_size, true)

    bigFsparse = spzeros(Int8, size(bigFV)[1], 1)

    block_size = [2, 3, 4]
    margin_size = 0
    block_number, blocks_number_axis = lario3d.number_of_blocks_per_axis(
        data_size, block_size)



    bigFchar = spzeros(Int8, length(bigFV))
    Flin = Nothing
#     println("block number ", block_number, " block size: ", block_size, "margin size: ", margin_size,
#     " block number axis: ", blocks_number_axis)
    for block_i=1:block_number
#         println("block_i: ", block_i)
        block1, offset1, block_size1 = lario3d.get_block(
            segmentation, block_size, margin_size, blocks_number_axis, block_i
        )
#         println(" offset: ", offset1, " size i: ", block_size1, " real_size:", size(block1), " size: ", block_size)
        # offset1 = [0,0,0]
    #     segmentation1 = block1 .> threshold
        segmentation1 = block1

        filteredFVi, Flin, V, model = lario3d.get_surface_grid(segmentation1)
        (VV, EV, FV, CV) = model
    #     Plasm.View((V,[VV, EV, filteredFV]))
    #     print("Flin ", Flin)

    # face from small to big


    # fid_subgrid = [i for i=1:size(Flin)[2] if 0 < Flin[1,i]]

#         println("voxel cartesian")
        for fid=1:length(Flin)
            if (Flin[fid] == 1)

                big_fid, voxel_cart = lario3d.sub_grid_face_id_to_orig_grid_face_id(data_size, block_size1, offset1, fid)
#                 print(fid, voxel_cart, big_fid, " ")
                bigFchar[big_fid] += 1

            end
        end
    # filtered_bigFV = [
    #     bigFV[lario3d.sub_grid_face_id_to_orig_grid_face_id(data_size, block_size, offset1, fid)]
    #     )
    # ]
    end

    # Get FV and filter double faces on the border
    filtered_bigFV = [
        bigFV[i] for i=1:length(bigFchar) if bigFchar[i] == 1
    ]

    model = (bigVV, bigEV, bigFV, bigCV)
    return filtered_bigFV, bigFchar, bigV, model
end
