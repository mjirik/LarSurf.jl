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

V = [[0 0]; [2 0]; [1 2]; [3 2]; [4 0] ]'
EVch = spzeros(Int8, 7, 5)
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
EVch[6,5] = 1
EVch[7,4] = 1
EVch[7,5] = 1
Matrix(EVch)

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

function smoothing(V, EVch)
    k = 0.35
#     Matrix(setIzero!(EVch' * EVch))

    neighboorNumber = getDiag(EVch' * EVch)
    neighboors = setIzero!(EVch' * EVch)

#     targetV =  neighboors * V' ./ neighboorNumber
#     diff = targetV - V'
#     newV = (V' + k * diff)'

    targetV = V * neighboors ./ neighboorNumber'
    diff = targetV - V
    newV = V + k * diff

    return make_full(newV)
end

smoothing(V, EVch)



# nrn4
bigEVch = Lar.characteristicMatrix(bigEV)
newBigV = smoothing(bigV, bigEVch)
Plasm.View((newBigV,[bigVV, bigEV, filtered_bigFV]))
