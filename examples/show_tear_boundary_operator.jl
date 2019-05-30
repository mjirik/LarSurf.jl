include("../src/LarSurf.jl")
using Plasm
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
# using LarSurf

threshold = 4000
pth = LarSurf.datasets_join_path("medical/orig/sample-data/nrn4.pklz")
datap = LarSurf.read3d(pth)

data3d = datap["data3d"]
# segmentation = convert(Array{Int8, 2}, data3d .> threshold)
segmentation = data3d .> threshold

segmentation_linear_int = [Int8(segmentation[k]) for k=1:length(segmentation)]

b3, V, FVi = LarSurf.get_boundary3(size(data3d))


segmentation_arr2 = reshape(segmentation_linear_int, length(segmentation), 1)

faces = b3' * segmentation_arr2

selected_faces = FVi .* faces
FVill = [selected_faces[k, :] for k=1:size(selected_faces,1) if any(selected_faces[k, :] .!= 0)]
# Plasm.view(V, FVill)(2, 2, 2)
# block_size = [5, 5, 5]
# margin_size = 0

## Artifical data
# data3d = ones(Int16, 3, 3, 3)
# data3d[2, 2, 2] = 10
# data3d

# voxelsize_mm = [0.5, 1.0, 2.]
# threshold=0


# include("../src/LarSurf.jl")

# import SparseArrays.spzeros
# using Plasm
# using LinearAlgebraicRepresentation
# Lar = LinearAlgebraicRepresentation

# block_size = [2, 2, 2]
# block_size = size(data3d)
# b3 = LarSurf.get_boundary3(block_size)

# blocks_number, blocks_number_axis = LarSurf.number_of_blocks_per_axis(
#     size(data3d), block_size)
#
#
# block1 = LarSurf.get_block(
#     data3d, block_size, margin_size, blocks_number_axis, false, 1
# )
#
# verts, trifaces = LarSurf.import_data3d(data3d, voxelsize_mm, 4000)
#
# println(verts)
#
#
# println(trifaces)
#
#
# println("======= To LAR ========")
#
# V, EV, FE = LarSurf.to_lar(verts, trifaces)
#
# println(V)
# println(EV)
# println(FE)
#
# println("V: ", typeof(V), size(V))
# println("EV: ", typeof(EV))
# print("FV: ", typeof(FE))
#
# @show EV;
#
#
# # convert to list of lists
# # trifaces_list = [trifaces[k, :] for k=1:size(trifaces,1)]
# trifaces_list = [trifaces[k, 3:-1:1] for k=1:size(trifaces,1)]
# Vt = permutedims(V, [2,1])
#
# # Plasm.view(Lar.cuboid([1,1,1]))
#
# # Plasm.view(Vt, trifaces_list)
# Plasm.viewexploded(V, selected_faces)(2,2,2)
