
include("../src/lario3d.jl")

import SparseArrays.spzeros
using Plasm
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation

block_size = 2

V, CVill = Lar.cuboidGrid([block_size, block_size, block_size])

# A lot of work can be done by this:
# V, (VV, EV, FV, CV) = Lar.cuboidGrid([2,2,2], true)

# CVill to FVi
nc = size(CVill)[1]
nfaces_per_C = 6
nfaces = nfaces_per_C * nc
FVi = Array{Int64}(undef, nfaces, 4)
#     println(sz)
# produce faces
for k in 1:nc
    cube_points = CVill[k]
    FVi[(k - 1) * nfaces_per_C + 1, :] = cube_points[[1, 2, 4, 3]]
    FVi[(k - 1) * nfaces_per_C + 2, :] = cube_points[[1, 5, 6, 2]]
    FVi[(k - 1) * nfaces_per_C + 3, :] = cube_points[[1, 3, 7, 5]]
    FVi[(k - 1) * nfaces_per_C + 4, :] = cube_points[[3, 4, 8, 7]]
    FVi[(k - 1) * nfaces_per_C + 5, :] = cube_points[[2, 6, 8, 4]]
    FVi[(k - 1) * nfaces_per_C + 6, :] = cube_points[[6, 5, 8, 7]]
end

VFi = convert(Array{Int64, 2}, FVi')

# """
# Input is list of lists
# Output is 2D Array
# """
# function ll2array(CVill)
    

# convert from list of list to 2D array
# CVi = Array{Int64}(undef, size(CVill)[1], size(CVill[1])[1])
CVi = Array{Int64}(undef, size(CVill)[1], size(CVill[1])[1])

for k in 1:nc
    CVi[k, :] = CVill[k]
end

nvertices = size(V)[2]

# CVill to sparse
print("CVill to sparse, sz: ", nc, " nvertices: ", nvertices)

CV01 = spzeros(Int8, nc, nvertices)
nvertices_per_C = size(CVi)[2]

for k in 1:nc
    for i in 1:nvertices_per_C
        print("vert k: ", k,", i: ", i)
        vertind = CVi[k, i]
        print(" vert ind: ", vertind, "\n")
        CV01[k, vertind] = 1
    end
end

# VF to sparse
print("VF to sparse")
nfaces = size(VFi)[2]
VF01 = spzeros(Int8, nvertices, nfaces)

for k in 1:size(VFi)[1]
    for i in 1:(size(VFi)[2])
        # print("vert k: ", k,", i: ", i)
        vertind = VFi[k, i]
        # print(" vert ind: ", vertind, "\n")
        VF01[vertind, i] = 1
    end
end


boundary_numbers = CV01 * VF01

# take just o

boundary = boundary_numbers .== 4

boundary = convert(Array{Int8, 2}, boundary)

# list of lists

FVill = [FVi[k, :] for k=1:size(FVi,1)]

# Plasm.view(V, CVill)
# Plasm.viewexploded(V, CVill)(2,2,2)
# Plasm.viewexploded(V, FVill)(2,2,2)
print("boundary stats (#true, # false): ", sum(boundary .== true), ", ", sum(boundary .== false) )
