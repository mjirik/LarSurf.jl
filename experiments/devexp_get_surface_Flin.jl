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

block_size=[4,4,4]

segmentation = lario3d.generate_segmentation567(20)
lario3d.grid_get_surface_Flin(segmentation)
segmentation = lario3d.generate_segmentation567(1)
Flin1, larmodel1 = lario3d.grid_get_surface_Flin(segmentation)
Flin2, larmodel2 = lario3d.grid_get_surface_Flin_old(segmentation)
V1, top1 = larmodel1
V2, top2 = larmodel2
(VV1, EV1, FV1, CV1) = top1
(VV2, EV2, FV2, CV2) = top2


Flin_block1 = lario3d.__grid_get_surface_Fchar_per_block(segmentation, block_size)
Flin_block2 = lario3d.__grid_get_surface_Fchar_per_block_old_implementation(segmentation, block_size)

for i=1:size(Flin_block1,1)
    if Flin_block1[i] == Flin_block2[i]
    else
        if (Flin_block2[i] == 2) & (Flin_block1[i]==0)
        else
            error("Flin implementation does not fit, $i")
        end
    end
end

@timeit to "size10" begin
    for i=1:5
        @timeit to "full" begin
            @timeit to "new" lario3d.grid_get_surface_Flin(segmentation)
            @timeit to "old" lario3d.grid_get_surface_Flin_old(segmentation)
        end
        @timeit to "per block" begin
            @timeit to "new" lario3d.__grid_get_surface_Fchar_per_block(segmentation, block_size)
            @timeit to "old" lario3d.__grid_get_surface_Fchar_per_block_old_implementation(segmentation, block_size)
        end
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
