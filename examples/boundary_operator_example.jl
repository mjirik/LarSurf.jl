
include("../src/lario3d.jl")

import SparseArrays.spzeros
import SparseArrays.dropzeros!
using Plasm
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation


segmentation = zeros(Int8, 5, 6, 7)
segmentation[2:5,2:5,2:6] .= 1
# Plasm.view(Plasm.numbering(.6)((V,[VV, EV, filteredFV])))

filteredFV, Flin, V, model = lario3d.get_surface(segmentation)
(VV, EV, FV, CV) = model
Plasm.View((V,[VV, EV, filteredFV]))




