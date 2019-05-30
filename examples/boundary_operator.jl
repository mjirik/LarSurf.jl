
include("../src/LarSurf.jl")
# include("arr_fcn.jl")

import SparseArrays.spzeros
using Plasm
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation

# using arr_fcn

block_size = [2, 2, 2]
# function get_boundary3(block_size)
V, CVill = Lar.cuboidGrid([block_size[1], block_size[2], block_size[3]])

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



# convert from list of list to 2D array
# CVi = Array{Int64}(undef, size(CVill)[1], size(CVill[1])[1])
CVi = LarSurf.ll2array(CVill)


nvertices = size(V)[2]

# CVill to sparse
print("CVill to sparse, sz: ", nc, " nvertices: ", nvertices)
VF01 = LarSurf.ind_to_sparse(VFi, nvertices, 1)
CV01 = LarSurf.ind_to_sparse(CVi, nvertices, 2)

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
# return boundary, V, FVi
# end
