include("../src/LarSurf.jl")
using Plasm
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
# using LarSurf


block_size = [5, 5, 5]
margin_size = 0

## Artifical data
data3d = ones(Int16, 19, 15, 31)
data3d[2:14,8:13,9:11] .= 10
# data3d

voxelsize_mm = [0.5, 0.9, 0.8]
threshold=0


blocks_number, blocks_number_axis = LarSurf.number_of_blocks_per_axis(
    size(data3d), block_size)


block1 = LarSurf.get_block(
    1, data3d, block_size, margin_size, blocks_number_axis, false
)

verts, trifaces = LarSurf.import_data3d(block1, voxelsize_mm)

println(verts)
println(trifaces)


println("======= To LAR ========")

V, EV, FE = LarSurf.to_lar(verts, trifaces)

println(V)
println(EV)
println(FE)

println("V: ", typeof(V), size(V))
println("EV: ", typeof(EV))
print("FV: ", typeof(FE))

@show EV;
