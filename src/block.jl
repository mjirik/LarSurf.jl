#=
block:
- Julia version:
- Author: miros
- Date: 2019-01-16
=#

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

    compare = (tuple(bsub) .== blocks_number_axis)
    if (compare[1] || compare[2] || compare[3])
        print("end of col, row or slice")
        outdata = similar(data3d, dims=block_size)
        xst, xsp, yst, ysp, zst, zsp = data_sub_from_block_sub(
            block_size, margin_size, bsub
        )

    else
        xst, xsp, yst, ysp, zst, zsp = data_sub_from_block_sub(
            block_size, margin_size, bsub
        )
        print(xst, ":", xsp, ", ", yst, ":", ysp, ", ", zst, ":", zsp)
        outdata = data3d[xst:xsp, yst:ysp, zst:zsp]
    end
    return outdata
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
