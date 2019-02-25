using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using Plasm, SparseArrays

include("../src/lario3d.jl")

sz=[3, 3, 3]
sz=[5, 4, 3]
# sz=[1, 2, 3]


# V,(VV,EV,FV,CV) = Lar.cuboidGrid([3,3,3], true)
V,(VV,EV,FV,CV) = Lar.cuboidGrid(sz, true)

# Plasm.view( Plasm.numbering(.6)((V,[VV, EV, FV])) )


faces = lario3d.get_face_ids_from_cube_in_grid(sz, [2, 2, 2], false)

print(faces)

Plasm.view( Plasm.numbering(.6)((V,[VV, EV, FV])) )

FVfiltered = [FV[faces[i]] for i=1:length(faces)]

Plasm.view( Plasm.numbering(.6)((V,[VV, FVfiltered])) )
