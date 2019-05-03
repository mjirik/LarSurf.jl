#=
block:
- Julia version:
- Author: miros
- Date: 2019-01-16
=#

include("print_function.jl")
ArrayOrTuple = Union{Array{Int, 1}, Tuple}
"""
seg3d
"""
function number_of_blocks_per_axis(seg3d_size, block_size)
#     println("block_size: ", block_size)
    if typeof(block_size) == Tuple{Int64}
        dim = nfields(seg3d_size)
    elseif  typeof(block_size) == Array{Int64, 1}
        dim = length(block_size)
    else
        warn("Unknown type of block_size")
    end
#     println( "dim:", dim, " seg size:", seg3d_size, " block size: ", block_size)

    blocks_number = Array{Int}(undef, dim)
    for k in 1:dim
        # print(k)
        delenec = seg3d_size[k]
        delitel = block_size[k]
        number_for_this_axis = cld(delenec, delitel)
        # print(" ", delenec, ", ", delitel, ", ", number_for_this_axis)

        blocks_number[k] = number_for_this_axis
    end
    return prod(blocks_number), blocks_number
end

function get_block(data3d, block_size:: Array{Int64, 1}, margin_size::Int, blocks_number_axis, block_i)
    a = Array{Int}(
        undef,
        blocks_number_axis[1],
        blocks_number_axis[2],
        blocks_number_axis[3]
    )
#     print("block_i: ", block_i)
    bsub = CartesianIndices(a)[block_i]
    bsub_arr = [bsub[1], bsub[2], bsub[3]]
    data_size = lario3d.size_as_array(size(data3d))

    first = (bsub_arr .== [1, 1, 1])
    last = (bsub_arr .== blocks_number_axis)
#     print(" bsub :", bsub, "block number axis", blocks_number_axis, " first last ", first, last, "\n")
    if any(first) || any(last)
        if margin_size == 0
#             println("running margin_size == 0 version")
            xst, xsp, yst, ysp, zst, zsp = lario3d.data_sub_from_block_sub(
                block_size, margin_size, bsub
            )
            stop = [xsp, ysp, zsp]
#             print("stop ", stop)
            lario3d.hard_max!(stop, data_size)
        #     new_stop = zeros(eltype(stop), size(stop)...)
#             print("stop ", stop)
            oxst = xst
            oyst = yst
            ozst = zst
            oxsp, oysp, ozsp = stop
            outdata = data3d[oxst:oxsp, oyst:oysp, ozst:ozsp]
        else
#             print(" end of col, row or slice ", bsub, "\n")

    #         outdata = zeros(
    #             eltype(data3d),
    #             block_size[1] + margin_size,
    #             block_size[2] + margin_size,
    #             block_size[3] + margin_size
    #         )
            xst, xsp, yst, ysp, zst, zsp = data_sub_from_block_sub(
                block_size, margin_size, bsub
            )
#             "subs before: "
#             print_slice3(xst, xsp, yst, ysp, zst, zsp)
            xst, oxst, xsh = get_start_and_outstart_ind(xst, margin_size)
            yst, oyst, ysh = get_start_and_outstart_ind(yst, margin_size)
            zst, ozst, zsh = get_start_and_outstart_ind(zst, margin_size)
    #         print("[", xsh, ", ", ysh, ",", zsh, "]")
            szx, szy, szz = size(data3d)
            bszx, bszy, bszz = block_size
            xsp, oxsp = get_end_and_outend_ind(xst, xsp, szx, xsh)
            ysp, oysp = get_end_and_outend_ind(yst, ysp, szy, ysh)
            zsp, ozsp = get_end_and_outend_ind(zst, zsp, szz, zsh)
#             print(" sh[",xsh, ",", ysh, ",", zsh, "]")
#             print("postprocessing input")
            lario3d.print_slice3(xst, xsp, yst, ysp, zst, zsp)
#             print("postprocessing output")
            lario3d.print_slice3(oxst, oxsp, oyst, oysp, ozst, ozsp)
    #         print_slice3(xst, xsp, yst, ysp, zst, zsp)
    #         print_slice3(oxst, oxsp, oyst, oysp, ozst, ozsp)
            outdata = zeros(
                eltype(data3d),
                xsh + xsp - xst + 1,
                ysh + ysp - yst + 1,
                zsh + zsp - zst + 1,
        #         block_size[1] + margin_size,
        #         block_size[2] + margin_size,
        #         block_size[3] + margin_size
            )
            outdata[oxst:oxsp, oyst:oysp, ozst:ozsp] = data3d[
                xst:xsp, yst:ysp, zst:zsp
            ]
        end

    else
        oxst, oxsp, oyst, oysp, ozst, ozsp = data_sub_from_block_sub(
            block_size, margin_size, bsub
        )
#         print(oxst, ":", oxsp, ", ", oyst, ":", oysp, ", ", ozst, ":", ozsp)
        outdata = data3d[oxst:oxsp, oyst:oysp, ozst:ozsp]
        offset = [oxst, oyst, ozst]
    end
    offset = [oxst - 1, oyst - 1, ozst - 1]
    sz = [oxsp - oxst + 1, oysp - oyst + 1, ozsp - ozst + 1]


    return outdata, offset, sz
end


function get_start_and_outstart_ind(xst, margin_size)
    if xst < 1
        oxst = 2 - xst
        xst = 1
        xshift = oxst - xst
    else
        oxst = 1
        xshift = 0
        # xst = xst
    end
    return xst, oxst, xshift
end

function get_end_and_outend_ind(xst, xsp, szx, xsh)
    if szx < xsp
#         print("A", xsh)
        oxsp = 1 + szx - xst
        xsp = szx
    else
#         print("B", xsh)
        oxsp = 1 + xsp - xst + xsh
        # xsp = xsp
    end
    return xsp, oxsp
end

"""
Get cartesian indices for data from block cartesian indices.
No out of bounds check is performed.
"""
function data_sub_from_block_sub(block_size::ArrayOrTuple, margin_size::Int, bsub)
    xst = (block_size[1] * (bsub[1] - 1)) + 1 - margin_size
    xsp = (block_size[1] * (bsub[1] + 0)) + 0 + margin_size
    yst = (block_size[2] * (bsub[2] - 1)) + 1 - margin_size
    ysp = (block_size[2] * (bsub[2] + 0)) + 0 + margin_size
    zst = (block_size[3] * (bsub[3] - 1)) + 1 - margin_size
    zsp = (block_size[3] * (bsub[3] + 0)) + 0 + margin_size
    return xst, xsp, yst, ysp, zst, zsp
end


"""
Get face IDs based on position of cube in grid. Faces IDs along each axis
are returned.

f1, f2, f3 = get_face_ids_from_cube_in_grid([1,2,3], 1, false)
"""
function get_face_ids_from_cube_in_grid(grid_size::ArrayOrTuple, cube_carthesian_position::ArrayOrTuple, trailing_face::Bool)
    if trailing_face
        trf = 1
    else
        trf = 0
    end
    sz1,sz2,sz3 = grid_size
    i, j, k = cube_carthesian_position
    f10 = (sz2 * sz3) * (i - 1 + trf)  + (j - 1) * sz3 + k
    nax1 = (1 + sz1) * sz2 * sz3
    @debug ("number of 1st axis faces: ", nax1, ", ")
    f20 = nax1 +
        (sz2 + 1) * sz3 * (i - 1)  + (j - 1 + trf) * sz3 + k

    nax2 = sz1 * (1 + sz2) * sz3
    @debug ("2st axis faces: ", nax2, ", ")
    nax3_layer = (sz3 + 1) * sz2 * (i - 1)
    nax3_row = (j - 1) * (sz3 + 1)
    @debug ("3st axis faces in one layer and in one row: ",
        nax3_layer, " ", nax3_row,  "\n")
    f30 = nax1 +  nax2 +
        nax3_layer + nax3_row  + k + trf

    return f10, f20, f30

end


function cartesian_withloops(x,y)
    leny=length(y)
    lenx=length(x)
    m=leny*lenx
    OUT = zeros(eltype(x), m,2)
    c=1
    for i = 1:lenx
        for j = 1:leny
            OUT[c,1] = x[i]
            OUT[c,2] = y[j]
            c+=1
        end
    end
    return OUT
end

"""
Get list of surface faces in inner subgrid.
"""
function cube_in_block_surface(block_size::ArrayOrTuple, cube_start::ArrayOrTuple, cube_stop::ArrayOrTuple)
    dimension = length(block_size)
    dim = 1
    inner_block_size = cube_stop - cube_start + ones(size(cube_stop))
    number_of_facelets_per_dim = zeros(Int, dimension)
    for i=1:dimension
#         print("inner_block_size ", inner_block_size, "\n")
        ones_size = copy(inner_block_size)
        facelet_size_on_this_dim = [ones_size[j] for j=1:length(ones_size) if j != i]
#         print("facelet_size", facelet_size_on_this_dim, "\n")
        number_of_facelets_per_dim[i] = prod(facelet_size_on_this_dim)

#         copy
    end
#     print("number_of_facelets_per_dim ", number_of_facelets_per_dim, "\n")
    total_number_of_facelets = sum(number_of_facelets_per_dim) * 2

    # output array
    facelet_inds = Array{Int64}(undef, total_number_of_facelets)

#     Array
#     array = Array{Int64}(undef, 5)
    ranges = [collect(cube_start[i]:cube_stop[i]) for i=1:dimension]
#     print("ranges ", ranges, "\n")
#     ranges = Array{Any}(undef, dimension)
    cart_index = zeros(Int64, dimension)
    linear_facelet_index = 1
    for i=1:dimension
        rest_dims = [j for j=1:dimension if j != i]
#         print("rest dims ", rest_dims, "\n")
        r1 = collect(cube_start[rest_dims[1]]:cube_stop[rest_dims[1]])
        r2 = collect(cube_start[rest_dims[2]]:cube_stop[rest_dims[2]])
#         print("r1 ", r1, ",", typeof(r1),"\n")
#         print("r2 ", r2, ",", typeof(r2),"\n")
        cartrange_i_dim = cartesian_withloops( r1, r2, )
#         println("cartrange_i_dim ", cartrange_i_dim)
        for k=1:size(cartrange_i_dim)[1]
            cart_index_rest = cartrange_i_dim[k, :]
            cart_index[i] = cube_start[i]
            for j=1:(dimension - 1)
                cart_index[rest_dims[j]] = cart_index_rest[j]
            end
            facelet_inds[linear_facelet_index] = get_face_ids_from_cube_in_grid(
                block_size, cart_index, false)[i]
            linear_facelet_index += 1
            cart_index[i] = cube_stop[i]
            facelet_inds[linear_facelet_index] = get_face_ids_from_cube_in_grid(
                block_size, cart_index, true)[i]
#             println("facelet_index: ", linear_facelet_index, " cart_index ", cart_index, " index rest ", cart_index_rest)
            linear_facelet_index += 1

        end


#         ranges[i] = collect(cube_start[i]:cube_stop[i])
#         ranges[i] = collect(cube_start[rest_dims[i]]:cube_stop[rest_dims[i]])
#         print("inner_block_size ", inner_block_size, "\n")
#         ones_size = copy(inner_block_size)
#         facelet_size_on_this_dim = [ones_size[j] for j=1:length(ones_size) if j != i]
#         print("facelet_size", facelet_size_on_this_dim, "\n")
#         number_of_facelets_per_dim[i] = prod(facelet_size_on_this_dim)

#         copy
    end
    return facelet_inds
end
#     rest_dims = [2, 3]
#     # shape of flat area (with dimension D-1). One dimension is 1 the other are
#     # the same
#     ones_size = copy(block_size)
#     ones_size[dim] = 1
#     # ones_size = ones(Int64, dimension)
#     # ones_size[dim] = block_size[dim]
#     ones(typeof(cube_start), ones_size...)
#     # cat(dim, )
#     # cartesian_withloops(collect(cubes_start[1]), collect(cube_stop[2]))
#     # for
#     return 1
# end
#
# function a(i)
#     return 1
function grid_voxel_cart_to_id(grid_size::ArrayOrTuple, voxel_cart::ArrayOrTuple)
    sz1,sz2,sz3 = grid_size
    i, j, k = voxel_cart
    trf = 0
    ind = (sz2 * sz3) * (i - 1 + trf)  + (j - 1) * sz3 + k
    return ind
end

function grid_voxel_cart_to_node_id(grid_size::Array{Int, 1}, voxel_cart::ArrayOrTuple)
    sz1,sz2,sz3 = grid_size + [1,1,1]
    i, j, k = voxel_cart
    trf = 0
    ind = (sz2 * sz3) * (i - 1 + trf)  + (j - 1) * sz3 + k
    return ind

end

function grid_voxel_id_to_cart(grid_size::Array{Int, 1}, ind)
#     ind = (sz2 * sz3) * (i - 1)  + (j - 1) * sz3 + k
    sz1,sz2,sz3 = grid_size
    layer = sz2*sz3
    ir = div(ind - 1, layer) + 1
    rest1 = mod(ind - 1 , layer) + 1
#     println("rest1 ", rest1)
    row = sz3
    jr = div(rest1 -1, row) + 1
    rest2 = mod(rest1 - 1, row) + 1
    kr = rest2
#     println("rests: ", rest1, " ", rest2)
    return [ir, jr, kr]
end

function grid_x_face_to_carthesian(grid_size::ArrayOrTuple, ind::Int)
    return grid_voxel_id_to_cart(grid_size, ind)
end

function grid_y_face_to_carthesian(grid_size::ArrayOrTuple, ind::Int)
#     f20 = nax1 +
#         (sz2 + 1) * sz3 * (i - 1 + trf)  + (j - 1 + trf) * sz3 + k
    sz1,sz2,sz3 = grid_size
    nax1 = (1 + sz1) * sz2 * sz3
    ind = ind - nax1

    layer = (sz2 + 1) * sz3
    ir = div(ind - 1, layer) + 1
    rest1 = mod(ind - 1, layer) + 1

    jr = div(rest1 - 1, sz3) + 1
    rest2 = mod(rest1 - 1, sz3) + 1
    kr = rest2
    return [ir, jr, kr]
end

function grid_z_face_to_carthesian(grid_size::ArrayOrTuple, ind::Int)
#     nax3_layer = (sz3 + 1) * sz2 * (i - 1)
#     nax3_row = (j - 1) * (sz3 + 1)
#     f30 = nax1 +  nax2 +
#         nax3_layer + nax3_row  + k + trf
    sz1,sz2,sz3 = grid_size
    nax1 = (1 + sz1) * sz2 * sz3
    nax2 = sz1 * (1 + sz2) * sz3
    ind = ind - nax1 - nax2

    layer = (sz3 + 1) * sz2
    ir = div(ind - 1, layer) + 1
    rest1 = mod(ind - 1, layer) + 1

    row = (sz3 + 1)
    jr = div(rest1 - 1, row) + 1
    rest2 = mod(rest1 - 1, row) + 1
    kr = rest2
    return [ir, jr, kr]
end
# end

function grid_face_id_to_cartesian(grid_size::ArrayOrTuple, fid::Int)
    sz1,sz2,sz3 = grid_size
    nax1 = (1 + sz1) * sz2 * sz3
    nax2 = sz1 * (1 + sz2) * sz3

    if fid <= nax1
        # x-face it is the same index as voxel index
        axis = 1
        voxel_cart = grid_x_face_to_carthesian(grid_size, fid)

    elseif fid <= (nax1 + nax2)
        # y-face
        axis = 2
        voxel_cart = grid_y_face_to_carthesian(grid_size, fid)
    else
        # z-face
        axis = 3
        voxel_cart = grid_z_face_to_carthesian(grid_size, fid)
    end
    return voxel_cart, axis
end


function grid_to_linear(data3d::Array, threshold=0)
    """
    Get grid linearized version of segmentation
    """
    segClin = spzeros(Int8, prod(size(data3d)), 1)
    sz = size(data3d)
    for k in 1:sz[3]
        for j in 1:sz[2]
            for i in 1:sz[1]
                if data3d[i,j,k] > threshold
                    ind = lario3d.grid_voxel_cart_to_id(size(data3d), [i,j,k])
                    segClin[ind] = 1
                end
            end
        end
    end
    return segClin
end

"""
Get face ID in original grid from its ID in subgrid.
"""
function sub_grid_face_id_to_orig_grid_face_id(data_size::ArrayOrTuple, block_size::ArrayOrTuple, offset::ArrayOrTuple, fid::Int)
    face_cart, axis = lario3d.grid_face_id_to_cartesian(block_size, fid)

    voxel_cart = face_cart + offset
    big_fids = lario3d.get_face_ids_from_cube_in_grid(data_size, voxel_cart, false)
    big_fid = big_fids[axis]
    return big_fid, voxel_cart
end

"""
Calculate number of faces in grid.
> grid_number_of_faces([5,5,5])

"""
function grid_number_of_faces(grid_size::ArrayOrTuple)
    pr = prod(grid_size)
    num = pr + grid_size[1] * grid_size[2] +
        pr + grid_size[2] * grid_size[3] +
        pr + grid_size[1] * grid_size[3]
    return num

end


function grid_face_id_to_node_ids(grid_size::ArrayOrTuple, face_id::Int)
    voxel_cart, axis = grid_face_id_to_cartesian(grid_size, fid)
    # TODO finish


end
