include("../src/lario3d.jl")
# using lario3d


block_size = [5, 5, 5]
margin_size = 0

## Artifical data
data3d = ones(Int16, 19, 15, 31)
data3d[2:14,8:13,9:11] .= 10
# data3d

voxelsize_mm = [0.5, 0.9, 0.8]
threshold=0


blocks_number, blocks_number_axis = lario3d.number_of_blocks_per_axis(
    size(data3d), block_size)


block1 = lario3d.get_block(
    data3d, block_size, margin_size, blocks_number_axis, 1
)

verts, trifaces = lario3d.import_data3d(block1, voxelsize_mm)

println(verts)
println(trifaces)


println("======= To LAR ========")

V, EV, FE = lario3d.to_lar(verts, trifaces)

println(V)
print(typeof(V))
println(EV)
print(typeof(EV))
println(FE)
print(typeof(FE))
