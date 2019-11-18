using Logging

"""
jlfile = @__FILE__
"""
module Experiments
using Distributed
using ExSup
using JLD2
using LarSurf
# using ViewerGL
function report_init_row(jlfile)
    data = Dict()
    data["jlfile"] = jlfile
    data["nprocs"] = nprocs()
    data["nworkers"] = nworkers()
    data["hostname"] = gethostname()
    data["ncores"] = length(Sys.cpu_info())
	ExSup.datetime_to_dict!(data)
    return data
end

function report_add_data_info(data, segmentation, voxelsize_mm)

	data["data size 1"] = size(segmentation, 1)
	data["data size 2"] = size(segmentation, 2)
	data["data size 3"] = size(segmentation, 3)
	nvoxels = sum(segmentation)
	@info "nvoxels=$(nvoxels)"
	data["nvoxels"] = nvoxels
	data["voxelsize_mm 1"] = size(voxelsize_mm, 1)
	data["voxelsize_mm 2"] = size(voxelsize_mm, 2)
	data["voxelsize_mm 3"] = size(voxelsize_mm, 3)
	return data
end


function experiment_get_surface(
	data3d_full, voxelsize_mm;
	output_path=".",
	threshold=1,
	mask_label="data",
	stepxy=1, stepz=1, do_crop=false, cropx=1, cropy=1, cropz=1,
	block_size_scalar=64, data=nothing, time_start=nothing,
	output_csv_file = "exp_surface_extraction_times.csv",
	# show=False
	)
	if time_start == nothing
		time_start = time()
	end
	if data == nothing
		data = Dict()
	end
	fn = output_csv_file
	block_size = [block_size_scalar, block_size_scalar, block_size_scalar]
	data["block size"] = block_size[1]
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
	voxelsize_mm[1] = voxelsize_mm[1] * stepz
	voxelsize_mm[2] = voxelsize_mm[2] * stepxy
	voxelsize_mm[3] = voxelsize_mm[3] * stepxy
	@info "voxelsize mm = $(voxelsize_mm), size = $(sz)"
	data = report_add_data_info(data, segmentation, voxelsize_mm)
	# segmentation = LarSurf.generate_cube(data_size1; remove_one_pixel=true)
	@info "==== using done, data generated time from start: $(time() - time_start) [s]"
	data["data generated"] = time() - time_start

	@info "Setup..."
	# setup_time = @elapsed LarSurf.lsp_setup(block_size;reference_time=time_start)
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
	@info "csv filename" fn
	data["smoothing time [s]"] = 0.0
	data["operation"] = "surface extraction"
	ExSup.add_to_csv(data, fn)
	@info "csv export done"

	V, FV = larmodel
	FVtri = LarSurf.triangulate_quads(FV)


	@JLD2.save "$(mask_label)_V_FV.jld2" V FV
	# if show
	# 	@info "Starting ViewerGL..."
	# 	ViewerGL.VIEW([
	# 	    ViewerGL.GLGrid(V, FVtri, ViewerGL.Point4d(1,1,1,0.1))
	# 		ViewerGL.GLAxis(ViewerGL.Point3d(-1,-1,-1),ViewerGL.Point3d(1,1,1))
	# 	])
	# end
	# FV = FVtri
	@JLD2.save "$output_path/$(mask_label)_V_FVtri.jld2" V FVtri
	objlines = LarSurf.Lar.lar2obj(V, FVtri, "$output_path/$(mask_label)_tri.obj")
	return V, FV, FVtri
end

function experiment_make_smoothing(V, FV, FVtri;
	output_path=".",
	mask_label="data",
	taubin=true, taubin_lambda=0.33, taubin_mu=-0.34, taubin_n=5,
	data=nothing,
	output_csv_file = "exp_surface_extraction_times.csv",
	# show=false
	)
	@info "smoothing"
	if data == nothing
		data = Dict()
	end
	if taubin
		t = @elapsed Vs = LarSurf.Smoothing.smoothing_FV_taubin(
		V, FV, taubin_lambda, taubin_mu, taubin_n)
		@info "smoothing taubin time", t
		# t = @elapsed FVtri = LarSurf.triangulate_quads(FV)

	else
		# t = @elapsed Vs = LarSurf.Smoothing.smoothing_FV(V, FVtri, 0.6, 3)
		t = @elapsed Vs = LarSurf.Smoothing.smoothing_FV(V, FVtri, 0.6, 3)
		@info "smoothing time", t
	end
	@info "Smoothing numer of Vs: $(size(Vs))"
	@JLD2.save "$output_path/$(mask_label)_Vs_FVtri.jld2" Vs FVtri
	# @JLD2.save "liver01tri.jld2" V FVtri
	objlines = LarSurf.Lar.lar2obj(Vs, FVtri, "$output_path/$(mask_label)_tri_sm.obj")
	data["operation"] = "surface extraction"
	data["smoothing time [s]"] = t
	# ExSup.add_to_csv(data, output_csv_file)
	# if show
	# 	ViewerGL.VIEW([
	# 	    ViewerGL.GLGrid(Vs, FVtri, ViewerGL.Point4d(1, 0, 1, 0.1))
	# 		ViewerGL.GLAxis(ViewerGL.Point3d(-1, -1, -1),ViewerGL.Point3d(1, 1, 1))
	# 	])
	# end
	return Vs
end
# end
# Plasm.view(val)
"""
Read data from file, make surface extraction and smoothing.
Surface models are stored into .obj files and all statistics are stored into
CSV file.

:param pth: filename with 3D data(dcm, tif, pklz, ...) or
.jld file generated with V and FV or
.jld file with datap
generated in previous run
"""
function experiment_make_surf_extraction_and_smoothing(
	data3d_full, voxelsize_mm;
	output_path=".",
	threshold=1, mask_label="data",
	stepxy=1, stepz=1, do_crop=false, cropx=1, cropy=1, cropz=1,
	block_size_scalar=64, data=nothing, time_start=nothing,
	output_csv_file = "exp_surface_extraction_times.csv",
	taubin::Bool=true, taubin_lambda=0.33, taubin_mu=-0.34, taubin_n=5,
	smoothing::Bool=true
	)
	# @info "pth"
	# println(pth)
	if data == nothing
		data = Dict()
	end
	datap_readed = true
		# FVtri = LarSurf.triangulate_quads(FV)
	# @load "ircad_$(mask_label).jld2" V FV
	V, FV, FVtri = experiment_get_surface(
		data3d_full, voxelsize_mm;
		output_path=output_path,
		threshold=threshold,
		mask_label=mask_label,
		stepxy=stepxy, stepz=stepz, do_crop=do_crop, cropx=cropx, cropy=cropy, cropz=cropz,
		block_size_scalar=block_size_scalar, data=data, time_start=time_start,
		output_csv_file = output_csv_file,
		# show=show
	)
	if smoothing
		Vs = experiment_make_smoothing(V, FV, FVtri;
				output_path=output_path,
		mask_label=mask_label,
		taubin=taubin,
		taubin_lambda = taubin_lambda,
		taubin_mu = taubin_mu,
		taubin_n = taubin_n,
		data=data,
		output_csv_file=output_csv_file,
		# show=show
		)
		return Vs, FVtri
	else
		return V, FVtri
	end
end

end
