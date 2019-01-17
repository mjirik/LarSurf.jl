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
    a = Array{Int}(undef, blocks[1], blocks_number[2], blocks_number[3])
    bi = CartesianIndices(a)[block_i]

    compare = (bi .== blocks_number_axis[1])
    if (compare[1] || compare[2] || copare[3])
        print("end of col, row or slice")
        outdata = similar(data3d, dims=block_size)

    else
        xst = block_size[1] * blocks_number_axis[1] * (bi[1] + 0)
        xsp = block_size[1] * blocks_number_axis[1] * (bi[1] + 1)
        yst = block_size[2] * blocks_number_axis[2] * (bi[2] + 0)
        ysp = block_size[2] * blocks_number_axis[2] * (bi[2] + 1)
        zst = block_size[3] * blocks_number_axis[3] * (bi[3] + 0)
        zsp = block_size[3] * blocks_number_axis[3] * (bi[3] + 1)
        outdata = data3d[xst:xsp, yst:ysp, zst:zsp]
    end
    return outdata
end
