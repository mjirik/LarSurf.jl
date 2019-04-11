# include("../src/lario3d.jl")
tim = time()
# using Revise
using lario3d
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using Plasm, SparseArrays
using Pandas
using Seaborn

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
filtered_bigFV, Flin, (bigV, tmodel) = lario3d.get_surface_grid_per_block(segmentation, block_size)
bigVV, bigEV, bigFV, bigCV = tmodel


# Repeated run
tim_prev = tim
tim = time()
println("surface extracted in time: ", tim - tim_prev)
Plasm.View((bigV,[bigVV, bigEV, filtered_bigFV]))
Plasm.View((bigV,[bigVV, filtered_bigFV]))
# Plasm.View((bigV,[bigVV, bigEV, filtered_bigFV]))

times = []
sizes = []
for block_size1=3:2:10
    block_size = [block_size1, block_size1, block_size1]
    append!(sizes, block_size1)

    t0 = time()
    filtered_bigFV, Flin, (bigV, tmodel) = lario3d.get_surface_grid_per_block(segmentation, block_size);
    t1 = time() - t0
    append!(times, t1)
    println("time: ", t1)

end
df = DataFrame(Dict(:size=>sizes, :time=>times))
to_csv(df, "data.csv"; index=false)

# lmplot(df; x="time", y="size")