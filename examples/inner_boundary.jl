include("../src/LarSurf.jl")
# include("arr_fcn.jl")

import SparseArrays.spzeros
using Plasm
using LinearAlgebraicRepresentation

Lar = LinearAlgebraicRepresentation

# 3D 3x3x3

ibf = LarSurf.inner_boundary_filter([3, 3, 3])
