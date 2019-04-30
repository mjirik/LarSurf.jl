using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using Plasm, SparseArrays

sz=[3, 3]


# V,(VV,EV,FV,CV) = Lar.cuboidGrid([3,3,3], true)
# V,(VV,EV,FV,CV) = Lar.cuboidGrid([sz[1], sz[2], sz[3]], false)
# V,(VV,EV,FV,CV) = Lar.cuboidGrid(sz, true)
# V,(VV,EV,FV) = Lar.cuboidGrid(sz, true)
c2 = Lar.larGridSkeleton([1,1,1])(2)
# Plasm.view( Plasm.numbering(.6)((V,[VV, EV, FV])) )
# Plasm.view( Plasm.numbering(.6)((V,[VV, EV, FV])) )
# Plasm.view( Plasm.numbering(.6)((V,[VV, EV])) )
