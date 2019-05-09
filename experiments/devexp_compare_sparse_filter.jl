# check speed of new and old sparse filter

using Revise
using lario3d
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using Plasm, SparseArrays
using Pandas
using Seaborn
using Dates
using Logging

using Profile
using ProfileView


b3, something = lario3d.get_boundary3([30,30,30])
lario3d.sparse_filter!(b3, 1, 1, 0)
lario3d.sparse_filter_old!(b3, 1, 1, 0)
println("start")
@time lario3d.sparse_filter!(b3, 1, 1, 0)
@time lario3d.sparse_filter!(b3, 1, 1, 0)
@time lario3d.sparse_filter!(b3, 1, 1, 0)
@time lario3d.sparse_filter!(b3, 1, 1, 0)
@time lario3d.sparse_filter!(b3, 1, 1, 0)

println("asdf")
# b3 = lario3d.get_boundary3([30,30,30])
@time lario3d.sparse_filter_old!(b3, 1, 1, 0)
# b3 = lario3d.get_boundary3([30,30,30])
@time lario3d.sparse_filter_old!(b3, 1, 1, 0)
@time lario3d.sparse_filter_old!(b3, 1, 1, 0)
@time lario3d.sparse_filter_old!(b3, 1, 1, 0)
@time lario3d.sparse_filter_old!(b3, 1, 1, 0)
