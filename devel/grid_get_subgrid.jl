#=
grid_get_subgrid:
- Julia version: 1.1.0
- Author: Jirik
- Date: 2019-03-29
=#



function data_sub_from_block_sub(block_size, margin_size, bsub)
    xst = (block_size[1] * (bsub[1] - 1)) + 1 - margin_size
    xsp = (block_size[1] * (bsub[1] + 0)) + 0 + margin_size
    yst = (block_size[2] * (bsub[2] - 1)) + 1 - margin_size
    ysp = (block_size[2] * (bsub[2] + 0)) + 0 + margin_size
    zst = (block_size[3] * (bsub[3] - 1)) + 1 - margin_size
    zsp = (block_size[3] * (bsub[3] + 0)) + 0 + margin_size
    return xst, xsp, yst, ysp, zst, zsp
end

function number_of_blocks_per_axis(seg3d_size, block_size)
    println("block_size: ", block_size)
    if typeof(block_size) == Tuple{Int64}
        dim = nfields(seg3d_size)
    elseif  typeof(block_size) == Array{Int64, 1}
        dim = length(block_size)
    else
        warn("Unknown type of block_size")
    end
    println( "dim:", dim, " seg size:", seg3d_size, " block size: ", block_size)

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


function limit_by!(stop, data_size)
    for i=1:length(stop)
        if data_size[i] < stop[i]
            stop[i] = data_size[i]
        end
    end
    return stop
end


    segmentation = LarSurf.generate_slope([11,12,13])
    data_size = LarSurf.size_as_array(size(segmentation))
    data3d = segmentation
    block_size = [2,3,4]
    block_i = 91
    margin_size = 0


    block_number, blocks_number_axis = number_of_blocks_per_axis(data_size, block_size)
    a = Array{Int}(
        undef,
        blocks_number_axis[1],
        blocks_number_axis[2],
        blocks_number_axis[3]
    )
    bsub = CartesianIndices(a)[block_i]
#     faces = LarSurf.cube_in_block_surface([1,2,3], [1,1,1], [1,2,2])
    bsub_arr = [bsub[1], bsub[2], bsub[3]]

    first = (bsub_arr .== [1, 1, 1])
    last = (bsub_arr .== blocks_number_axis)

    # if margin_size == 0

    xst, xsp, yst, ysp, zst, zsp = LarSurf.data_sub_from_block_sub(
        block_size, margin_size, bsub
    )
    stop = [xsp, ysp, zsp]
    print("stop ", stop)
    limit_by!(stop, data_size)
#     new_stop = zeros(eltype(stop), size(stop)...)
    print("stop ", stop)

#     if data_size[1] < xsp
#         xsp = data_size[1]
#     end
#     if data_size[1] < xsp
#         xsp = data_size[1]
#     end
