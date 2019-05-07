#=
surface_extraction:
- Julia version: 1.1.0
- Author: Jirik
- Date: 2019-03-19
=#
"""
return
surfaceLARmodel, Flin, fullLARmodel
"""
function get_surface_grid(segmentation::AbstractArray; return_all::Bool=false)
    segClin = lario3d.grid_to_linear(segmentation, 0)

    block_size = lario3d.size_as_array(size(segmentation))

    b3, larmodel = lario3d.get_boundary3(block_size)
    V, topology = larmodel
    (VV, EV, FV, CV) = topology
    # println("segmentation: ", size(segmentation))
    # println("segClin: ", size(segClin), " ", typeof(segClin))
    # println("b3: ", size(b3), " ", typeof(b3))
    # println("==========")
    Flin = segClin' * b3
    # Matrix(Flin)
    lario3d.sparse_filter!(Flin, 1, 1, 0)
    dropzeros!(Flin)

    filteredFV = [FV[i] for i=1:length(Flin) if (Flin[i] == 1)]
    if return_all
        return (V, [filteredFV]), Flin, larmodel
    else
        return (V, [filteredFV])
    end
end

"""
Based on input segmentation and block size calculate filtered FV and full sparse FV.
In sparse FV is number 1 where is the surface. There is also number 2 where is
the edge between blocks.
"""
function __grid_get_surface_Fchar_per_block(segmentation::AbstractArray, block_size::Array{Int,1})
    data_size = lario3d.size_as_array(size(segmentation))
    numF = lario3d.grid_number_of_faces(data_size)
    # print("size vs length vs grid_number_of_faces: ", szF, " ", lenF, " ", numF)
    # print("size vs length vs grid_number_of_faces: ", typeof(szF), " ", typeof(lenF), " ", typeof(numF))

    # block_size = [2, 3, 4]
    margin_size = 0
    block_number, blocks_number_axis = lario3d.number_of_blocks_per_axis(
        data_size, block_size)

    # bigFchar = spzeros(Int8, lenF)
    bigFchar = spzeros(Int8, numF)
    Flin = Nothing
    @debug "block number ", block_number, " block size: ", block_size, "margin size: ", margin_size,
        " block number axis: ", blocks_number_axis
    for block_i=1:block_number
        block1, offset1, block_size1 = lario3d.get_block(
            segmentation, block_size, margin_size, blocks_number_axis, block_i
        )
        segmentation1 = block1

        filteredFVi, Flin, (V, model) = lario3d.get_surface_grid(segmentation1; return_all=true)
        (VV, EV, FV, CV) = model

    # face from small to big

        for fid=1:length(Flin)
            if (Flin[fid] == 1)

                big_fid, voxel_cart = lario3d.sub_grid_face_id_to_orig_grid_face_id(data_size, block_size1, offset1, fid)
                bigFchar[big_fid] += 1

            end
        end
    end
    return bigFchar
end

function get_surface_grid_per_block_full(segmentation::AbstractArray, block_size::ArrayOrTuple; return_all::Bool=false)
    Fchar = __grid_get_surface_Fchar_per_block(segmentation, block_size)

    data_size = lario3d.size_as_array(size(segmentation))
    # bigV, (bigVV, bigEV, bigFV, bigCV) = Lar.cuboidGrid(data_size, true)
    # model = (bigVV, bigEV, bigFV, bigCV)
    bigV, FVreduced = lario3d.grid_Fchar_to_V_FVfulltoreduced(Fchar, data_size)
    model = [FVreduced]

    # return filtered_bigFV, Fchar, (bigV, model)

    if return_all
        return (bigV,[FVreduced]), Fchar, (bigV, model)
    else
        return (bigV,[FVreduced])
    end
end

"""
Construction of FV is reduced. The V
"""
function get_surface_grid_per_block_Vreduced_FVreduced(segmentation::AbstractArray, block_size::ArrayOrTuple; return_all::Bool=false)
    Fchar = __grid_get_surface_Fchar_per_block(segmentation, block_size)

    data_size = lario3d.size_as_array(size(segmentation))
    # bigV, (bigVV, bigEV, bigFV, bigCV) = Lar.cuboidGrid(data_size, true)
    # model = (bigVV, bigEV, bigFV, bigCV)
    bigV, FVreduced = lario3d.grid_Fchar_to_Vreduced_FVreduced(Fchar, data_size)

    # return filtered_bigFV, Fchar, (bigV, model)

    if return_all
        return (bigV,[FVreduced]), Fchar, (bigV, [FVreduced])
    else
        return (bigV,[FVreduced])
    end
end


function get_surface_grid_per_block_FVreduced(segmentation::AbstractArray, block_size::ArrayOrTuple; return_all::Bool=false)
    # block_size::Array{Integer, 1}


    # filteredFV, Flin, V, model = lario3d.get_surface_grid(segmentation)
    # (VV, EV, FV, CV) = model
    # Plasm.View((V,[VV, EV, filteredFV]))

    # bigV, (bigVV, bigEV, bigFV, bigCV) = Lar.cuboidGrid(data_size, true)
    # szF = size(bigFV)[1]
    # lenF = length(bigFV)
    # numF = lario3d.grid_number_of_faces(data_size)
    Fchar = __grid_get_surface_Fchar_per_block(segmentation, block_size)

    data_size = lario3d.size_as_array(size(segmentation))
    bigV, FVreduced = lario3d.grid_Fchar_to_V_FVreduced(Fchar, data_size)

    # return filtered_bigFV, Fchar, (bigV, model)

    if return_all
        return (bigV,[FVreduced]), Fchar, (bigV, [FVreduced])
    else
        return (bigV,[FVreduced])
    end



    # all_info = [lario3d.grid_face_id_to_node_ids(data_size, bigFchar[i])
    #     for i=1:length(bigFchar) if bigFchar[i] == 1
    # ]
    #
    # filtered_bigFV = [all_info[i][1] for i=1:length(bigFchar)]
    #
    # # bigV, (bigVV, bigEV, bigFV, bigCV) = Lar.cuboidGrid(data_size, true)
    # # model = (bigVV, bigEV, bigFV, bigCV)
    # bigV, model = Lar.cuboidGrid(data_size, true)
    # (bigVV, bigEV, bigFV, bigCV) = model
    #
    # # Get FV and filter double faces on the border
    # filtered_bigFV1 = [
    #     bigFV[i] for i=1:length(bigFchar) if bigFchar[i] == 1
    # ]
    # # TODO filtered_bigFV a filtered_bigFV1 by měly být stejné, s přeházeným pořadím
    # if return_all
    #     return (bigG, [filtered_bigFV]), bigFchar, (bigV, model)
    # else
    #     return (bigG, [filtered_bigFV])
    # end
end
