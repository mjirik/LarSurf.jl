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
            default = "exp_surface_extraction_ircad_times.csv"
        "--label"
            help = "label used in output filename"
            default = "data"
        "--taubin_lambda"
            help = "Taubin smoothing parameter. lambda=0.33, mu=-0.34"
            arg_type = Float64
			default = 0.3
        "--taubin_mu"
            help = "Taubin smoothing parameter. lambda=0.33, mu=-0.34"
            arg_type = Float64
			default = 0.3
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
@info "Distributed init..."
using Distributed
if nprocs() == 1
    addprocs(3)
end
block_size_scalar = args["block_size"]


using LarSurf
# @everywhere using LarSurf


# fn = "exp_surface_extraction_ircad_times.csv"
fn = args["output_csv_file"]

@info "before everywhere using"
@info "time from start: $(time()-time_start) [s]"
# using Plasm
# @everywhere using LarSurf
# @everywhere using Distributed

@info "after everywhere using, time from start: $(time()-time_start) [s]"

block_size = [block_size_scalar, block_size_scalar, block_size_scalar]

# data_id = 1
show = false
taubin = true
taubin_n = 5
taubin_lambda = 0.4
taubin_mu = -0.2

stepz = args["stepz"]
stepxy = args["stepxy"]
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
threshold = args["threshold"]
mask_label = args["label"]


data = LarSurf.report_init_row(@__FILE__)
LarSurf.set_time_data(data)

# data["nprocs"] = nprocs()
# data["fcn"] = String(Symbol(fcni))
data["block size"] = block_size[1]

data["using done"] = time()-time_start
# segmentation = LarSurf.data234()
@info "Generate data..."
@info "time from start: $(time() - time_start) [s]"
mask_labels=["liver", "portalvein"]
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
	ExSu.datetime_to_dict!(data)
	ExSu.add_to_csv(data, fn)

	V, FV = larmodel
	FVtri = LarSurf.triangulate_quads(FV)


	@JLD2.save "$(mask_label)_V_FV.jld2" V FV
	using ViewerGL
	println("=== ViewerGL readed")
	ViewerGL.VIEW([
	    ViewerGL.GLGrid(V, FVtri, ViewerGL.Point4d(1,1,1,0.1))
		ViewerGL.GLAxis(ViewerGL.Point3d(-1,-1,-1),ViewerGL.Point3d(1,1,1))
	])
	# FV = FVtri
	@JLD2.save "$(mask_label)_V_FVtri_tri.jld2" V FVtri
	@info "smoothing"
	objlines = LarSurf.Lar.lar2obj(V, FVtri, "$(mask_label)_tri.obj")

	if taubin
		t = @elapsed Vs = LarSurf.Smoothing.smoothing_FV_taubin(
		V, FV, taubin_lambda, taubin_mu, taubin_n)
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
	@JLD2.save "$(mask_label)_Vs_FVtri_sm.jld2" Vs FVtri
	# @JLD2.save "liver01tri.jld2" V FVtri
	objlines = LarSurf.Lar.lar2obj(Vs, FVtri, "$(mask_label)_tri_sm.obj")
# end
# Plasm.view(val)
