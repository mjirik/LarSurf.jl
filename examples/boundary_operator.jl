
include("../src/lario3d.jl")

import SparseArrays.spzeros
using Plasm
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation

block_size = 2

V, CV = Lar.cuboidGrid([block_size, block_size, block_size])

# CV to FV
nc = size(CV)[1]
nfaces_per_C = 6
nfaces = nfaces_per_C * nc
faces_i = Array{Int64}(undef, nfaces, 4)
#     println(sz)
# produce faces
for k in 1:nc
    cube_points = CV[k]
    faces_i[(k - 1) * nfaces_per_C + 1, :] = cube_points[[1, 2, 4, 3]]
    faces_i[(k - 1) * nfaces_per_C + 2, :] = cube_points[[1, 5, 6, 2]]
    faces_i[(k - 1) * nfaces_per_C + 3, :] = cube_points[[1, 3, 7, 5]]
    faces_i[(k - 1) * nfaces_per_C + 4, :] = cube_points[[3, 4, 8, 7]]
    faces_i[(k - 1) * nfaces_per_C + 5, :] = cube_points[[2, 6, 8, 4]]
    faces_i[(k - 1) * nfaces_per_C + 6, :] = cube_points[[6, 5, 8, 7]]
end

# list of lists

faces_list = [faces_i[k, :] for k=1:size(faces_i,1)]

# Plasm.view(V, CV)
# Plasm.viewexploded(V, CV)(2,2,2)
# Plasm.viewexploded(V, faces_list)(2,2,2)

faces_t = convert(Array{Int64, 2}, faces_i')


# convert from list of list to 2D array
cv = Array{Int64}(undef, size(CV)[1], size(CV[1])[1])

for k in 1:nc
    cv[k, :] = CV[k]
end

nvertices = size(V)[2]

# CV to sparse
print("CV to sparse, sz: ", nc, " nvertices: ", nvertices)

CV01 = spzeros(Int8, nc, nvertices)
nvertices_per_C = size(cv)[2]

for k in 1:nc
    for i in 1:nvertices_per_C
        # print("vert k: ", k,", i: ", i)
        vertind = cv[k, i]
        # print(" vert ind: ", vertind, "\n")
        CV01[i, vertind] = 1
    end
end

# VF to sparse
print("VF to sparse")
nfaces = size(faces_t)[2]
VF01 = spzeros(Int8, nvertices, nfaces)

for k in 1:size(faces_t)[1]
    for i in 1:(size(faces_t)[2])
        # print("vert k: ", k,", i: ", i)
        vertind = faces_t[k, i]
        # print(" vert ind: ", vertind, "\n")
        VF01[vertind, i] = 1
    end
end


boundary_numbers = CV01 * VF01

# take just o

boundary = boundary_numbers .== 4
