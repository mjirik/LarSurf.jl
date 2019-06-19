
# include("../src/LarSurf.jl")

using LarSurf
import SparseArrays.spzeros
import SparseArrays.dropzeros!
using Plasm, SparseArrays
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation



# threshold = 4000
# pth = Io3d.datasets_join_path("medical/orig/sample-data/nrn4.pklz")
# segmentation = LarSurf.generate_slope([5,6,7])
segmentation = LarSurf.generate_slope([15,16,17])

# data3d = datap["data3d"]
# segmentation = data3d .> threshold
# data_size = LarSurf.size_as_array(size(data3d))
#
# segmentation = zeros(Int8, 5, 6, 7)
# segmentation[2:5,2:5,2:6] .= 1
# Plasm.view(Plasm.numbering(.6)((V,[VV, EV, filteredFV])))

filteredFV, Flin, V, model = LarSurf.get_surface_grid(segmentation)
(VV, EV, FV, CV) = model
Plasm.View((V,[VV, EV, filteredFV]))




