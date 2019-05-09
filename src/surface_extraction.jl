#=
surface_extraction:
- Julia version: 1.1.0
- Author: Jirik
- Date: 2019-03-19
=#

"""
Calculate multiplication linearized volume cells with boundary matrix and
filter it for number 1.
"""
function grid_get_surface_Flin(segmentation::AbstractArray)
    segClin = lario3d.grid_to_linear(segmentation, 0)

    block_size = lario3d.size_as_array(size(segmentation))

    b3, larmodel = lario3d.get_boundary3(block_size)
    # println("segmentation: ", size(segmentation))
    # println("segClin: ", size(segClin), " ", typeof(segClin))
    # println("b3: ", size(b3), " ", typeof(b3))
    # println("==========")
    Flin = segClin' * b3
    # Matrix(Flin)
    lario3d.sparse_filter!(Flin, 1, 1, 0)
    dropzeros!(Flin)
    return Flin, larmodel
end

function grid_get_surface_Flin_old(segmentation::AbstractArray)
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
    lario3d.sparse_filter_old!(Flin, 1, 1, 0)
    dropzeros!(Flin)
    return Flin, larmodel
end

"""
return
surfaceLARmodel, Flin, fullLARmodel
"""
function get_surface_grid(segmentation::AbstractArray; return_all::Bool=false)
    Flin, larmodel = grid_get_surface_Flin(segmentation)

    println("Flin ", size(Flin), " ", maximum(Flin))
    V = larmodel[1]
    FV = larmodel[2][4]
    inds, vals = findnz(Flin)
    # filteredFV = [FV[i] for i=inds]
    filteredFV = [FV[i] for i=1:length(Flin) if (Flin[i] == 1)]
    if return_all
        return (V, [filteredFV]), Flin, larmodel
    else
        return (V, [filteredFV])
    end
end



function get_surface_grid_old(segmentation::AbstractArray; return_all::Bool=false)
    Flin, larmodel = grid_get_surface_Flin_old(segmentation)
    V, topology = larmodel
    (VV, EV, FV, CV) = topology

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

    bigFchar = spzeros(Int8, numF)
    # println("bigFchar ", size(bigFchar))
    Flin = Nothing
    # println("block number ", block_number, " block size: ", block_size, "margin size: ", margin_size,
    #     " block number axis: ", blocks_number_axis)
    for block_i=1:block_number
        block1, offset1, block_size1 = lario3d.get_block(
            segmentation, block_size, margin_size, blocks_number_axis, block_i
        )
        segmentation1 = block1

        # filteredFVi, Flin, (V, model) = lario3d.get_surface_grid(segmentation1; return_all=true)
        # (VV, EV, FV, CV) = model
        Flin, larmodel = lario3d.grid_get_surface_Flin(segmentation1)

    # face from small to big
        i, j, v = findnz(Flin)
        # println("Flin i j v, ", length(i)," ", length(v), " bigFchar ", nnz(bigFchar))
        for fid=j
            big_fid, voxel_cart = lario3d.sub_grid_face_id_to_orig_grid_face_id(data_size, block_size1, offset1, fid)
            # if it is 0 set it one
            # if it is 1 there are two faces (prev and current) so remove
            # if bigFchar[big_fid] == 0
            bigFchar[big_fid] = (bigFchar[big_fid] + 1) % 2
            # bigFchar[big_fid] += 1
            # print(".")
        end
        # @time for fid=1:length(Flin)
        #     if (Flin[fid] == 1)
        #
        #         big_fid, voxel_cart = lario3d.sub_grid_face_id_to_orig_grid_face_id(data_size, block_size1, offset1, fid)
        #         bigFchar[big_fid] += 1
        #
        #     end
        # end
    end
    dropzeros!(bigFchar)
    return bigFchar
end

function __grid_get_surface_Fchar_per_block_old_implementation(segmentation::AbstractArray, block_size::Array{Int,1})
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

        filteredFVi, Flin, (V, model) = lario3d.get_surface_grid_old(segmentation1; return_all=true)
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
    println("Fchar ", size(Fchar))

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
function get_surface_grid_per_block_Vreduced_FVreduced_old(segmentation::AbstractArray, block_size::ArrayOrTuple; return_all::Bool=false)
    Fchar = __grid_get_surface_Fchar_per_block_old_implementation(segmentation, block_size)

    data_size = lario3d.size_as_array(size(segmentation))
    # bigV, (bigVV, bigEV, bigFV, bigCV) = Lar.cuboidGrid(data_size, true)
    # model = (bigVV, bigEV, bigFV, bigCV)
    bigV, FVreduced = lario3d.grid_Fchar_to_Vreduced_FVreduced_old(Fchar, data_size)

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
end

function get_surface_grid_per_block(segmentation::AbstractArray, block_size::ArrayOrTuple; return_all::Bool=false)
    return get_surface_grid_per_block_Vreduced_FVreduced(segmentation, block_size; return_all=return_all)
end
