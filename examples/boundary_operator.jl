
include("../src/lario3d.jl")

import SparseArrays.spzeros
using Plasm
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation

V, CV = Lar.cuboidGrid([1,1,1])

# CV to FV
sz = size(CV)[1]
nfaces_per_C = 6
nfaces = nfaces_per_C * sz
faces = Array{Int64}(undef, nfaces, 4)
#     println(sz)
# produce faces
for k in 1:sz
    cube_points = CV[k]
    faces[(k - 1) * nfaces_per_C + 1, :] = cube_points[[1, 2, 4, 3]]
    faces[(k - 1) * nfaces_per_C + 2, :] = cube_points[[1, 5, 6, 2]]
    faces[(k - 1) * nfaces_per_C + 3, :] = cube_points[[1, 3, 7, 5]]
    faces[(k - 1) * nfaces_per_C + 4, :] = cube_points[[3, 4, 8, 7]]
    faces[(k - 1) * nfaces_per_C + 5, :] = cube_points[[2, 6, 8, 4]]
    faces[(k - 1) * nfaces_per_C + 6, :] = cube_points[[6, 5, 8, 7]]
end

# list of lists

faces_list = [faces[k, :] for k=1:size(faces,1)]

# Plasm.view(V, CV)
# Plasm.viewexploded(V, CV)(2,2,2)
Plasm.viewexploded(V, faces_list)(2,2,2)

faces_t = convert(Array{Int64, 2}, faces')


# convert from list of list to 2D array
cv = Array{Int64}(undef, size(CV)[1], size(CV[1])[1])

for k in 1:sz
    cv[k, :] = CV[k]
end

nvertices = size(V)[2]

# CV to sparse

CV01 = spzeros(Int8, sz, nvertices)

for k in 1:sz
    for j in 1:nvertices
        CV01[k, cv[k, j]] = 1
    end
end

# VF to sparse
nfaces = size(faces_t)[2]
VF01 = spzeros(Int8, nvertices, nfaces)

for k in 1:size(faces_t)[1]
    for i in 1:(size(faces_t)[2])
        VF01[faces_t[k, i], k] = 1
    end
end


boundary = CV01 * VF01
