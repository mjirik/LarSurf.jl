#=
surface_to_obj:
- Julia version: 1.1.0
- Author: Jirik
- Date: 2019-04-10
=#

# include("../src/lario3d.jl")
tim = time()
# using Revise
using lario3d
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using Plasm, SparseArrays
using Pandas
using Seaborn

tim_prev = tim
tim = time()
println("using done in: ", tim - tim_prev)
threshold = 10

xystep = 10
zstep = 5
xystep = 20
zstep = 10
pth = lario3d.datasets_join_path("medical/orig/3Dircadb1.1/MASKS_DICOM/liver")

datap = lario3d.read3d(pth);
#
data3d_full = datap["data3d"]
println("orig size: ", size(data3d_full))
data3d = data3d_full[1:zstep:end, 1:xystep:end, 1:xystep:end];

data_size = lario3d.size_as_array(size(data3d))
println("data size: ", data_size)
segmentation = data3d .> threshold;

tim_prev = tim
tim = time()
println("data read complete in time: ", tim - tim_prev)

# Run once to force compilation
## Generate data
# segmentation = lario3d.generate_slope([9,10,11])
block_size = [5,5,5]
filtered_bigFV, Flin, bigV, model = lario3d.get_surface_grid_per_block(segmentation, block_size)
bigVV, bigEV, bigFV, bigCV = model

V = bigV
FV = filtered_bigFV
nV = size(bigV)[2]
# First method for computation of EV
EV = []
for f in FV
	push!(EV, [[f[1],f[2]],[f[3],f[4]],  [f[1],f[3]],[f[2],f[4]]])
end
doubleedges = sort(cat(EV))
doubleedges = convert(Lar.Cells, doubleedges)
EV = [doubleedges[k] for k=1:2:length(doubleedges)]



# Plasm.view(V,EV)

# Computing copFE
# kEV = Lar.characteristicMatrix(EV);
aFV = lario3d.ll2array(FV)
kFV = lario3d.characteristicMatrix(aFV, nV);

aEV = lario3d.ll2array(EV)
kEV = lario3d.characteristicMatrix(aEV, nV);
kFE = kFV * kEV'
I,J,Value = SparseArrays.findnz(kFE)
triples = hcat([[i,j,1] for (i,j,v) in zip(I,J,Value) if v == 2 ]...)
I,J,Value = [triples[k,:] for k=1:size(triples,1)]
copFE = SparseArrays.sparse(I,J,Value)
copFE = convert(SparseMatrixCSC{Int8,Int64},copFE)
FE = [findnz(copFE[k,:])[1] for k=1:length(FV)]
copFE = Lar.coboundary_1(V,kFV,kEV)

# Assembling the chain complex cc
copCF = SparseArrays.ones(Int8,1,size(kFV,1))
copCF = convert(Lar.ChainOp, copCF)
cc = [kEV, copFE, copCF]::Lar.ChainComplex

# View a surface triangulation
V = convert(Lar.Points,V')
triangles = cat(Lar.triangulate(V::Lar.Points, cc[1:2]))
TV = convert(Lar.Cells,triangles)
V = convert(Lar.Points,V')
Plasm.view(Plasm.hpc_exploded( (V,[TV]) )(1.2,1.2,1.2))

# Export an OBJ file of the surface
V = convert(Lar.Points,V')
open("testfile.obj","w") do f
    print(f, Lar.lar2obj(V::Lar.Points, cc) )
end
