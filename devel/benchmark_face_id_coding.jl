using Revise
using BenchmarkTools
using LarSurf

function get_block_cart_calcul(blocks_number_axis, block_i)

    z = div(block_i, blocks_number_axis[1] * blocks_number_axis[2])
    rest = mod(block_i, blocks_number_axis[1] * blocks_number_axis[2])
    y = div(rest, blocks_number_axis[1])
    rest = mod(rest, blocks_number_axis[2])
    x = rest
    return [x,y,z]
end

bl1 = get_block_cart_calcul([10,10,10], 125)
println(bl1)
bl2 = get_block_cart_cartind([10,10,10], 125)
println(bl2)
bl3 = LarSurf.grid_voxel_id_to_cart([10,10,10], 125)
println(bl3)

function get_block_cart_cartind(blocks_number_axis, block_i)
    a = Array{Int}(
        undef,
        blocks_number_axis[1],
        blocks_number_axis[2],
        blocks_number_axis[3]
    )
#     print("block_i: ", block_i)
    # TODO maybe the cartesian index is slow
    bsub = CartesianIndices(a)[block_i]
    return bsub
end



blocks_number_axis = [10,10,10]
a = Array{Int}(
    undef,
    blocks_number_axis[1],
    blocks_number_axis[2],
    blocks_number_axis[3]
)

function get_block_cart_cartind_extern(blocks_number_axis, block_i)
#     print("block_i: ", block_i)
    # TODO maybe the cartesian index is slow
    bsub = CartesianIndices(a)[block_i]
    return bsub
end



bm = @benchmark get_block_cart_cartind([10,10,10], 472)
display(bm)

bm = @benchmark get_block_cart_calcul([10,10,10], 472)
display(bm)

bm = @benchmark LarSurf.grid_voxel_id_to_cart([10,10,10], 472)
display(bm)

bm = @benchmark get_block_cart_cartind_extern([10,10,10], 472)
display(bm)
