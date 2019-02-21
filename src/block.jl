#=
block:
- Julia version:
- Author: miros
- Date: 2019-01-16
=#

include("print_function.jl")

"""
seg3d
"""
function number_of_blocks_per_axis(seg3d_size, block_size)
    # print("ahoj")
    blocks_number = Array{Int}(undef, nfields(seg3d_size))
    for k in 1:nfields(seg3d_size)
        # print(k)
        delenec = seg3d_size[k]
        delitel = block_size[k]
        number_for_this_axis = cld(delenec, delitel)
        # print(" ", delenec, ", ", delitel, ", ", number_for_this_axis)

        blocks_number[k] = number_for_this_axis
    end
    return prod(blocks_number), blocks_number
end

function get_block(data3d, block_size, margin_size, blocks_number_axis, block_i)
    a = Array{Int}(
        undef,
        blocks_number_axis[1],
        blocks_number_axis[2],
        blocks_number_axis[3]
    )
    print("block_i: ", block_i)
    bsub = CartesianIndices(a)[block_i]
    bsub_arr = [bsub[1], bsub[2], bsub[3]]

    first = (bsub_arr .== [1, 1, 1])
    last = (bsub_arr .== blocks_number_axis)
    print(bsub, blocks_number_axis, " first last ", first, last, "\n")
    if any(first) || any(last)
        print("end of col, row or slice ", bsub, "\n")

        outdata = zeros(
            eltype(data3d),
            block_size[1] + margin_size,
            block_size[2] + margin_size,
            block_size[3] + margin_size
        )
        xst, xsp, yst, ysp, zst, zsp = data_sub_from_block_sub(
            block_size, margin_size, bsub
        )
        print_slice3(xst, xsp, yst, ysp, zst, zsp)
        xst, oxst, xsh = get_start_and_outstart_ind(xst, margin_size)
        yst, oyst, ysh = get_start_and_outstart_ind(yst, margin_size)
        zst, ozst, zsh = get_start_and_outstart_ind(zst, margin_size)
        print("[", xsh, ", ", ysh, ",", zsh, "]")
        szx, szy, szz = size(data3d)
        bszx, bszy, bszz = block_size
        xsp, oxsp = get_end_and_outend_ind(xst, xsp, szx, xsh)
        ysp, oysp = get_end_and_outend_ind(yst, ysp, szy, ysh)
        zsp, ozsp = get_end_and_outend_ind(zst, zsp, szz, zsh)
        print_slice3(xst, xsp, yst, ysp, zst, zsp)
        print_slice3(oxst, oxsp, oyst, oysp, ozst, ozsp)
        outdata[oxst:oxsp, oyst:oysp, ozst:ozsp] = data3d[
            xst:xsp, yst:ysp, zst:zsp
        ]

    else
        xst, xsp, yst, ysp, zst, zsp = data_sub_from_block_sub(
            block_size, margin_size, bsub
        )
        print(xst, ":", xsp, ", ", yst, ":", ysp, ", ", zst, ":", zsp)
        outdata = data3d[xst:xsp, yst:ysp, zst:zsp]
    end
    return outdata
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
        print("A", xsh)
        oxsp = 1 + szx - xst
        xsp = szx
    else
        print("B", xsh)
        oxsp = 1 + xsp - xst + xsh
        # xsp = xsp
    end
    return xsp, oxsp
end

"""
Get cartesian indices for data from block cartesian indices.
No out of bounds check is performed.
"""
function data_sub_from_block_sub(block_size, margin_size, bsub)
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

f1, f2, f3 = get_face_ids_from_cube_in_grid([1,2,3])
"""
function get_face_ids_from_cube_in_grid(grid_size, cube_carthesian_position)
    sz1,sz2,sz3 = grid_size
    i, j, k = cube_carthesian_position
    f10 = (sz2 * sz3) * (i - 1)  + (j - 1) * sz3 + k
    nax1 = (1 + sz1) * sz2 * sz3
    @debug ("number of 1st axis faces: ", nax1, ", ")
    f20 = nax1 +
        (sz2 + 1) * sz3 * (i - 1)  + (j - 1) * sz3 + k

    nax2 = sz1 * (1 + sz2) * sz3
    @debug ("2st axis faces: ", nax2, ", ")
    nax3_layer = (sz3 + 1) * sz2 * (i - 1)
    nax3_row = (j - 1) * (sz3 + 1)
    @debug ("3st axis faces in one layer and in one row: ",
        nax3_layer, " ", nax3_row,  "\n")
    f30 = nax1 +  nax2 +
        nax3_layer + nax3_row  + k

    return f10, f20, f30

end
