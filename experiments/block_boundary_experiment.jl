# include("../src/lario3d.jl")

using Revise
using lario3d
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using Plasm, SparseArrays
using Pandas
using Seaborn



## Read data from file
threshold = 4000;
pth = lario3d.datasets_join_path("medical/orig/sample-data/nrn4.pklz")

# threshold = 10
# pth = lario3d.datasets_join_path("medical/orig/3Dircadb1.1/MASKS_DICOM/liver")
datap = lario3d.read3d(pth);
#
data3d = datap["data3d"]
data_size = lario3d.size_as_array(size(data3d))
segmentation = data3d .> threshold;


## Generate data
# segmentation = lario3d.generate_slope([9,10,11])
filtered_bigFV, Flin, bigV, model = lario3d.get_surface_grid_per_block(segmentation, [2,3,4])
bigVV, bigEV, bigFV, bigCV = model
Plasm.View((bigV,[bigVV, bigEV, filtered_bigFV]))
# Plasm.View((bigV,[bigVV, bigEV, filtered_bigFV]))

times = []
sizes = []
for block_size1=3:5
    block_size = [block_size1, block_size1, block_size1]
    append!(sizes, block_size1)

    t0 = time()
    filtered_bigFV, Flin, bigV, model = lario3d.get_surface_grid_per_block(segmentation, block_size);
    t1 = time() - t0
    append!(times, t1)
    print("time: ", t1)

end
df = DataFrame(Dict(:size=>sizes, :time=>times))
to_csv(df, "data.csv")

# lmplot(df; x="time", y="size")