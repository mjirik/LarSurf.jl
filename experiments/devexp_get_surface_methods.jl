
using Revise
using LarSurf
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using Plasm, SparseArrays
using Pandas
using Seaborn
using Dates
using Logging

using TimerOutputs

const to = TimerOutput()
# Compilation
# block_size=[4,4,4]
#
# segmentation = LarSurf.generate_segmentation567(1)
# Flin1, larmodel1 = LarSurf.grid_get_surface_Flin(segmentation)
# Flin2, larmodel2 = LarSurf.grid_get_surface_Flin_old(segmentation)
# Flin_block2 = LarSurf.__grid_get_surface_Fchar_per_block_old_implementation(segmentation, block_size)
# V1, top1 = larmodel1
# V2, top2 = larmodel2
# (VV1, EV1, FV1, CV1) = top1
# (VV2, EV2, FV2, CV2) = top2


segmentation = LarSurf.generate_almost_cube(100)
println("segmentation size: ", size(segmentation))
block_size=[16,16,16]


function one_test_iteration(to)
    print("=")
    @timeit to "surf" LarSurf.get_surface_grid(segmentation)
    @timeit to "surf old" LarSurf.get_surface_grid_old(segmentation)
    print(".")
    @timeit to "surf block" LarSurf.get_surface_grid_per_block(segmentation, block_size)
    @timeit to "surf block full" LarSurf.get_surface_grid_per_block_full(segmentation, block_size)
    print(".")
    @timeit to "surf block FVr" LarSurf.get_surface_grid_per_block_FVreduced(segmentation, block_size)
    @timeit to "surf block Vr FVr" LarSurf.get_surface_grid_per_block_Vreduced_FVreduced(segmentation, block_size)
    print(".")
    @timeit to "surf block Vr FVr fixed" LarSurf.get_surface_grid_per_block_Vreduced_FVreduced_fixed_block_size(segmentation, block_size)
    @timeit to "surf block Vr FVr old" LarSurf.get_surface_grid_per_block_Vreduced_FVreduced_old(segmentation, block_size)
    print(".")
    @timeit to "surf block VR FVr parallel" LarSurf.get_surface_grid_per_block_Vreduced_FVreduced_parallel(segmentation, block_size)
    print(".")
    return to
end

println("Warming...")
one_test_iteration(to)
println("Evaluation")


reset_timer!(to)

@timeit to "size20" begin
    for i=1:2
        one_test_iteration(to)
    end
end

display(to)
#
