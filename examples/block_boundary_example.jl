# include("../src/LarSurf.jl")

using Revise
using LarSurf
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using Plasm, SparseArrays

using Pio3d



## Read data from file
# threshold = 4000
# pth = Pio3d.datasets_join_path("medical/orig/sample-data/nrn4.pklz")
# datap = Pio3d.read3d(pth)
#
# data3d = datap["data3d"]
# data_size = LarSurf.size_as_array(size(data3d))
# segmentation = data3d .> threshold


## Generate data
segmentation = LarSurf.generate_slope([9,10,11])
filteredFV, Flin, (V, model) = LarSurf.get_surface_grid_per_block(segmentation, [2,3,4])
# LarSurf.get_surface
# filtered_bigFV = [
#     bigFV[LarSurf.sub_grid_face_id_to_orig_grid_face_id(data_size, block_size, offset1, fid)]
#     for fid=1:length(Flin) if (Flin[fid] == 1)
# ]


Plasm.View((bigV,[bigVV, bigEV, filtered_bigFV]))
# for fid=1:size(Flin)[2]
#     if 0 < Flin[1,fid]
#         big_fid = LarSurf.sub_grid_face_id_to_orig_grid_face_id(data_size, block_size, offset1, fid)
#         bigFchar[big_fid] = 1
#     end
# end

# LarSurf.grid_face_id_to_cartesian(block_size, )
# A = Flin
# rows = rowvals(A)
# vals = nonzeros(A)
# m, n = size(A)
# for i = 1:n
#    for j in nzrange(A, i)
#       row = rows[j]
#       val = vals[j]
#       print("row: ", row)
#       print("col: ", j)
#       print("col: ", i)
#       println("val: ", val)
# #       LarSurf.sub_grid_face_id_to_orig_face_id(data_size, block_size, [0,0,0], )
#       # perform sparse wizardry...
#    end
# end
