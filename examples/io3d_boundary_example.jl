# include("../src/LarSurf.jl")

using LarSurf
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using Plasm, SparseArrays




threshold = 4000
pth = LarSurf.datasets_join_path("medical/orig/sample-data/nrn4.pklz")
datap = LarSurf.read3d(pth)

data3d = datap["data3d"]
# segmentation = convert(Array{Int8, 2}, data3d .> threshold)
segmentation = data3d .> threshold

(V, filtered_topology), Flin, (Vfull, tmodel) = LarSurf.get_surface_grid(segmentation)
(VV, EV, FV, CV) = tmodel
filteredFV = filtered_topology[1]
Plasm.View((V,[VV, EV, filteredFV]))
