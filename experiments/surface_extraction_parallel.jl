println("Starting...")
@info "Starting..."
time_start = time()
# using Revise
# using ExSu
using ArgParse

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--block_size"
            help = "Block size given by scalar Int"
			arg_type = Int
			default = 64
        "--input_path", "-i"
            help = "Input path"
			default = nothing
        "--output_path", "-o"
            help = "output path"
			default = "."
        "--input_path_in_datasets", "-d"
            help = "Input path relative to Io3d.jl dataset path"
			default = nothing
        "--threshold"
            help = "another option with an argument"
            arg_type = Int
            default = 7000
        "--stepz"
            help = "Every stepz-th voxel in z-axis is readed"
            arg_type = Int
			default = 1
        "--stepxy"
            help = "Every stepxy-th voxel in xy-axis is readed"
            arg_type = Int
			default = 1
        "--crop"
            help = "Integer number describing the size of crop of input volume for all axes."
            arg_type = Int
			default = nothing
        "--output_csv_file"
            help = "Path to outpu CSV file"
            default = "exp_surface_extraction_times.csv"
        "--label"
            help = "label used in output filename"
            default = "data"
        "--taubin_lambda"
            help = "Taubin smoothing parameter. lambda=0.33, mu=-0.34"
            arg_type = Float64
			default = 0.33
        "--taubin_mu"
            help = "Taubin smoothing parameter. lambda=0.33, mu=-0.34"
            arg_type = Float64
			default = -0.34
        "--taubin_n"
            help = "Taubin smoothing parameter. Number of iterations "
            arg_type = Int
			default = 5
        "--n_procs"
            help = "Number of required CPU-cores"
            arg_type = Int
			default = 4
        "--show"
            help = "Show 3D visualization"
			default = false
            action = :store_true
            # action = :store_true
        # "arg1"
        #     help = "a positional argument"
        #     required = true
    end

    return parse_args(s)
end
args = parse_commandline()

# println("args: $(args)")
# println(args["threshold"])
# exit()

using Test
using Logging
using SparseArrays
using ExSu
using Io3d
using JLD2
using ViewerGL
@info "Distributed init..."
using Distributed
if nprocs() == 1
    addprocs(args["n_procs"]-1)
end
block_size_scalar = args["block_size"]


using LarSurf
# @everywhere using LarSurf


# fn = "exp_surface_extraction_ircad_times.csv"
output_csv_file = args["output_csv_file"]

@info "before everywhere using"
@info "time from start: $(time()-time_start) [s]"
# using Plasm
# @everywhere using LarSurf
# @everywhere using Distributed

@info "after everywhere using, time from start: $(time()-time_start) [s]"


# data_id = 1
show = false
taubin = true
# taubin_n = 5
# taubin_lambda = 0.4
# taubin_mu = -0.2

crop_px = args["crop"]
if crop_px == nothing
	do_crop = false
else
	do_crop = true
	cropx = crop_px
	cropy = crop_px
	cropz = crop_px
end
# stepxy = 4
# block_size = [128, 128, 128]
# block_size = [128, 128, 128]
# block_size = [32, 32, 32]
# data_size1 = 128
# data_size1 = 256
# data_size1 = 512

# -------------------------------------------------------------------


data = LarSurf.Experiments.report_init_row(@__FILE__)
LarSurf.set_time_data(data)

# data["nprocs"] = nprocs()
# data["fcn"] = String(Symbol(fcni))

data["using done"] = time()-time_start
# segmentation = LarSurf.data234()
@info "Generate data..."
@info "time from start: $(time() - time_start) [s]"
# pth = Io3d.datasets_join_path("medical/orig/3Dircadb1.$data_id/MASKS_DICOM/liver")

# for mask_label in mask_labels

	if args["input_path"] == nothing
		if args["input_path_in_datasets"] == nothing
			pth = Io3d.datasets_join_path("medical/orig/jatra_mikro_data/Nejlepsi_rozliseni_nevycistene")
			pth = Io3d.datasets_join_path("medical/processed/corrosion_cast/nrn10.pklz")
		else
			pth = Io3d.datasets_join_path(args["input_path_in_datasets"])
		end

	else
		pth = args["input_path"]
	end




function experiment_get_surface(
	data3d_full, voxelsize_mm;
	output_path=".",
	threshold=1,
	mask_label="data",
	stepxy=1, stepz=1, cropx=1, cropy=1, cropz=1,
	block_size_scalar=64, data=nothing, time_start=nothing,
	output_csv_file = "exp_surface_extraction_times.csv",
	show=False
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
	data = LarSurf.Experiments.report_add_data_info(data, segmentation, voxelsize_mm)
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
	ExSu.datetime_to_dict!(data)
	@info "csv filename" fn
	data["smoothing time [s]"] = ""
	ExSu.add_to_csv(data, fn)
	@info "csv export done"

	V, FV = larmodel
	FVtri = LarSurf.triangulate_quads(FV)


	@JLD2.save "$(mask_label)_V_FV.jld2" V FV
	if show
		@info "Starting ViewerGL..."
		ViewerGL.VIEW([
		    ViewerGL.GLGrid(V, FVtri, ViewerGL.Point4d(1,1,1,0.1))
			ViewerGL.GLAxis(ViewerGL.Point3d(-1,-1,-1),ViewerGL.Point3d(1,1,1))
		])
	end
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
	show=false
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
		t = @elapsed Vs = LarSurf.Smoothing.smoothing_FV(V, FVtri, 0.6, 3)
		@info "smoothing time", t
	end
	@info "Smoothing numer of Vs: $(size(Vs))"
	@JLD2.save "$output_path/$(mask_label)_Vs_FVtri.jld2" Vs FVtri
	# @JLD2.save "liver01tri.jld2" V FVtri
	objlines = LarSurf.Lar.lar2obj(Vs, FVtri, "$output_path/$(mask_label)_tri_sm.obj")
	data["smoothing time [s]"] = t
	# ExSu.add_to_csv(data, output_csv_file)
	if show
		ViewerGL.VIEW([
		    ViewerGL.GLGrid(Vs, FVtri, ViewerGL.Point4d(1, 0, 1, 0.1))
			ViewerGL.GLAxis(ViewerGL.Point3d(-1, -1, -1),ViewerGL.Point3d(1, 1, 1))
		])
	end
end
# end
# Plasm.view(val)
"""
Read data from file, make surface extraction and smoothing.
Surface models are stored into .obj files and all statistics are stored into
CSV file.

:param pth: filename with 3D data(dcm, tif, pklz, ...) or file generated with V and FV
generated in previous run
"""
function experiment_make_surf_extraction_and_smoothing(
	pth;
	output_path=".",
	threshold=1, mask_label="data",
	stepxy=1, stepz=1, cropx=1, cropy=1, cropz=1,
	block_size_scalar=64, data=nothing, time_start=nothing,
	output_csv_file = "exp_surface_extraction_times.csv",
	taubin::Bool=true, taubin_lambda=0.33, taubin_mu=-0.34, taubin_n=5,
	show::Bool=false
	)
	@info "pth"
	println(pth)
	if pth[end-4:end] == ".jld2"
		@info "Surface model given in .jld file. Skipping surface extraction"
		@JLD2.load pth V FV
		FVtri = LarSurf.triangulate_quads(FV)
	# @load "ircad_$(mask_label).jld2" V FV
	else
		datap = Io3d.read3d(pth)
		data3d_full = datap["data3d"]
		voxelsize_mm = datap["voxelsize_mm"]
		V, FV, FVtri = experiment_get_surface(
			data3d_full, voxelsize_mm;
			output_path=output_path,
			threshold=threshold,
			mask_label=mask_label,
			stepxy=stepxy, stepz=stepz, cropx=cropx, cropy=cropy, cropz=cropz,
			block_size_scalar=block_size_scalar, data=data, time_start=time_start,
			output_csv_file = output_csv_file,
			show=show
		)
	end
	experiment_make_smoothing(V, FV, FVtri;
			output_path=output_path,
	mask_label=mask_label,
	taubin=taubin,
	taubin_lambda = args["taubin_lambda"],
	taubin_mu = args["taubin_mu"],
	taubin_n = args["taubin_n"],
	data=data,
	output_csv_file=output_csv_file,
	show=show
	)
end

experiment_make_surf_extraction_and_smoothing(
	pth;
	output_path=args["output_path"],
	threshold=args["threshold"],
	mask_label = args["label"],
	stepz = args["stepz"],
	stepxy = args["stepxy"],
	cropx=cropx, cropy=cropy, cropz=cropz,
	block_size_scalar=block_size_scalar, data=data, time_start=time_start,
	output_csv_file = output_csv_file,
	taubin=taubin,
	taubin_lambda = args["taubin_lambda"],
	taubin_mu = args["taubin_mu"],
	taubin_n = args["taubin_n"],
	show=args["show"]
)
