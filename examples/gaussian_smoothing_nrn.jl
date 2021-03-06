#=
gaussian_smoothing:
- Julia version: 1.1.0
- Author: Jirik
- Date: 2019-04-08
=#
using LarSurf
using LinearAlgebraicRepresentation
Lar = LinearAlgebraicRepresentation
using Plasm, SparseArrays
# using Pandas
using Pio3d
# using Seaborn


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

function smoothing_EV(V, EVch::SparseMatrixCSC, k=0.35)
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

smoothing_EV(V, EVch)



## Read data from file
xystep = 1
zstep = 1
threshold = 4000;
pth = Pio3d.datasets_join_path("medical/orig/sample-data/nrn4.pklz")
datap = Pio3d.read3d(pth)

data3d = datap["data3d"]
segmentation = data3d .> threshold


block_size = [5,5,5]
basicmodel, Flin, larmodel = LarSurf.get_surface_grid_per_block(segmentation, block_size; return_all=true)
someV, topology = basicmodel
filtered_bigFV = topology[1]
# someV, filtered_bigFV = basicmodel
bigV = someV
# bigV, tmodel = larmodel
# bigVV, bigEV, bigFV, bigCV = tmodel
# return (bigV,[FVreduced])

Plasm.View(basicmodel)
# Plasm.View((bigV,[bigVV, bigEV, filtered_bigFV]))

FV = filtered_bigFV
function get_EV(FV)
	# @info "getFV " FV
	EV = []
	for f in FV
		push!(EV, [[f[1],f[2]],[f[3],f[4]],  [f[1],f[3]],[f[2],f[4]]])
	end
	# display(cat(EV))
	@info "EV example !" EV EV[1]

	catev = cat(EV)
	@info "cat(EV)" catev
	@info "hcat(EV)" hcat(EV)
	@info "vcat(EV)" vcat(EV)
	doubleedges = Base.sort(catev)

	# doubleedges = Base.sort(cat(EV;dims=2))
	@info "EV double example" doubleedges
	doubleedges = convert(Lar.Cells, doubleedges)
	EV = [doubleedges[k] for k=1:2:length(doubleedges)]
	return EV
end
function smoothing_FV(V::Array, FV::Array{Array{Int64,1},1})
	# @info "smoothing FV " FV
	EV = get_EV(FV)
	aEV = LarSurf.ll2array(EV)

	# nrn4

	# notAllBigEV =


	kEV = LarSurf.characteristicMatrix(aEV, size(bigV)[2])
	# kEV = Lar.characteristicMatrix(EV)
	newBigV = smoothing_EV(V, kEV, 0.6)
	return newBigV
end

@info "smoothing_FV example" bigV FV FV[1]
newBigV = smoothing_FV(bigV, FV)

Plasm.View((newBigV * 100,[filtered_bigFV]))
# Plasm.View((newBigV * 100,[bigVV, bigEV, filtered_bigFV]))
