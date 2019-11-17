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

@info "before everywhere using"
@info "time from start: $(time()-time_start) [s]"
# using Plasm
# @everywhere using LarSurf
# @everywhere using Distributed

@info "after everywhere using, time from start: $(time()-time_start) [s]"

block_size = [64, 64, 64]

data_id = 1
show = false
taubin = true
taubin_n = 5
taubin_p1 = 0.4
taubin_p2 = -0.2

stepz = 1
stepxy = 1
do_crop = false
cropx = 200
cropy = 200
cropz = 400
# stepxy = 4
# block_size = [128, 128, 128]
# block_size = [128, 128, 128]
# block_size = [32, 32, 32]
# data_size1 = 128
# data_size1 = 256
# data_size1 = 512

# -------------------------------------------------------------------


LarSurf.set_time_data(data)

data = LarSurf.report_init_row(@__FILE__)
# data["nprocs"] = nprocs()
# data["fcn"] = String(Symbol(fcni))
data["block size"] = block_size[1]

data["using done"] = time()-time_start
# segmentation = LarSurf.data234()
@info "Generate data..."
@info "time from start: $(time() - time_start) [s]"
mask_labels=["liver", "portalvein"]
# pth = Io3d.datasets_join_path("medical/orig/3Dircadb1.$data_id/MASKS_DICOM/liver")

mask_label = "nrn"
threshold = 7000
# for mask_label in mask_labels

	pth = Io3d.datasets_join_path("medical/orig/jatra_mikro_data/Nejlepsi_rozliseni_nevycistene")
	pth = Io3d.datasets_join_path("medical/processed/corrosion_cast/nrn10.pklz")
	datap = Io3d.read3d(pth)
	data3d_full = datap["data3d"]
	@info "raw data size=$(size(data3d_full))"
	data3d_full = data3d_full[1:stepz:end, 1:stepxy:end, 1:stepxy:end]
	if do_crop
		data3d_full = data3d_full[1:cropx, 1:cropy, 1:cropz]
	end
	    # round(size(data3d_full, 1) / target_size1)
	    # return data3d_full
	# segmentation = convert(Array{Int8, 3}, data3d_full .> threshold)
	segmentation = Int8.(data3d_full .> threshold)

	sz = [
		size(data3d_full, 1),
	 	size(data3d_full, 2),
	 	size(data3d_full, 3)
		]
	@info "nvoxels=$(nvoxels)"
	voxelsize_mm = datap["voxelsize_mm"]
	voxelsize_mm[1] = voxelsize_mm[1] * stepz
	voxelsize_mm[2] = voxelsize_mm[2] * stepxy
	voxelsize_mm[3] = voxelsize_mm[3] * stepxy
	@info "voxelsize mm = $(voxelsize_mm), size = $(sz)"
	data = report_add_data_info(data, segmentation, voxelsize_mm)
	# segmentation = LarSurf.generate_cube(data_size1; remove_one_pixel=true)
	@info "==== using done, data generated time from start: $(time() - time_start) [s]"
	data["data generated"] = time() - time_start

	@info "Setup..."
	setup_time = @elapsed LarSurf.lsp_setup(block_size;reference_time=time_start)
	println("setup time: $setup_time")
	@info "==== setup done, time from start: $(time() - time_start) [s]"
	data["setup done"] = time() - time_start
	# for wid in workers()
	#     # println("testing on $wid")
	#     ftr = @spawnat wid LarSurf._single_boundary3
	#     @test fetch(ftr) != nothing
	# end

	# @debug "Setup done"
	tmd = @timed larmodel = LarSurf.lsp_get_surface(segmentation; voxelsize=voxelsize_mm)
	val, tm, mem, gc = tmd
	println("Total time per $(mask_label): $tm")
	@info "==== time from start: $(time() - time_start) [s]"
	data["finished"] = time() - time_start
	ExSup.datetime_to_dict!(data)
	ExSup.add_to_csv(data, fn)

	V, FV = larmodel
	FVtri = LarSurf.triangulate_quads(FV)


	@JLD2.save "ircad_$(mask_label).jld2" V FV
	using ViewerGL
	println("=== ViewerGL readed")
	ViewerGL.VIEW([
	    ViewerGL.GLGrid(V, FVtri, ViewerGL.Point4d(1,1,1,0.1))
		ViewerGL.GLAxis(ViewerGL.Point3d(-1,-1,-1),ViewerGL.Point3d(1,1,1))
	])
	# FV = FVtri
	@JLD2.save "ircad_$(mask_label)_tri.jld2" V FVtri
	@info "smoothing"
	objlines = LarSurf.Lar.lar2obj(V, FVtri, "nrn_tri.obj")

	if taubin
		t = @elapsed Vs = LarSurf.Smoothing.smoothing_FV_taubin(V, FV, taubin_p1, taubin_p2, taubin_n)
		@info "smoothing taubin time", t
		# t = @elapsed FVtri = LarSurf.triangulate_quads(FV)

		if show
			ViewerGL.VIEW([
			    ViewerGL.GLGrid(Vs, FVtri, ViewerGL.Point4d(1, 0, 1, 0.1))
				ViewerGL.GLAxis(ViewerGL.Point3d(-1, -1, -1),ViewerGL.Point3d(1, 1, 1))
			])
		end
	else
		t = @elapsed Vs = LarSurf.Smoothing.smoothing_FV(V, FVtri, 0.6, 3)
		@info "smoothing time", t
	end
	@info "Smoothing numer of Vs: $(size(Vs))"
	@JLD2.save "ircad_$(mask_label)_sm.jld2" Vs FVtri
	# @JLD2.save "liver01tri.jld2" V FVtri
	objlines = LarSurf.Lar.lar2obj(Vs, FVtri, "nrn_tri_taubin.obj")
# end
# Plasm.view(val)
