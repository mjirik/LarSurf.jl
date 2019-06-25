module Smoothing
using SparseArrays
using LarSurf

# function eye(sz)
#     arr = spzeros(Int8, sz, sz)
#     for i=1:sz
#         arr[i,i] = 1
#     end
#     return arr
# end
#
# function setIzero!(arr)
#     for i=1:size(arr)[1]
#         arr[i,i] = 0
#     end
#     return arr
# end
#
# function getDiag(arr)
#     sz = size(arr)[1]
#     arro = zeros(eltype(arr), sz)
#     for i=1:sz
#         arro[i] = arr[i,i]
#     end
#     return arro
# end
#
# function make_full(arr)
#     arrout = Array{eltype(arr), 2}(undef, size(arr)...)
#     for i=1:size(arr)[1]
#         for j=1:size(arr)[2]
#             arrout[i,j] = arr[i,j]
#         end
#     end
#     return arrout
# end
# #neighboor vertexes
#
# """
# Smoothing based on EV
# """
# function smoothing_EV(V, EVch::SparseArrays.SparseMatrixCSC, k=0.35)
# #     Matrix(setIzero!(EVch' * EVch))
#
#     neighboorNumber = getDiag(EVch' * EVch)
#     neighboors = setIzero!(EVch' * EVch)
#
# #     targetV =  neighboors * V' ./ neighboorNumber
# #     diff = targetV - V'
# #     newV = (V' + k * diff)'
#
#     targetV = V * neighboors ./ neighboorNumber'
#     # println("targetV shape: ", size(targetV))
#     diff = targetV - V
#     # println("diff shape: ", size(diff))
#     newV = V + k * diff
#
#     return make_full(newV)
# end




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
    # println("targetV shape: ", size(targetV))
    diff = targetV - V
    # println("diff shape: ", size(diff))
    newV = V + k * diff

    return make_full(newV)
end

# smoothing_EV(V, EVch)


# function get_EV(FV::Array{Array{Int64,1},1})
# function get_EV(FV)
# 	EV = []
# 	for f in FV
# 		push!(EV, [[f[1],f[2]],[f[3],f[4]],  [f[1],f[3]],[f[2],f[4]]])
# 	end
# 	print("EV")
# 	display(EV)
# 	display(cat(EV))
# 	# doubleedges = sort(cat(EV,1))
# 	# doubleedges = convert(Lar.Cells, doubleedges)
# 	# EV = [doubleedges[k] for k=1:2:length(doubleedges)]
# 	return EV
# end
#
# function smoothing_FV(V::Array, FV::Array{Array{Int64,1},1})
# 	@info "smoothing FV" FV
# 	EV = get_EV(FV)
# 	# aEV = LarSurf.ll2array(EV)
# 	#
# 	# kEV = LarSurf.characteristicMatrix(aEV, size(bigV)[2])
# 	# smoothing_EV(V, kEV)
# end

function get_EV(FV)
	# @info "getFV " FV
	EV = []
	for f in FV
		push!(EV, [[f[1],f[2]],[f[3],f[4]],  [f[1],f[3]],[f[2],f[4]]])
	end
	display(cat(EV))
	doubleedges = sort(cat(EV))
	doubleedges = convert(LarSurf.Lar.Cells, doubleedges)
	EV = [doubleedges[k] for k=1:2:length(doubleedges)]
	return EV
end
function smoothing_FV(V::Array, FV::Array{Array{Int64,1},1}, k=0.35)
	# @info "smoothing FV " FV
	EV = get_EV(FV)
	# LarSurf
	aEV = LarSurf.ll2array(EV)

	# nrn4

	# notAllBigEV =


	# kEV = LarSurf.characteristicMatrix(aEV, size(bigV)[2])
	kEV = LarSurf.characteristicMatrix(aEV, size(V)[2])
	# kEV = Lar.characteristicMatrix(EV)
	newBigV = smoothing_EV(V, kEV, k)
	return newBigV
end


end
