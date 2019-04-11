#=
gaussian_smoothing:
- Julia version: 1.1.0
- Author: Jirik
- Date: 2019-04-08
=#
using lario3d
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using Plasm, SparseArrays
using Pandas
using Seaborn


V = [[0 0]; [2 0]; [1 2]; [3 2]; [4 2]; [4 0] ]'
EVch = spzeros(Int8, 7, 6)
EVch[1,1] = 1
EVch[1,2] = 1
EVch[2,2] = 1
EVch[2,3] = 1
EVch[3,1] = 1
EVch[3,3] = 1
EVch[4,3] = 1
EVch[4,4] = 1
EVch[5,2] = 1
EVch[5,4] = 1
EVch[6,2] = 1
EVch[6,6] = 1
EVch[7,4] = 1
EVch[7,6] = 1
Matrix(EVch)

FVch = spzeros(Int8, 3, 6)
FVch[1, 1] = 1
FVch[1, 2] = 1
FVch[1, 3] = 1
FVch[2, 2] = 1
FVch[2, 3] = 1
FVch[2, 4] = 1
# FVch[3, 2] = 1
# FVch[3, 4] = 1
# FVch[3, 6] = 1

FEch = spzeros(Int8, 3, 7)
FEch[1, 1] = 1
FEch[1, 2] = 1
FEch[1, 3] = 1
FEch[2, 2] = 1
FEch[2, 4] = 1
FEch[2, 5] = 1

function eye(sz)
    arr = spzeros(Int8, sz, sz)
    for i=1:sz
        arr[i,i] = 1
    end
    return arr
end

function setIzero!(arr)
    for i=1:size(arr)[1]
        arr[i,i] = 0
    end
    return arr
end

function getDiag(arr)
    sz = size(arr)[1]
    arro = zeros(eltype(arr), sz)
    for i=1:sz
        arro[i] = arr[i,i]
    end
    return arro
end

function make_full(arr)
    arrout = Array{eltype(arr), 2}(undef, size(arr)...)
    for i=1:size(arr)[1]
        for j=1:size(arr)[2]
            arrout[i,j] = arr[i,j]
        end
    end
    return arrout
end
#neighboor vertexes

function smoothing(V, EVch, k=0.35)
#     Matrix(setIzero!(EVch' * EVch))

    neighboorNumber = getDiag(EVch' * EVch)
    neighboors = setIzero!(EVch' * EVch)

#     targetV =  neighboors * V' ./ neighboorNumber
#     diff = targetV - V'
#     newV = (V' + k * diff)'

    targetV = V * neighboors ./ neighboorNumber'
    println("targetV shape: ", size(targetV))
    diff = targetV - V
    println("diff shape: ", size(diff))
    newV = V + k * diff

    return make_full(newV)
end

smoothing(V, EVch)



## Read data from file
xystep = 1
zstep = 1
threshold = 4000;
pth = lario3d.datasets_join_path("medical/orig/sample-data/nrn4.pklz")
datap = lario3d.read3d(pth)

data3d = datap["data3d"]
segmentation = data3d .> threshold


block_size = [5,5,5]
filtered_bigFV, Flin, bigV, model = lario3d.get_surface_grid_per_block(segmentation, block_size)
bigVV, bigEV, bigFV, bigCV = model

Plasm.View((bigV,[bigVV, bigEV, filtered_bigFV]))

EV = []
FV = filtered_bigFV
for f in FV
	push!(EV, [[f[1],f[2]],[f[3],f[4]],  [f[1],f[3]],[f[2],f[4]]])
end
doubleedges = sort(cat(EV))
doubleedges = convert(Lar.Cells, doubleedges)
EV = [doubleedges[k] for k=1:2:length(doubleedges)]
aEV = lario3d.ll2array(EV)

# nrn4

# notAllBigEV =


kEV = lario3d.characteristicMatrix(aEV, size(bigV)[2])
# kEV = Lar.characteristicMatrix(EV)
newBigV = smoothing(bigV, kEV, 0.6)
Plasm.View((newBigV * 100,[filtered_bigFV]))
# Plasm.View((newBigV * 100,[bigVV, bigEV, filtered_bigFV]))
