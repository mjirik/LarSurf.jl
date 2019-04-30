#=
block_boundary_experiment_profile:
- Julia version: 1.1.0
- Author: Jirik
- Date: 2019-04-26
=#

# include("../src/lario3d.jl")
tim = time()
using Revise
using lario3d
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using Plasm, SparseArrays
using Pandas
using Seaborn
using Dates
using Profile

data_file = "data.csv"

tim_prev = tim
tim = time()
println("using done in: ", tim - tim_prev)

## Read data from file
# xystep = 1
# zstep = 1
# threshold = 4000;
# pth = lario3d.datasets_join_path("medical/orig/sample-data/nrn4.pklz")

xystep = 50
zstep = 30
threshold = 10

xystep = 25
zstep = 15

xystep = 10
zstep = 5

xystep = 20
zstep = 10

# xystep = 4
# zstep = 2
pth = lario3d.datasets_join_path("medical/orig/3Dircadb1.1/MASKS_DICOM/liver")

datap = lario3d.read3d(pth);
#
data3d_full = datap["data3d"]
println("orig size: ", size(data3d_full))
data3d = data3d_full[1:zstep:end, 1:xystep:end, 1:xystep:end];

data_size = lario3d.size_as_array(size(data3d))
println("data size: ", data_size)
segmentation = data3d .> threshold;

tim_prev = tim
tim = time()
println("data read complete in time: ", tim - tim_prev)

# Run once to force compilation
## Generate data
# segmentation = lario3d.generate_slope([9,10,11])
block_size = [5,5,5]
function time_profile()
    filtered_bigFV, Flin, (bigV, tmodel) = lario3d.get_surface_grid_per_block(segmentation, block_size)
    bigVV, bigEV, bigFV, bigCV = tmodel
end

Profile.init(n = 10^8, delay = 0.02)
@profile  time_profile()

Profile.print(format=:flat)
println("======== profile printed =======")
using ProfileView
ProfileView.view()

ProfileView.svgwrite("profile_results2.svg")
