using BenchmarkTools
using LarSurf

# function grid_voxel_id_to_cart(grid_size::Array{Int, 1}, ind::Int64)
function grid_voxel_id_to_cart_calcul(grid_size, ind)
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
    return [kr, jr, ir]
end



function grid_voxel_id_to_cart_cartind(blocks_number_axis, block_i)
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
_cart = Array{Int}(
    undef,
    blocks_number_axis[1],
    blocks_number_axis[2],
    blocks_number_axis[3]
)

function grid_voxel_id_to_cart_extern(blocks_number_axis, block_i)
#     print("block_i: ", block_i)
    # TODO maybe the cartesian index is slow
    bsub = CartesianIndices(_cart)[block_i]
    return bsub
end


bl1 = grid_voxel_id_to_cart_calcul([10,10,10], 125)
println(bl1)
bl2 = grid_voxel_id_to_cart_cartind([10,10,10], 125)
println(bl2)
# bl3 = LarSurf.grid_voxel_id_to_cart([10,10,10], 125)
bl3 = grid_voxel_id_to_cart_extern([10,10,10], 125)
println(bl3)


bm = @benchmark grid_voxel_id_to_cart_calcul([10,10,10], 472)
display(bm)

bm = @benchmark grid_voxel_id_to_cart_cartind([10,10,10], 472)
display(bm)

bm = @benchmark grid_voxel_id_to_cart_extern([10,10,10], 472)
display(bm)


# bm = @benchmark LarSurf.grid_voxel_id_to_cart([10,10,10], 472)
# display(bm)
