println("First line of the script")
time_start = time()
using ViewerGL
using Distributed
if nprocs() == 1
    addprocs(3)
end
# using Revise
using Test
using Logging
using SparseArrays
using ExSu
using Io3d
using JLD2
# using ExSu


fn = "exp_surface_extraction_ircad_times.csv"
data = Dict()

@info "before everywhere using"
@info "time from start: $(time()-time_start) [s]"
# using Plasm
@everywhere using LarSurf
@everywhere using Distributed

@info "after everywhere using, time from start: $(time()-time_start) [s]"


block_size = [64, 64, 64]
# block_size = [128, 128, 128]
# block_size = [128, 128, 128]
# block_size = [32, 32, 32]
data_size1 = 128
# data_size1 = 256
# data_size1 = 512
data_id = 1


LarSurf.set_time_data(data)

# data["nprocs"] = nprocs()
# data["fcn"] = String(Symbol(fcni))
data["nprocs"] = nprocs()
data["nworkers"] = nworkers()
data["jlfile"] = @__FILE__
data["hostname"] = gethostname()
data["ncores"] = length(Sys.cpu_info())
data["block size"] = block_size[1]

data["using done"] = time()-time_start
# segmentation = LarSurf.data234()
@info "Generate data..."
@info "time from start: $(time()-time_start) [s]"
pth = Io3d.datasets_join_path("medical/orig/3Dircadb1.$data_id/MASKS_DICOM/liver")
datap = Io3d.read3d(pth)
data3d_full = datap["data3d"]
    # round(size(data3d_full, 1) / target_size1)
    # return data3d_full
segmentation = convert(Array{Int8, 3}, data3d_full .> 0)
data["data size 1"] = size(data3d_full, 1)
data["data size 2"] = size(data3d_full, 2)
data["data size 3"] = size(data3d_full, 3)
voxelsize_mm = datap["voxelsize_mm"]
# segmentation = LarSurf.generate_cube(data_size1; remove_one_pixel=true)
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
tmd = @timed larmodel = LarSurf.lsp_get_surface(segmentation; voxelsize=voxelsize_mm)
val, tm, mem, gc = tmd
println("Total time: $tm")
@info "==== finished, time from start: $(time()-time_start) [s]"
data["finished"] = time()-time_start
ExSu.datetime_to_dict!(data)
ExSu.add_to_csv(data, fn)

V, FV = larmodel
FVtri = LarSurf.triangulate_quads(FV)

ViewerGL.VIEW([
    ViewerGL.GLGrid(V,FVtri,ViewerGL.Point4d(1,1,1,0.1))
	ViewerGL.GLAxis(ViewerGL.Point3d(-1,-1,-1),ViewerGL.Point3d(1,1,1))
])
@JLD2.save "liver01.jld2" V FV
# Plasm.view(val)
