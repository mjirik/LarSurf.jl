using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using Plasm, SparseArrays

sz=[3, 3, 3]
sz=[2, 2, 2]
# sz=[5, 6, 7]


# V,(VV,EV,FV,CV) = Lar.cuboidGrid([3,3,3], true)
V,(VV,EV,FV,CV) = Lar.cuboidGrid(sz, true)

# Plasm.view( Plasm.numbering(.6)((V,[VV, EV, FV])) )
Plasm.view( Plasm.numbering(.6)((V,[VV, EV, FV])) )
