using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using Plasm, SparseArrays


sz=[2,3,4]
# V,(VV,EV,FV,CV) = Lar.cuboidGrid([sz[1], sz[2], sz[3]], true)
V,(VV,EV,FV,CV) = Lar.cuboidGrid([sz[1], sz[2], sz[3]], false)
# Plasm.view( Plasm.numbering(.6)((V,[VV, EV, FV])) )
# Plasm.view( Plasm.numbering(.6)((V,[VV, EV, FV])) )
