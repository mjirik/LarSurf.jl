
using Test
using Logging
using Revise
using lario3d
using Plasm
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation

function prepare_data(factor::Integer)
    segmentation = zeros(Int8, 5*factor, 6*factor, 7*factor)
    segmentation[2*factor:5*factor,2*factor:5*factor,2*factor:6*factor] .= 1
    return segmentation

end

segmentation = prepare_data(1)

# Warm up
larmodel1 = lario3d.get_surface_grid_per_block_full(segmentation, [2,2,2])
larmodel2 = lario3d.get_surface_grid_per_block_FVreduced(segmentation, [2,2,2])
larmodel3 = lario3d.get_surface_grid_per_block_Vreduced_FVreduced(segmentation, [2,2,2])


function run_measurement(segmentation_size_factor, b3_size; skip_full=false)
    lario3d.get_boundary3(b3_size) # prepare boundary3 in memory
    segmentation = prepare_data(segmentation_size_factor)

    segsize = size(segmentation)
    println("Segmentation size: $segsize, boundary size: $b3_size")
    println("Fchar comp. = boundary matrix mul and index reconstruction")
    @time Fchar = lario3d.__grid_get_surface_Fchar_per_block(segmentation, b3_size)
    data_size = lario3d.size_as_array(size(segmentation))
    println("just V and FV computation")
    @time lario3d.grid_Fchar_to_Vreduced_FVreduced(Fchar, data_size)
    @time lario3d.grid_Fchar_to_V_FVreduced(Fchar, data_size)
    if ~skip_full
        @time lario3d.grid_Fchar_to_V_FVfulltoreduced(Fchar, data_size)
    end
    println("full surface = Fchar, V and FV computation")
    @time larmodel3 = lario3d.get_surface_grid_per_block_Vreduced_FVreduced(segmentation, b3_size)
    @time larmodel2 = lario3d.get_surface_grid_per_block_FVreduced(segmentation, b3_size)
    if ~skip_full
        @time larmodel1 = lario3d.get_surface_grid_per_block_full(segmentation, b3_size)
    end

    println("============================")
end

run_measurement(1, [2,2,2])
run_measurement(5, [2,2,2])
run_measurement(5, [16,16,16])
run_measurement(10, [2,2,2])
run_measurement(10, [16,16,16])
run_measurement(15, [16,16,16])
# run_measurement(10, [2,2,2])
run_measurement(20, [16,16,16]; skip_full=true)
run_measurement(40, [16,16,16]; skip_full=true)
run_measurement(40, [32,32,32]; skip_full=true)
run_measurement(40, [64,64,64]; skip_full=true)
run_measurement(50, [32,32,32]; skip_full=true)
run_measurement(60, [32,32,32]; skip_full=true)
