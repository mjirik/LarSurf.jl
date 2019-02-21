include("../src/lario3d.jl")
# include("arr_fcn.jl")

import SparseArrays.spzeros
using Plasm
using LinearAlgebraicRepresentation

Lar = LinearAlgebraicRepresentation

# 3D 3x3x3

ibf = lario3d.inner_boundary_filter([3, 3, 3])
