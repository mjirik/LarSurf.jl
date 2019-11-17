println("First line of the script")
time_start = time()
using Test
using Logging
using SparseArrays
using ExSup
using Io3d
using JLD2
@info "Before Distributed"
using Distributed
if nprocs() == 1
    addprocs(3)
end
# using Revise
# using ExSup
using LarSurf
# @everywhere using LarSurf


fn = "exp_surface_extraction_ircad_times.csv"
data = Dict()

@info "before everywhere using"
@info "time from start: $(time()-time_start) [s]"
# using Plasm
# @everywhere using LarSurf
# @everywhere using Distributed

@info "after everywhere using, time from start: $(time()-time_start) [s]"


data_id = 1
stepz = 1
stepxy = 1
# stepxy = 4
block_size = [64, 64, 64]
# block_size = [128, 128, 128]
# block_size = [128, 128, 128]
# block_size = [32, 32, 32]
# data_size1 = 128
# data_size1 = 256
# data_size1 = 512


LarSurf.set_time_data(data)
LarSurf.report_init_row(@__FILE__)

data["block size"] = block_size[1]
data["using done"] = time()-time_start
# segmentation = LarSurf.data234()
@info "Generate data..."
@info "time from start: $(time() - time_start) [s]"
mask_labels=["liver", "portalvein"]
# pth = Io3d.datasets_join_path("medical/orig/3Dircadb1.$data_id/MASKS_DICOM/liver")

for mask_label in mask_labels
	pth = Io3d.datasets_join_path("medical/orig/3Dircadb1.$data_id/MASKS_DICOM/$(mask_label)")
	datap = Io3d.read3d(pth)
	data3d_full = datap["data3d"]
	data3d_full = data3d_full[1:stepz:end, 1:stepxy:end, 1:stepxy:end]
	    # round(size(data3d_full, 1) / target_size1)
	    # return data3d_full
	segmentation = convert(Array{Int8, 3}, data3d_full .> 0)
	voxelsize_mm = datap["voxelsize_mm"]
	voxelsize_mm[1] = voxelsize_mm[1] * stepz
	voxelsize_mm[2] = voxelsize_mm[2] * stepxy
	voxelsize_mm[3] = voxelsize_mm[3] * stepxy
	LarSurf.report_add_data_info(data, segmentation, voxelsize_mm)
	@info "voxelsize mm = $(voxelsize_mm), size=$(size(data3d_full))"
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
	println("Total time per $(mask_label): $tm")
	@info "==== time from start: $(time()-time_start) [s]"
	data["finished"] = time()-time_start
	ExSup.add_to_csv(data, fn)

	V, FV = larmodel
	FVtri = LarSurf.triangulate_quads(FV)


	@JLD2.save "ircad_$(mask_label).jld2" V FV
	using ViewerGL
	println("=== ViewerGL readed")
	ViewerGL.VIEW([
	    ViewerGL.GLGrid(V,FVtri,ViewerGL.Point4d(1,1,1,0.1))
		ViewerGL.GLAxis(ViewerGL.Point3d(-1,-1,-1),ViewerGL.Point3d(1,1,1))
	])
	# FV = FVtri
	@JLD2.save "ircad_$(mask_label)_tri.jld2" V FVtri
	# @JLD2.save "liver01tri.jld2" V FVtri
end
# Plasm.view(val)
