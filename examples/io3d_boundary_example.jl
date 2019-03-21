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
segmentation = data3d .> threshold

filteredFV, Flin, V, model = lario3d.get_surface_grid(segmentation)
(VV, EV, FV, CV) = model
Plasm.View((V,[VV, EV, filteredFV]))
