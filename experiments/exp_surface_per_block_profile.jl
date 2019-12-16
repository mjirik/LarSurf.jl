#=
block_boundary_experiment_profile:
- Julia version: 1.1.0
- Author: Jirik
- Date: 2019-04-26
=#

# include("../src/LarSurf.jl")
tim = time()
using Revise
using LarSurf
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using Plasm, SparseArrays
using Pandas
using Seaborn
using Dates
using Logging

using Profile
using ProfileView

# using Logger
# logger = SimpleLogger(stdout, Logging.Debug)
logger = SimpleLogger(stdout, Logging.Info)
old_logger = global_logger(logger)

# Logging.min_enabled_level

data_file = "data.csv"
fn_profile_txt = "exp_surface_per_block_profile.txt"

tim_prev = tim
tim = time()
println("using done in: ", tim - tim_prev)

## Read data from file
# xystep = 1
# zstep = 1
# threshold = 4000;
# pth = Pio3d.datasets_join_path("medical/orig/sample-data/nrn4.pklz")

threshold = 10
# xystep = 50
# zstep = 30

# xystep = 25
# zstep = 15


# xystep = 20
# zstep = 10

# xystep = 10
# zstep = 5

# xystep = 4
# zstep = 2

xystep = 8
zstep = 4
pth = Pio3d.datasets_join_path("medical/orig/3Dircadb1.1/MASKS_DICOM/liver")

datap = Pio3d.read3d(pth);
#
data3d_full = datap["data3d"]
println("orig size: ", size(data3d_full))
data3d = data3d_full[1:zstep:end, 1:xystep:end, 1:xystep:end];

data_size = LarSurf.size_as_array(size(data3d))
println("data size: ", data_size)
segmentation = data3d .> threshold;

tim_prev = tim
tim = time()
println("data read complete in time: ", tim - tim_prev)

# Run once to force compilation
## Generate data
# segmentation = LarSurf.generate_slope([9,10,11])
block_size = [8,8,8]
function time_profile()
    larmodel = LarSurf.get_surface_grid_per_block(segmentation, block_size)
    # bigVV, bigEV, bigFV, bigCV = tmodel
end

#compile
LarSurf.set_param(boundary_allow_read_files=false)
LarSurf.set_param(boundary_allow_write_files=false)
LarSurf.set_param(boundary_allow_memory=false)
time_profile()
println("==========")
# LarSurf._boundary3_storage = Dict()
LarSurf.set_param(boundary_allow_read_files=false)
LarSurf.set_param(boundary_allow_write_files=false)
LarSurf.set_param(boundary_allow_memory=true)
# delete memory
LarSurf.reset(boundary_storage=true)

Profile.init(n = 10^9, delay=0.01)
@profile time_profile()
open(fn_profile_txt, "w") do s
    Profile.print(IOContext(s, :displaysize => (24, 500)))
end
Profile.print(format=:flat)
ProfileView.view()

# ProfileView.svgwrite("profile_results2.svg")
