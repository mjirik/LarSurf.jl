# julia experiments\to_jld2.jl -i "..\..\..\lisa_data\nrn10.pklz" -o nrn10.jld2
using ArgParse

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--input_path", "-i"
            help = "Input path"
			default = nothing
        "--output_path", "-o"
            help = "output path"
			default = nothing
    end

    return parse_args(s)
end
args = parse_commandline()

# using Test
using Logging
using Pio3d
using JLD2
ipath = args["input_path"]
opath = args["output_path"]

if opath == nothing
	opath = "$ipath.jld2"
end

@info "Reading $ipath..."
datap_in = Pio3d.read3d(ipath)

# @info "datap" datap_in

datap = Dict()
datap["data3d"] = datap_in["data3d"]
datap["voxelsize_mm"] = datap_in["voxelsize_mm"]

@info "Writing $opath..."
@JLD2.save opath datap
