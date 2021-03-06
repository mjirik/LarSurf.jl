# check speed of new and old sparse filter

using Revise
using LarSurf
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using Plasm, SparseArrays
using Pandas
using Seaborn
using Dates
using Logging

using Profile
using ProfileView


b3, something = LarSurf.get_boundary3([30,30,30])
LarSurf.sparse_filter!(b3, 1, 1, 0)
LarSurf.sparse_filter_old!(b3, 1, 1, 0)
println("start")
@time LarSurf.sparse_filter!(b3, 1, 1, 0)
@time LarSurf.sparse_filter!(b3, 1, 1, 0)
@time LarSurf.sparse_filter!(b3, 1, 1, 0)
@time LarSurf.sparse_filter!(b3, 1, 1, 0)
@time LarSurf.sparse_filter!(b3, 1, 1, 0)

println("asdf")
# b3 = LarSurf.get_boundary3([30,30,30])
@time LarSurf.sparse_filter_old!(b3, 1, 1, 0)
# b3 = LarSurf.get_boundary3([30,30,30])
@time LarSurf.sparse_filter_old!(b3, 1, 1, 0)
@time LarSurf.sparse_filter_old!(b3, 1, 1, 0)
@time LarSurf.sparse_filter_old!(b3, 1, 1, 0)
@time LarSurf.sparse_filter_old!(b3, 1, 1, 0)
