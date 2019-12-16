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

	EVchPow = EVch' * EVch
    neighboorNumber = getDiag(EVchPow)
    neighboors = setIzero!(EVchPow)
	dropzeros!(neighboors)

#     targetV =  neighboors * V' ./ neighboorNumber
#     diff = targetV - V'
#     newV = (V' + k * diff)'

	# println("neighboors 2")
	# println(EVchPow)
	# println("neighboors")
	# println(neighboors)
	# println("neighboors number")
	# println(neighboorNumber)
    targetV = (V * neighboors) ./ neighboorNumber'
    # println("targetV shape: ", size(targetV))
    diff = targetV - V
	# @info "sm V orig   $(V[:,1:5])"
	# @info "sm V target $(targetV[:,1:5])"
	# @info "sm V diff   $(diff[:,1:5])"
    # println("diff shape: ", size(diff))
    newV = V + k * diff

    return make_full(newV)
end


"""
Get EV array from FV of surface of quads. Filtration step does not work for non surface
objects. But implementation is prepared for triangles
"""
function get_EV_quads(FV::Array{Array{Int64,1},1}; return_unfiltered=false, data=nothing)
	@debug "getFV " FV
	# EV = []
	# for f in FV
	# 	push!(EV, [[f[1],f[2]],[f[3],f[4]],  [f[1],f[3]],[f[2],f[4]]])
	# 	# push!(EV, [[f[1],f[2]],[f[3],f[4]],  [f[1],f[3]],[f[2],f[4]]])
	# end
	if size(FV[1],1) == 4

		# couples = [[1,2], [3,4], [1,3], [2,4]]
		couples = [[1,2], [2,3], [3,4], [4,1]]
	else
		couples = [[1,2], [2,3], [3,1]]
	end
	szc = size(couples,1)

	ev_time = @elapsed EV = reshape([sort([f[couples[c][1]], f[couples[c][2]]]) for f in FV, c=1:szc],:)
	# doubleedges = Base.sort(mycat(EV))
	if return_unfiltered
		if data != nothing
			data["smoothing EV construction time [s]"] = ev_time
		end
		return EV
	end
    ev_unique_time = @elapsed EVnew = collect(Set(EV))
	if data != nothing
		data["smoothing EV construction time [s]"] = ev_time
		data["smoothing make EV unique time [s]"] = ev_unique_time
	end
	return EVnew
	# doubleedges = Base.sort(EV)
	# doubleedges = convert(LarSurf.Lar.Cells, doubleedges)
	# newEV = [doubleedges[k] for k=1:2:length(doubleedges)]
	# return newEV
end

function get_EV_quads2(FV::Array{Array{Int64,1},1}; return_unfiltered=false)
	# @info "getFV " FV
	# EV = []
	# for f in FV
	# 	push!(EV, [[f[1],f[2]],[f[3],f[4]],  [f[1],f[3]],[f[2],f[4]]])
	# 	# push!(EV, [[f[1],f[2]],[f[3],f[4]],  [f[1],f[3]],[f[2],f[4]]])
	# end
	if size(FV[1],1) == 4
		couples = [[1,2], [3,4], [1,3], [2,4]]
	else
		couples = [[1,2], [2,3], [3,1]]
	end
	EV = reshape([sort([f[couples[c][1]], f[couples[c][2]]]) for f in FV, c=1:size(couples,1)],:)
	# doubleedges = Base.sort(mycat(EV))
	if return_unfiltered
		return EV
	end
	doubleedges = Base.sort(EV)
	doubleedges = convert(LarSurf.Lar.Cells, doubleedges)
	newEV = [doubleedges[k] for k=1:2:length(doubleedges)]
	return newEV
end

"""
Smoothing with defined k. Works for quads or triangles.
"""
function smoothing_FV(V::Array, FV::Array{Array{Int64,1},1}, k=0.35, n=1)
	@info "smoothing V by FV, size(V) = $(size(V)), size(FV) = $(size(FV))"

	EV = LarSurf.Smoothing.get_EV_quads(FV)
	# kEV = LarSurf.characteristicMatrix(aEV, size(bigV)[2])
	# kEV = LarSurf.characteristicMatrix(aEV, size(V)[2])
	aEV = LarSurf.ll2array(EV)
	kEV = LarSurf.characteristicMatrix(aEV, size(V)[2])
	# kEV = Lar.characteristicMatrix(EV)
	# @info "computing new V" @__MODULE__
	# @info "computing new V" @__FILE__
	newV = V
	for i=1:n
		newV = smoothing_EV(newV, kEV, k)
	end
	return newV
end

function smoothing_FV_taubin(V::Array, FV::Array{Array{Int64,1},1}, k1=0.35, k2=-0.1, n=1, data=nothing)
	@info "smoothing V by FV, size(V) = $(size(V)), size(FV) = $(size(FV))"
	if size(FV[1],1) == 4
		@info "FV are quads"
	else
		@info "FV are triangles"
	end
	EV = get_EV_quads(FV, data=data)

	# LarSurf
	aEV = LarSurf.ll2array(EV)

	# kEV = LarSurf.characteristicMatrix(aEV, size(bigV)[2])
	kEV = LarSurf.characteristicMatrix(aEV, size(V)[2])
	# kEV = Lar.characteristicMatrix(EV)
	@info "computing new V"
	newV = V
	taubin_time = @elapsed for i=1:n
		@info "taubin iteration $(i)"
		newV = smoothing_EV(newV, kEV, k1)
		newV = smoothing_EV(newV, kEV, k2)
	end

	if data != nothing
		data["smoothing taubin iterations time [s]"] = taubin_time
	end
	return newV
end

# """
# Iterative smoothing
# """
# function smoothing_FV(V::Array, FV::Array{Array{Int64,1},1}, k::Real, n::Integer)
# 	Vtmp = V
# 	for i=1:n
# 		Vtmp = smoothing_FV(Vtmp, FV, k)
# 	end
# 	return Vtmp
#
# end
#
# """
# Iterative smoothing
# """
# function smoothing_FV_taubin(V::Array, FV::Array{Array{Int64,1},1}, k1::Real, k2::Real, n::Integer)
# 	Vtmp = V
# 	for i=1:n
# 		Vtmp = smoothing_FV(Vtmp, FV, k1)
# 		Vtmp = smoothing_FV(Vtmp, FV, k2)
# 	end
# 	return Vtmp
#
# end

end
