
include("../src/LarSurf.jl")

import SparseArrays.spzeros
import SparseArrays.dropzeros!
using Plasm
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation


segmentation = zeros(Int8, 5, 6, 7)
segmentation[2:5,2:5,2:6] .= 1
# Plasm.view(Plasm.numbering(.6)((V,[VV, EV, filteredFV])))

filteredFV, Flin, (V, tmodel) = LarSurf.get_surface_grid(segmentation)
(VV, EV, FV, CV) = tmodel
Plasm.View((V,[VV, EV, filteredFV]))




