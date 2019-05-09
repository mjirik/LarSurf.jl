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

# using Profile
# using ProfileView
using TimerOutputs

const to = TimerOutput()

segmentation = lario3d.generate_segmentation567(20)
lario3d.grid_get_surface_Flin(segmentation)
segmentation = lario3d.generate_segmentation567(10)
lario3d.grid_get_surface_Flin_old(segmentation)

@timeit to "size10" begin
    for i=1:5
        @timeit to "new" lario3d.grid_get_surface_Flin(segmentation)
        @timeit to "old" lario3d.grid_get_surface_Flin_old(segmentation)
    end
end
segmentation = lario3d.generate_segmentation567(20)
@timeit to "size20" begin
    for i=1:5
        @timeit to "new" lario3d.grid_get_surface_Flin(segmentation)
        @timeit to "old" lario3d.grid_get_surface_Flin_old(segmentation)
    end
end

to
#
