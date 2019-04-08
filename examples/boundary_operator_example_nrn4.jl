
# include("../src/lario3d.jl")

using lario3d
import SparseArrays.spzeros
import SparseArrays.dropzeros!
using Plasm, SparseArrays
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation



threshold = 4000
pth = lario3d.datasets_join_path("medical/orig/sample-data/nrn4.pklz")
datap = lario3d.read3d(pth)

data3d = datap["data3d"]
segmentation = data3d .> threshold
# data_size = lario3d.size_as_array(size(data3d))
#
# segmentation = zeros(int8, 5, 6, 7)
# segmentation[2:5,2:5,2:6] .= 1
# plasm.view(plasm.numbering(.6)((v,[vv, ev, filteredfv])))

filteredfv, flin, v, model = lario3d.get_surface_grid(segmentation)
(vv, ev, fv, cv) = model
plasm.view((v,[vv, ev, filteredfv]))




