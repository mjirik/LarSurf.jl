
# include("../src/lario3d.jl")
# include("../src/sampledata.jl")

using lario3d
using Plasm
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation


verts, trifaces = lario3d.hexagon()

V, EV, FE = lario3d.to_lar(verts, trifaces)

Lar.view(V, EV)
