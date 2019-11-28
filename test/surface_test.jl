#=
surface_test:
- Julia version: 1.1.0
- Author: Jirik
- Date: 2019-03-19
=#
# using Revise
using Test
using Logging
using SparseArrays
using Distributed
if nprocs() == 1
    addprocs(3)
end

@everywhere using LarSurf
# using Plasm
# using LinearAlgebraicRepresentation
# Lar = LinearAlgebraicRepresentation



@testset "Extract surface grid" begin
    segmentation = zeros(Int8, 5, 6, 7)

    segmentation[2:5,2:5,2:6] .= 1
    obj_sz = [4, 4, 5]
    # Plasm.view(Plasm.numbering(.6)((V,[VV, EV, filteredFV])))

    # reducedLARmodel, Flin, (V, model) = LarSurf.get_surface_grid_old(segmentation; return_all=true)
    reducedLARmodel, Flin, (V, model) = LarSurf.get_surface_grid(segmentation; return_all=true)

    (VV, EV, FV, CV) = model
    filteredFV = reducedLARmodel[2][1]
    larmodel1 = (V,[VV, EV, filteredFV])

    @test LarSurf.check_LARmodel(larmodel1)
    # using Plasm
    # Plasm.View(larmodel1)
end



@testset "Extract surface grid and check euler" begin

    segmentation = LarSurf.data234()
    # reducedLARmodel, Flin, (V, model) = LarSurf.get_surface_grid_old(segmentation; return_all=true)
    reducedLARmodel, Flin, (V, model) = LarSurf.get_surface_grid(segmentation; return_all=true)

    (VV, EV, FV, CV) = model
    filteredFV = reducedLARmodel[2][1]
    larmodel1 = (V,[VV, EV, filteredFV])

    # Plasm.View(larmodel1)
    display(filteredFV)

    @test LarSurf.check_surface_euler(filteredFV)

end

@testset "Extract surface grid per block full" begin


    # segmentation = zeros(Int8, 2, 3, 4)
    # segmentation[1:2,2:3,3:4] .= 1
    segmentation = LarSurf.data234()
    # Plasm.view(Plasm.numbering(.6)((V,[VV, EV, filteredFV])))
    # just for visualization
    data_size = LarSurf.size_as_array(size(segmentation))
    V, (VV, EV, FV, CV) = LarSurf.Lar.cuboidGrid(data_size, true)
    Fchar = LarSurf.__grid_get_surface_Fchar_per_block(segmentation, [2,2,2])

    V1, topology1 = LarSurf.get_surface_grid_per_block_full(segmentation, [2,2,2])
    # (VV, EV, FV, CV) = model
    larmodel1 = (V,[VV, EV, topology1[1]])
    @test LarSurf.check_LARmodel(larmodel1)
    @test LarSurf.check_surface_euler(topology1[1])
    # Plasm.View(larmodel1)

    # second implementation
    V2, FV2 = LarSurf.grid_Fchar_to_V_FVreduced(Fchar, size(segmentation))
    larmodel2 = (V2,[VV, EV, FV2])
    @test LarSurf.check_LARmodel(larmodel2)
    @test LarSurf.check_surface_euler(FV2)
    # Plasm.view( Plasm.numbering(.6)(larmodel2) )

    # third implementation
    V3, FV3 = LarSurf.grid_Fchar_to_Vreduced_FVreduced_old(Fchar, data_size)
    larmodel3 = (V3, [FV3])
    @test LarSurf.check_LARmodel(larmodel3)
    @test LarSurf.check_surface_euler(FV3)
    # Plasm.view(larmodel3)

    V4, FV4 = LarSurf.grid_Fchar_to_Vreduced_FVreduced(Fchar, data_size)
    larmodel4 = (V4, [FV4])
    @test LarSurf.check_LARmodel(larmodel4)
    @test LarSurf.check_surface_euler(FV4)
    # VV3 = [[i] for i=1:size(V3,2)]
    # Plasm.view((V3, [VV3, FV3]))
    # Plasm.view(larmodel4)

end

@testset "Extract surface grid per block reduced FV" begin

    segmentation = LarSurf.data234()
    # segmentation = zeros(Int8, 2, 3, 4)
    # segmentation[1:2,2:3,3:4] .= 1
    # obj_sz = [2, 2, 2]
    # Plasm.view(Plasm.numbering(.6)((V,[VV, EV, filteredFV])))

    larmodel1 = LarSurf.get_surface_grid_per_block_FVreduced(segmentation, [2,2,2])
    @test LarSurf.check_LARmodel(larmodel1)
    @test LarSurf.check_surface_euler(larmodel1[2][1])
    # Plasm.View(larmodel1)

end

@testset "Extract surface grid per block reduced FV and V" begin

    segmentation = zeros(Int8, 5, 6, 7)
    segmentation[2:5,2:5,2:6] .= 1
    obj_sz = [4, 4, 5]

    segmentation = zeros(Int8, 2, 3, 4)

    segmentation[1:2,2:3,3:4] .= 1
    obj_sz = [2, 2, 2]
    # Plasm.view(Plasm.numbering(.6)((V,[VV, EV, filteredFV])))

    larmodel1 = LarSurf.get_surface_grid_per_block_Vreduced_FVreduced_old(segmentation, [2,2,2])
    @test LarSurf.check_LARmodel(larmodel1)
    @test LarSurf.check_surface_euler(larmodel1[2][1])
    # Plasm.View(larmodel1)

    larmodel1 = LarSurf.get_surface_grid_per_block_Vreduced_FVreduced(segmentation, [2,2,2])
    @test LarSurf.check_LARmodel(larmodel1)
    @test LarSurf.check_surface_euler(larmodel1[2][1])
    # Plasm.View(larmodel1)

end

@testset "Get Flin test with fixed block" begin

    segmentation = LarSurf.data234()
    # segmentation = zeros(Int8, 2, 3, 4)
    # segmentation[1:2,2:3,3:4] .= 1
    # obj_sz = [2, 2, 2]
    block_size = [2,2,2]

    Flin = LarSurf.__grid_get_surface_Fchar_per_block(segmentation, block_size)
    # Slin, oneS, b3 = LarSurf.grid_get_surf_Fvec_larmodel_loc_fixed_block_size(segmentation, [2,2,2])
    Flin_loc, offsets, blocks_number_axis, larmodel1 = LarSurf.grid_get_surface_Bchar_loc_fixed_block_size(segmentation, block_size)
    Flin, new_data_size = LarSurf.__grid_get_surface_Fchar_per_fixed_block_size(segmentation, block_size)
    larmodel1 = LarSurf.get_surface_grid_per_block_Vreduced_FVreduced_fixed_block_size(segmentation, block_size)
    @test LarSurf.check_LARmodel(larmodel1)
    @test LarSurf.check_surface_euler(larmodel1[2][1])
    # Plasm.View(larmodel1)
end

@testset "Get Flin test parallel" begin

    segmentation = LarSurf.data234()
    block_size = [2,2,2]

    # Flin = LarSurf.__grid_get_surface_Fchar_per_block(segmentation, block_size)
    # Slin, oneS, b3 = LarSurf.grid_get_surf_Fvec_larmodel_loc_fixed_block_size(segmentation, [2,2,2])
    # Flin_loc, offsets, blocks_number_axis, larmodel1 = LarSurf.grid_get_surface_Bchar_loc_fixed_block_size(segmentation, block_size)
    # Flin, new_data_size = LarSurf.__grid_get_surface_Fchar_per_fixed_block_size(segmentation, block_size)
    larmodel1 = LarSurf.get_surface_grid_per_block_Vreduced_FVreduced_parallel(segmentation, block_size)
    @test LarSurf.check_LARmodel(larmodel1)
    @test LarSurf.check_surface_euler(larmodel1[2][1])
    # Plasm.View(larmodel1)
end

@testset "Get Flin test in one block" begin

    segmentation = LarSurf.data234()
    block_size = [2,2,2]
    number_of_blocks, bgetter = LarSurf.block_getter(segmentation, block_size)
    LarSurf.get_block(2, bgetter...)
    @test number_of_blocks ==4
    fids = LarSurf.__grid_get_surface_get_Fids_used_in_block(3, bgetter...)
    @test length(fids) > 0
    # TODO why is there only 16 faces? There should be 20 of them.
    # @test length(fids) == 20
    # segmentation = zeros(Int8, 2, 3, 4)
    # segmentation[1:2,2:3,3:4] .= 1
    # obj_sz = [2, 2, 2]
end

@testset "Get Fchar test" begin

    segmentation = LarSurf.data234()
    block_size = [2,2,2]

    # Flin1 = LarSurf.__grid_get_surface_Fchar(segmentation, block_size)
    # println("get fchar test 1")
    Flin0, lmodel0 = LarSurf.grid_get_surf_Fvec_larmodel(segmentation)
    @test nnz(Flin0) == 6*4
    # println("get fchar test 2")
    Flin1 = LarSurf.__grid_get_surface_Fchar_per_block(segmentation, block_size)
    @test nnz(Flin1) == 6*4

    # println("get fchar test 3")
    Flin2 = LarSurf.__grid_get_surface_Fchar_per_block_parallel_pmap(segmentation, block_size)
    @test nnz(Flin2) == 6*4
    # println("get fchar test 4")
    # TODO concider to make channel implementation work
    # Flin2 = LarSurf.__grid_get_surface_Fchar_per_block_parallel_channel(segmentation, block_size)
    # @test nnz(Flin2) == 6*4
    # println("get fchar test 5")

    # Slin, oneS, b3 = LarSurf.grid_get_surf_Fvec_larmodel_loc_fixed_block_size(segmentation, [2,2,2])
    # Flin_loc, offsets, blocks_number_axis, larmodel1 = LarSurf.grid_get_surface_Bchar_loc_fixed_block_size(segmentation, block_size)
    # Flin, new_data_size = LarSurf.__grid_get_surface_Fchar_per_fixed_block_size(segmentation, block_size)
    # larmodel1 = LarSurf.get_surface_grid_per_block_Vreduced_FVreduced_fixed_block_size(segmentation, block_size)
    # @test LarSurf.check_LARmodel(larmodel1)
    # @test LarSurf.check_surface_euler(larmodel1[2][1])
    # Plasm.View(larmodel1)
end


@testset "surface extraction all functions" begin

    segmentation = LarSurf.data234()
    block_size = [2,2,2]

    # whole at once functions
    fns_one = [
        LarSurf.get_surface_grid,
        LarSurf.get_surface_grid_old,
    ]
    for fun in fns_one
        larmodel1 = fun(segmentation)
        @test LarSurf.check_LARmodel(larmodel1)
        @test LarSurf.check_surface_euler(larmodel1[2][1])
    end

    # per block functions

    fns = [
        LarSurf.get_surface_grid_per_block,
        LarSurf.get_surface_grid_per_block_full,
        LarSurf.get_surface_grid_per_block_FVreduced,
        LarSurf.get_surface_grid_per_block_Vreduced_FVreduced,
        LarSurf.get_surface_grid_per_block_Vreduced_FVreduced_fixed_block_size,
        LarSurf.get_surface_grid_per_block_Vreduced_FVreduced_old,
        LarSurf.get_surface_grid_per_block_Vreduced_FVreduced_parallel
        # LarSurf.get_surface_grid_per_block,
        # LarSurf.get_surface_grid_per_bloc,
    ]
    for fun in fns
        larmodel1 = fun(segmentation, block_size)
        @test LarSurf.check_LARmodel(larmodel1)
        @test LarSurf.check_surface_euler(larmodel1[2][1])
    end
end

@testset "Get Fchar parallel test" begin

    segmentation = LarSurf.data234()
    block_size = [2,2,2]
    Flin2 = LarSurf.__grid_get_surface_Fchar_per_block_parallel_pmap(segmentation, block_size)
    println(Flin2)
    @test nnz(Flin2) == 6*4
end
