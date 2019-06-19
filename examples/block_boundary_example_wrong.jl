# include("../src/LarSurf.jl")

using LarSurf
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using Plasm, SparseArrays




threshold = 4000
pth = LarSurf.datasets_join_path("medical/orig/sample-data/nrn4.pklz")
datap = Io3d.read3d(pth)

data3d = datap["data3d"]
# segmentation = convert(Array{Int8, 2}, data3d .> threshold)
segmentation = data3d .> threshold

coord_vect_of_segment = [Int8(segmentation[k]) for k=1:length(segmentation)]




# coord_vect_of_segment = [x>0.25 ? 1 : 0  for x in rand(size(∂_2,1)) ]

# V,(_,_,FV,CV) = Lar.cuboidGrid([32,32,16], true)
sz = size(data3d)
V,(_,_,FV,CV) = Lar.cuboidGrid([sz[1], sz[2], sz[3]], true)
∂_2 = Lar.u_coboundary_2( CV, FV)
coord_vect_of_all_3D_cells  = ones(size(∂_2,1),1)
coord_vect_of_boundary_2D_cells = ∂_2' * coord_vect_of_all_3D_cells .% 2
out = coord_vect_of_boundary_2D_cells
boundary_2cells = [ FV[f] for f in findnz(SparseArrays.sparse(out))[1] ]
hpc = Plasm.lar2exploded_hpc(V, boundary_2cells)(1.3,1.3,1.3)
Plasm.view(hpc)
out = ∂_2' * coord_vect_of_segment .% 2
boundary_2cells = [ FV[f] for f in findnz(SparseArrays.sparse(out))[1] ]
hpc = Plasm.lar2exploded_hpc(V, boundary_2cells)(1.,1.,1.)
Plasm.view(hpc)
