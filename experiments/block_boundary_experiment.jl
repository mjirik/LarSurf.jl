# include("../src/lario3d.jl")
tim = time()
# using Revise
using lario3d
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using Plasm, SparseArrays
using Pandas
using Seaborn
using Dates

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

xystep = 8
zstep = 4

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

println("liver sum 1 = ", sum(segmentation == 0), ", 0 = ", sum(segmentation == 1))

tim_prev = tim
tim = time()
println("data read complete in time: ", tim - tim_prev)

# Run once to force compilation
## Generate data
# segmentation = lario3d.generate_slope([9,10,11])
block_size = [5,5,5]
filtered_bigFV, Flin, (bigV, tmodel) = lario3d.get_surface_grid_per_block(segmentation, block_size)
bigVV, bigEV, bigFV, bigCV = tmodel


times = []
block_sizes = []
data_sizes_1 = []
data_sizes_2 = []
data_sizes_3 = []
datetimes = String[]
comments = String[]


# lmplot(df; x="time", y="size")


# Repeated run with forced computation of boundary matrix in each request

# lario3d.set_param(force_calculate=true)
lario3d.set_param(boundary_allow_files=false)
lario3d.set_param(boundary_allow_memory=false)
tim_prev = tim
tim = time()
println("surface extracted in time: ", tim - tim_prev)
# Plasm.View((bigV,[bigVV, bigEV, filtered_bigFV]))
# Plasm.View((bigV,[bigVV, filtered_bigFV]))
# Plasm.View((bigV,[bigVV, bigEV, filtered_bigFV]))

# for block_size1=16:16:64
# for block_size1=[16, 32, 64]
for block_size1=[32]

    push!(datetimes, Dates.format(Dates.now(), "yyyy-mm-dd HH:MM:SS"))
    block_size = [block_size1, block_size1, block_size1]
    append!(block_sizes, block_size1)

    t0 = time()
    filtered_bigFV, Flin, (bigV, tmodel) = lario3d.get_surface_grid_per_block(segmentation, block_size);
    t1 = time() - t0
    append!(times, t1)
    push!(comments, "computed")
    push!(data_sizes_1, data_size[1])
    push!(data_sizes_2, data_size[2])
    push!(data_sizes_3, data_size[3])
    println("time: ", t1)

end


## Repeated run with boundary matrix loaded from memory
# lario3d.set_param(force_calculate=false)
lario3d.set_param(boundary_allow_files=true)
lario3d.set_param(boundary_allow_memory=true)
tim_prev = tim
tim = time()
println("surface extracted in time: ", tim - tim_prev)
# Plasm.View((bigV,[bigVV, bigEV, filtered_bigFV]))
# Plasm.View((bigV,[bigVV, filtered_bigFV]))
# Plasm.View((bigV,[filtered_bigFV]))
# Plasm.View((bigV,[bigVV, bigEV, filtered_bigFV]))

# for block_size1=3:2:10
for block_size1=[32]
    block_size = [block_size1, block_size1, block_size1]
    append!(block_sizes, block_size1)
    push!(datetimes, Dates.format(Dates.now(), "yyyy-mm-dd HH:MM:SS"))

    t0 = time()
    filtered_bigFV, Flin, (bigV, tmodel) = lario3d.get_surface_grid_per_block(segmentation, block_size);
    t1 = time() - t0
    append!(times, t1)
    push!(comments, "memory and file")
    push!(data_sizes_1, data_size[1])
    push!(data_sizes_2, data_size[2])
    push!(data_sizes_3, data_size[3])
    println("time: ", t1)

end

# ------

print("sizes: ", size(block_sizes), size(times), size(comments))
df = DataFrame(Dict(
    :block_size=>block_sizes,
    :time=>times,
    :comment=>comments,
    :datetime=>datetimes,
    :datasize1=>data_sizes_1,
    :datasize2=>data_sizes_1,
    :datasize3=>data_sizes_1,
    ))


add_to_csv(df, data_file)
