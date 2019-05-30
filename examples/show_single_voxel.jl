include("../src/LarSurf.jl")
using Plasm
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
# using LarSurf


block_size = [5, 5, 5]
margin_size = 0

## Artifical data
data3d = ones(Int16, 3, 3, 3)
data3d[2, 2, 2] = 10
# data3d

voxelsize_mm = [0.5, 1.0, 2.]
threshold=0


verts, trifaces = LarSurf.import_data3d(data3d, voxelsize_mm, 1)

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


# convert to list of lists
# trifaces_list = [trifaces[k, :] for k=1:size(trifaces,1)]
# this is not general
trifaces_list = [trifaces[k, 3:-1:1] for k=1:size(trifaces,1)]
Vt = permutedims(V, [2,1])

# Plasm.view(Lar.cuboid([1,1,1]))

Plasm.view(Vt, trifaces_list)
Plasm.viewexploded(Vt, trifaces_list)(2,2,2)
