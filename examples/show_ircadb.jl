# conda install -c mjirik io3d
# python -m io3d -l 3Dircadb1.1

include("../src/lario3d.jl")
using Plasm
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
# using lario3d

pth = lario3d.datasets_join_path("medical/orig/3Dircadb1.1/MASKS_DICOM/liver")
datap = lario3d.read3d(pth)

data3d = datap["data3d"]
voxelsize_mm = datap["voxelsize_mm"]
print(voxelsize_mm)

block_size = [50, 50, 50]
margin_size = 0
step = 10

## Artifical data
# data3d = ones(Int16, 3, 3, 3)
# data3d[2, 2, 2] = 10
# data3d

# voxelsize_mm = [1.0, 1.0, 1.0]
threshold=0



println("min max ", Int16(minimum(data3d)), " ", Int16(maximum(data3d)))


blocks_number, blocks_number_axis = lario3d.number_of_blocks_per_axis(
size(data3d), block_size)
#
#
block1 = lario3d.get_block(
    data3d, block_size, margin_size, blocks_number_axis, 1
)


verts, trifaces = lario3d.import_data3d(data3d[1:step:end, 1:step:end, 1:step:end], voxelsize_mm, 100)

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


# convert to list of lists
# trifaces_list = [trifaces[k, :] for k=1:size(trifaces,1)]
trifaces_list = [trifaces[k, 3:-1:1] for k=1:size(trifaces,1)]
Vt = permutedims(V, [2,1])

# Plasm.view(Lar.cuboid([1,1,1]))

# Plasm.view(Vt, trifaces_list)
Plasm.viewexploded(Vt, trifaces_list)(2,2,2)
