println("Starting...")
@info "Starting..."
time_start = time()
@info "...at time " time_start
# using Revise
# using ExSup
using ArgParse

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--block_size"
            help = "Block size given by scalar Int"
			arg_type = Int
			default = 64
        "--input_path", "-i"
            help = "Input path, The default shape is generated if 'truncated_sphere' string is given."
			default = nothing
        "--output_path", "-o"
            help = "output path"
			default = "."
        "--input_path_in_datasets", "-d"
            help = "Input path relative to Pio3d.jl dataset path"
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
			default = 10
        "--n_procs"
            help = "Number of required CPU-cores"
            arg_type = Int
			default = 4
        "--show"
            help = "Show 3D visualization"
            action = :store_true
        "--skip_smoothing"
            help = "Skip smoothing procedure"
            action = :store_true
        "--color"
			nargs = 4
            help = "Visualization color, RGBA"
			arg_type = Float64
			default = [1, 0, 1, 0.1]
            # action = :store_true
        # "arg1"
        #     help = "a positional argument"
        #     required = true
    end

    return parse_args(s)
end
args = parse_commandline()

# println("args: $(args)")
# println("color")
# println(args["color"])
# exit()

using Test
using Logging
using SparseArrays
using ExSup
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
end
cropx = crop_px
cropy = crop_px
cropz = crop_px
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
# pth = Pio3d.datasets_join_path("medical/orig/3Dircadb1.$data_id/MASKS_DICOM/liver")

# for mask_label in mask_labels

	if args["input_path"] == nothing
		using Pio3d
		if args["input_path_in_datasets"] == nothing
			# pth = Pio3d.datasets_join_path("medical/orig/jatra_mikro_data/Nejlepsi_rozliseni_nevycistene")
			pth = Pio3d.datasets_join_path("medical/processed/corrosion_cast/nrn10.pklz")
		else
			pth = Pio3d.datasets_join_path(args["input_path_in_datasets"])
		end

	else
		pth = args["input_path"]
	end


	data["input_path"] = pth
	if pth[end-4:end] == ".jld2"
		# @info "Surface model given in .jld file. Skipping surface extraction"
		# uu = @JLD2.load pth
		# if :V in uu
		# 	datap_readed = false
		# 	@JLD2.load pth V FV
		# 	FVtri = triangulate_quads(FV)
		# elseif :datap in uu
		@JLD2.load pth datap
		# else
		# 	@error "Expected F and FV or datap in jld2 file"
		# end
		# uu = nothing
		data3d_full = datap["data3d"]
		voxelsize_mm = datap["voxelsize_mm"]
	elseif args["input_path"] == "truncated_sphere"
		data3d_full = LarSurf.generate_truncated_sphere(30)
		voxelsize_mm = [1., 1., 1.]
		args["threshold"] = 0
	else
		using Pio3d
		datap = Pio3d.read3d(pth)
		data3d_full = datap["data3d"]
		voxelsize_mm = datap["voxelsize_mm"]
	end



# V1 is V or Vs accoring to smoothing parameter
V1, FVtri = LarSurf.Experiments.experiment_make_surf_extraction_and_smoothing(
	data3d_full, voxelsize_mm;
	output_path=args["output_path"],
	threshold=args["threshold"],
	mask_label = args["label"],
	stepz = args["stepz"],
	stepxy = args["stepxy"],
	do_crop=do_crop, cropx=cropx, cropy=cropy, cropz=cropz,
	block_size_scalar=block_size_scalar, data=data, time_start=time_start,
	output_csv_file = output_csv_file,
	taubin=taubin,
	taubin_lambda = args["taubin_lambda"],
	taubin_mu = args["taubin_mu"],
	taubin_n = args["taubin_n"],
	smoothing= !args["skip_smoothing"]
)
show=args["show"]
if show
	@info "ViewerGL init ..."
	using ViewerGL
	c = args["color"]
	# print("color: $c")
	EVtri = LarSurf.Smoothing.get_EV_quads(FVtri)
	ViewerGL.VIEW([
	    ViewerGL.GLGrid(V1, FVtri, ViewerGL.Point4d(c[1], c[2], c[3], c[4]))
		ViewerGL.GLGrid(V1, EVtri,ViewerGL.Point4d(0.,0.,0.,0.9))
		ViewerGL.GLAxis(ViewerGL.Point3d(-1, -1, -1),ViewerGL.Point3d(1, 1, 1))
	])
end
