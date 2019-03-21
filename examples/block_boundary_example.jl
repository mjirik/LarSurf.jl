# include("../src/lario3d.jl")

using lario3d
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using Plasm, SparseArrays




threshold = 4000
pth = lario3d.datasets_join_path("medical/orig/sample-data/nrn4.pklz")
datap = lario3d.read3d(pth)

data3d = datap["data3d"]
# segmentation = convert(Array{Int8, 2}, data3d .> threshold)
# segmentation = data3d .> threshold

# filteredFV, Flin, V, model = lario3d.get_surface_grid(segmentation)
# (VV, EV, FV, CV) = model
# Plasm.View((V,[VV, EV, filteredFV]))

bigV, (bigVV, bigEV, bigFV, bigCV) = Lar.cuboidGrid(lario3d.size_as_array(block_size), true)

bigFsparse = spzeros(Int8, size(bigFV)[1], 1)

block_size = [5,5,5]
margin_size = 0
blocks_number, blocks_number_axis = lario3d.number_of_blocks_per_axis(
    size(data3d), block_size)
block1 = lario3d.get_block(
    data3d, block_size, margin_size, blocks_number_axis, 1
)
segmentation = block1 .> threshold

filteredFV, Flin, V, model = lario3d.get_surface_grid(segmentation)
(VV, EV, FV, CV) = model
Plasm.View((V,[VV, EV, filteredFV]))

# face from small to big
fid = 15

lario3d.grid_face_id_to_cartesian(block_size, )
# A = Flin
# rows = rowvals(A)
# vals = nonzeros(A)
# m, n = size(A)
# for i = 1:n
#    for j in nzrange(A, i)
#       row = rows[j]
#       val = vals[j]
#       # perform sparse wizardry...
#    end
# end