include("../src/lario3d.jl")
using Plasm
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
# using lario3d


block_size = [5, 5, 5]
margin_size = 0

## Artifical data
data3d = ones(Int16, 3, 3, 3)
data3d[2, 2, 2] = 10
# data3d

voxelsize_mm = [0.5, 0.9, 0.8]
threshold=0


# blocks_number, blocks_number_axis = lario3d.number_of_blocks_per_axis(
#     size(data3d), block_size)
#
#
# block1 = lario3d.get_block(
#     data3d, block_size, margin_size, blocks_number_axis, 1
# )
#
verts, trifaces = lario3d.import_data3d(data3d, voxelsize_mm)

println(verts)


println(trifaces)


println("======= To LAR ========")

V, EV, FE = lario3d.to_lar(verts, trifaces)

println(V)
println(EV)
println(FE)

println("V: ", typeof(V), size(V))
println("EV: ", typeof(EV))
print("FV: ", typeof(FE))

@show EV;
