# tmux attach
# source activate julia
# julia -p 3 experiments/exp_surface_extraction_run.jl
# Ctrl-b d


# paper note
# the deinit with nothing, automatic end of while true
# using Revise
using Test
using Logging
using Distributed
@info "distributed loaded"
if nprocs() == 1
    addprocs(3)
end


using Dates
using ExSu

@everywhere using LarSurf

@info "LarSurf everywhere"
# global_logger(SimpleLogger(stdout, Logging.Debug))
# # set logger on all workers
# for wid in workers()
#     @spawnat wid global_logger(SimpleLogger(stdout, Logging.Debug))
# end


fn = "exp_surface_extraction5_test.csv"

# Number of logical CPU cores available in the system.
# println("CPU cores: ", Sys.CPU_CORES)
Sys.cpu_summary()
# Number of available processes.
number_procs = nprocs()
number_workers = nworkers()
println("nprocs: ", nprocs())
println("nworkers: ", nworkers())

include("prepare_data.jl")

general_prepare_data = LarSurf.generate_almost_cube
general_prepare_data = LarSurf.generate_cube

segmentation = LarSurf.generate_cube(10)

fcns = [
    # TODO prepare
    # LarSurf.get_surface_grid_per_block_Vreduced_FVreduced_parallel,
    # LarSurf.get_surface_grid_per_block_Vreduced_FVreduced_fixed_block_size,
    # LarSurf.get_surface_grid_per_block_Vreduced_FVreduced_old,
    # LarSurf.get_surface_grid_per_block_Vreduced_FVreduced,
    # LarSurf.get_surface_grid_per_block_FVreduced,
    # LarSurf.get_surface_grid_per_block_full,
    # LarSurf.get_surface_grid_old,
    # LarSurf.get_surface_grid,
    LarSurf.lsp_get_surface,
    # LarSurf.get_surface_grid_per_voxel,
]
# set last two are with one parameter
nargs = 1 * ones(Int64, length(fcns))
# nargs[end-1:end] .= 1
# inargs = [segmentation, block_size]
fcns_nargs = collect(zip(fcns, nargs))

# it is list with just fast functions
# fcns_fast = fcns_nargs[1:end-4]
fcns_fast = fcns_nargs
fcns_all  = fcns_nargs

@info "Nuber of functions per experiment: $(length(fcns_all))"

# = 17.6.
# # set last two are with one parameter
# nargs = 2 * ones(Int64, length(fcns))
# nargs[end-1:end] .= 1
# # inargs = [segmentation, block_size]
# fcns_nargs = collect(zip(fcns, nargs))
#
# # it is list with just fast functions
# fcns_fast = fcns_nargs[1:end-4]
# fcns_all  = fcns_nargs


# fcns_nargs_local = fcns_nargs[1:end]
# end
# fcns_nargs = [
#     (fcns[i], nargs[])
#     # (fcns[i], inargs[1:nargs[i]])
#     for i=1:length(fcns)
# ]



# Warm up on small data
@info "First Warm Up..."
block_size = [2,2,2]
LarSurf.lsp_setup(block_size)
for (fcni, nargs) in fcns_nargs
    @debug "running on small segmentation with size $(size(segmentation))"
    argsi = [segmentation, block_size]
    fcni(argsi[1:nargs]...)
end
@info "...done"


function save_data(experiment, timed, segmentation, b3_size, append_dct)
    tm = timed[2]
    al = timed[3]
    println(" time=$tm, alloc=$al ", append_dct["fcn"])
    dct = Dict()
    # dct = ExSu.timed_and_more_to_dict!(dct, timed;experiment=experiment)
    dct = ExSu.timed_to_dict!(dct, timed)
    dct = ExSu.datetime_to_dict!(dct)
    dct["experiment"] = experiment
    dct = ExSu.segmentation_description_to_dict!(dct, segmentation)
    dct = ExSu.size_to_dict!(dct, b3_size, "boundary3_")
    if append_dct != nothing
        merge!(dct, append_dct)
    end
    ExSu.add_to_csv(dct, fn)
end


"""
fcns_nargs_local
"""
function run_measurement(
    fcns_nargs_local, prepare_data_parameter, block_size,
    experiment=nothing; append_dct=nothing, skip_slow=false, data_fcn=nothing)
    if experiment == nothing
        experiment = "time measurement"
    end

    # LasRurf.set_block_size(block_size) # this is done by fallowing function too
    LarSurf.lsp_setup(block_size)

    println(experiment)
    if data_fcn == nothing
        prepare_data = general_prepare_data
    else
        prepare_data = data_fcn
    end

    segmentation = prepare_data(prepare_data_parameter)
    for (fcni, nargs) in fcns_nargs_local
        @info "==== Running $(String(Symbol(fcni)))"
        argsi = [segmentation, block_size]
        tmd = @timed(fcni(argsi[1:nargs]...))
        if append_dct == nothing
            append_dct = Dict()
        end
        append_dct["fcn"] = String(Symbol(fcni))
        append_dct["nprocs"] = number_procs
        append_dct["nworkers"] = number_workers
        append_dct["jlfile"] = @__FILE__
        append_dct["hostname"] = gethostname()
        append_dct["ncores"] = length(Sys.cpu_info())
        append_dct["data parameter"] = prepare_data_parameter


        save_data(experiment, tmd, segmentation, block_size, append_dct)
    end
    println("============================")
end

# Warming
@info "Warming..."
run_measurement(fcns_all , 10, [1,1,1] .*  8, "warming")
run_measurement(fcns_fast, 20, [1,1,1] .* 16, "warming"; skip_slow=true)
run_measurement(fcns_fast, 40, [1,1,1] .* 32, "warming"; skip_slow=true)
run_measurement(fcns_fast, 70, [1,1,1] .* 64, "warming"; skip_slow=true)
@info "...done"

for i=1:0
    @info "small scale experiments"
    ## Small
    block_size = [1,1,1] .* 16
    # LarSurf.lsp_setup(block_size)
    run_measurement(fcns_fast,  40, block_size, "small b3")
    run_measurement(fcns_fast,  40, block_size, "small b3")
    run_measurement(fcns_fast,  40, block_size, "small b3")

    ## Datasize, constant b3

    block_size = [1,1,1] .* 64
    # LarSurf.lsp_setup(block_size)
    run_measurement(fcns_fast,  20, block_size, "data size")
    run_measurement(fcns_fast,  40, block_size, "data size")
    run_measurement(fcns_fast,  80, block_size, "data size")
    run_measurement(fcns_fast, 160, block_size, "data size")
#     block_size = [1,1,1] .* 32
#     # LarSurf.lsp_setup(block_size)
#     run_measurement(fcns_fast, 512, [1,1,1] .*  8, "boundary size big 32")
#     run_measurement(fcns_fast, 512, [1,1,1] .* 16, "boundary size big 32")
#     run_measurement(fcns_fast, 512, [1,1,1] .* 32, "boundary size big 32")
#     run_measurement(fcns_fast, 512, [1,1,1] .* 64, "boundary size big 32")
end

# Experiments
for i=1:0
    @info "fist experiments"
    block_size = [1,1,1] .* 64
    run_measurement(fcns_fast, 320, block_size, "data size")
    run_measurement(fcns_fast, 512, block_size, "data size")

    ## Boundary matrix size

    run_measurement(fcns_fast, 100, [1,1,1] .*  8, "boundary size")
    run_measurement(fcns_fast, 100, [1,1,1] .* 16, "boundary size")
    run_measurement(fcns_fast, 100, [1,1,1] .* 32, "boundary size")
    run_measurement(fcns_fast, 100, [1,1,1] .* 64, "boundary size")
    # run_measurement(fcns_fast,100, [1,1,1] .* 64, "data size"; skip_slow=true)
end

for i=1:0
    @info "slow experiments"
    # block_size = [1,1,1] .* 32
    # LarSurf.lsp_setup(block_size)
    # run_measurement(fcns_fast, 512, [1,1,1] .*  8, "boundary size big 32")
    # run_measurement(fcns_fast, 512, [1,1,1] .* 16, "boundary size big 32")
    # run_measurement(fcns_fast, 512, [1,1,1] .* 32, "boundary size big 32")
    # run_measurement(fcns_fast, 512, [1,1,1] .* 64, "boundary size big 32")

    run_measurement(fcns_fast, 512, [1,1,1] .*  8, "boundary size big")
    run_measurement(fcns_fast, 512, [1,1,1] .* 16, "boundary size big")
    run_measurement(fcns_fast, 512, [1,1,1] .* 32, "boundary size big")
    run_measurement(fcns_fast, 512, [1,1,1] .* 64, "boundary size big")
end


# CT data
for i=1:20
    @info "CT data"
    # block_size = [1,1,1] .* 32
    # LarSurf.lsp_setup(block_size)
    # run_measurement(fcns_fast, 512, [1,1,1] .*  8, "boundary size big 32")
    # run_measurement(fcns_fast, 512, [1,1,1] .* 16, "boundary size big 32")
    # run_measurement(fcns_fast, 512, [1,1,1] .* 32, "boundary size big 32")
    # run_measurement(fcns_fast, 512, [1,1,1] .* 64, "boundary size big 32")

    run_measurement(fcns_fast, i, [1,1,1] .*  64, "Ircadb1"; data_fcn=prepare_ircad)
end
