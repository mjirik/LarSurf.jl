# include("../src/lario3d.jl")

using Revise
using lario3d
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using Plasm, SparseArrays




## Read data from file
# threshold = 4000
# pth = lario3d.datasets_join_path("medical/orig/sample-data/nrn4.pklz")
# datap = lario3d.read3d(pth)
#
# data3d = datap["data3d"]
# data_size = lario3d.size_as_array(size(data3d))
# segmentation = data3d .> threshold


## Generate data
segmentation = lario3d.generate_slope([26,27,28])
data_size = lario3d.size_as_array(size(segmentation))


# filteredFV, Flin, V, model = lario3d.get_surface_grid(segmentation)
# (VV, EV, FV, CV) = model
# Plasm.View((V,[VV, EV, filteredFV]))

bigV, (bigVV, bigEV, bigFV, bigCV) = Lar.cuboidGrid(data_size, true)

bigFsparse = spzeros(Int8, size(bigFV)[1], 1)

block_size = [5, 5, 5]
margin_size = 0
block_number, blocks_number_axis = lario3d.number_of_blocks_per_axis(
    data_size, block_size)



bigFchar = spzeros(Int8, length(bigFV))
Flin = Nothing
println("block number ", block_number, " block size: ", block_size, "margin size: ", margin_size,
" block number axis: ", blocks_number_axis)
for block_i=1:block_number
#     print("block_i: ", block_i)
    block1, offset1, sz1 = lario3d.get_block(
        segmentation, block_size, margin_size, blocks_number_axis, block_i
    )
    println(" offset: ", offset1, " size: ", sz1)
    # offset1 = [0,0,0]
#     segmentation1 = block1 .> threshold
    segmentation1 = block1

    filteredFVi, Flin, V, model = lario3d.get_surface_grid(segmentation1)
    (VV, EV, FV, CV) = model
#     Plasm.View((V,[VV, EV, filteredFV]))
#     print("Flin ", Flin)

# face from small to big


# fid_subgrid = [i for i=1:size(Flin)[2] if 0 < Flin[1,i]]

    for fid=1:length(Flin)
        if (Flin[fid] == 1)

            big_fid = lario3d.sub_grid_face_id_to_orig_grid_face_id(data_size, block_size, offset1, fid)
            bigFchar[big_fid] += 1


        end
    end
# filtered_bigFV = [
#     bigFV[lario3d.sub_grid_face_id_to_orig_grid_face_id(data_size, block_size, offset1, fid)]
#     )
# ]
end

# Get FV and filter double faces on the border
filtered_bigFV = [
    bigFV[i] for i=1:length(bigFchar) if bigFchar[i] == 1
]
# filtered_bigFV = [
#     bigFV[lario3d.sub_grid_face_id_to_orig_grid_face_id(data_size, block_size, offset1, fid)]
#     for fid=1:length(Flin) if (Flin[fid] == 1)
# ]


Plasm.View((bigV,[bigVV, bigEV, filtered_bigFV]))
# for fid=1:size(Flin)[2]
#     if 0 < Flin[1,fid]
#         big_fid = lario3d.sub_grid_face_id_to_orig_grid_face_id(data_size, block_size, offset1, fid)
#         bigFchar[big_fid] = 1
#     end
# end

# lario3d.grid_face_id_to_cartesian(block_size, )
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
# #       lario3d.sub_grid_face_id_to_orig_face_id(data_size, block_size, [0,0,0], )
#       # perform sparse wizardry...
#    end
# end