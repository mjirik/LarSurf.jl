println("First line of the script")
time_start = time()
using Distributed
if nprocs() == 1
    addprocs(3)
end
# using Revise
using Test
using Logging
using SparseArrays
using ExSu
# using ExSu


fn = "exp_surface_extraction_cube_times.csv"
data = Dict()

@info "before everywhere using"
@info "time from start: $(time()-time_start) [s]"
# using Plasm
@everywhere using LarSurf
@everywhere using Distributed


# block_size = [64, 64, 64]
block_size = [16, 16, 16]
data_size1 = 128
# data_size1 = 256
# data_size1 = 512

LarSurf.set_time_data(data)

data["nprocs"] = nprocs()
# data["fcn"] = String(Symbol(fcni))
data["nprocs"] = nprocs()
data["nworkers"] = nworkers()
data["jlfile"] = @__FILE__
data["hostname"] = gethostname()
data["ncores"] = length(Sys.cpu_info())
data["data size"] = data_size1
data["block size"] = block_size[1]

data["using done"] = time()-time_start
# segmentation = LarSurf.data234()
@info "Generate data..."
@info "time from start: $(time()-time_start) [s]"
segmentation = LarSurf.generate_cube(data_size1; remove_one_pixel=true)
@info "==== using done, data generated time from start: $(time()-time_start) [s]"
data["data generated"] = time()-time_start

@info "Setup..."
setup_time = @elapsed LarSurf.lsp_setup(block_size;reference_time=time_start)
println("setup time: $setup_time")
@info "==== setup done, time from start: $(time()-time_start) [s]"
data["setup done"] = time()-time_start
# for wid in workers()
#     # println("testing on $wid")
#     ftr = @spawnat wid LarSurf._single_boundary3
#     @test fetch(ftr) != nothing
# end

# @debug "Setup done"
tmd = @timed LarSurf.lsp_get_surface(segmentation)
val, tm, mem, gc = tmd
println("Total time: $tm")
@info "==== finished, time from start: $(time()-time_start) [s]"
data["finished"] = time()-time_start
ExSu.datetime_to_dict!(data)
ExSu.add_to_csv(data, fn)


# Plasm.view(val)
