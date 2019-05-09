
using Test
using Logging
using Revise
using lario3d
using Plasm
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation

fn = "exp_full_reduced.csv"

prepare_data = lario3d.generate_segmentation567

segmentation = prepare_data(1)

# Warm up
larmodel1 = lario3d.get_surface_grid_per_block_full(segmentation, [2,2,2])
larmodel2 = lario3d.get_surface_grid_per_block_FVreduced(segmentation, [2,2,2])
larmodel3 = lario3d.get_surface_grid_per_block_Vreduced_FVreduced(segmentation, [2,2,2])

function save_data(experiment, timed, segmentation, b3_size)
    tm = timed[2]
    al = timed[3]
    println(" time=$tm, alloc=$al")
    dct = Dict()
    dct = lario3d.timed_to_dict!(dct, timed;experiment=experiment)
    dct = lario3d.segmentation_description_to_dict!(dct, segmentation)
    dct = lario3d.size_to_dict!(dct, b3_size, "boundary3_")
    lario3d.add_to_csv(dct, fn)
end


function run_measurement(segmentation_size_factor, b3_size; skip_full=false)
    lario3d.get_boundary3(b3_size) # prepare boundary3 in memory
    segmentation = prepare_data(segmentation_size_factor)

    segsize = size(segmentation)
    println("Segmentation size: $segsize, boundary size: $b3_size")
    println("Fchar comp. = boundary matrix mul and index reconstruction")
    tmd = @timed(lario3d.__grid_get_surface_Fchar_per_block(segmentation, b3_size))
    Fchar = tmd[1]
    save_data("Fchar", tmd, segmentation, b3_size)
    data_size = lario3d.size_as_array(size(segmentation))
    println("just V and FV computation")
    tmd = @timed(lario3d.grid_Fchar_to_Vreduced_FVreduced(Fchar, data_size))
    save_data("Vr and FVr", tmd, segmentation, b3_size)
    tmd = @timed(lario3d.grid_Fchar_to_V_FVreduced(Fchar, data_size))
    save_data("V and FVr", tmd, segmentation, b3_size)
    if ~skip_full
        tmd = @timed(lario3d.grid_Fchar_to_V_FVfulltoreduced(Fchar, data_size))
        save_data("V and FVfr", tmd, segmentation, b3_size)
    end
    println("full surface = Fchar, V and FV computation")
    tmd = @timed(lario3d.get_surface_grid_per_block_Vreduced_FVreduced(segmentation, b3_size))
    save_data("seg Vr and FVr", tmd, segmentation, b3_size)
    tmd = @timed(lario3d.get_surface_grid_per_block_FVreduced(segmentation, b3_size))
    save_data("seg V and FVr", tmd, segmentation, b3_size)
    if ~skip_full
        tmd = @timed(lario3d.get_surface_grid_per_block_full(segmentation, b3_size))
        save_data("seg V and FVfr", tmd, segmentation, b3_size)
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
run_measurement(70, [32,32,32]; skip_full=true)
run_measurement(80, [32,32,32]; skip_full=true)
