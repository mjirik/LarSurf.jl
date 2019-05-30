
# include("../src/LarSurf.jl")
# include("../src/sampledata.jl")

using LarSurf
using Plasm
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation


verts, trifaces = LarSurf.hexagon()

V, EV, FE = LarSurf.to_lar(verts, trifaces)

Lar.view(V, EV)
