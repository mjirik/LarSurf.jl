import SparseArrays.spzeros
import SparseArrays.rowvals
import SparseArrays.nzrange
import SparseArrays.nonzeros
# using LinearAlgebraicRepresentation
# Lar = LinearAlgebraicRepresentation

# @everywhere begin



    """
    Filter sparse matrix. Set new values in matrix.
    """
    function sparse_filter!(sparse, what_to_find, true_value, false_value)
        A = sparse
        vals = nonzeros(A)
        for j=1:length(vals)
        # rows = rowvals(A)
        # # m, n = size(A)
        # n = size(A, 2)
        # for i = 1:n
        #    for j in nzrange(A, i)
        #       # row = rows[j]
              # val = vals[j]
              if vals[j] == what_to_find
                  newval = true_value
              else
                  newval = false_value
              end
              vals[j] = newval
        #    end
        end
        return A
    end

    function sparse_filter_old!(sparse, what_to_find, true_value, false_value)
        A = sparse
        rows = rowvals(A)
        vals = nonzeros(A)
        m, n = size(A)
        for i = 1:n
           for j in nzrange(A, i)
              row = rows[j]
              val = vals[j]
              if val == what_to_find
                  newval = true_value
              else
                  newval = false_value
              end
              vals[j] = newval
           end
        end
        return A
    end

	function unsafe_resize(sp::SparseMatrixCSC,m,n)
		newcolptr = sp.colptr
		resize!(newcolptr,n+1)
		for i=sp.n+2:n+1
	    	newcolptr[i] = sp.colptr[sp.n+1]
	 	end
	  	return SparseMatrixCSC(m,n,newcolptr,sp.rowval,sp.nzval)
	end

	"""
	From indexed base matrix to sparse array with 0 and 1
	Original implementation by Alberto Paoluzzi
	"""
	function characteristicMatrix_push( FV::LarSurf.Lar.Cells)::LarSurf.Lar.ChainOp
		I,J,V = Int64[],Int64[],Int8[]
		for f=1:length(FV)
			for k in FV[f]
			push!(I,f)
			push!(J,k)
			push!(V,1)
			end
		end
		M_2 = sparse(I,J,V)
		return M_2
	end

	"""
	From indexed base matrix to sparse array with 0 and 1
	"""
	function characteristicMatrix_set( FV::LarSurf.Lar.Cells)::LarSurf.Lar.ChainOp
	    sz = length(FV) * length(FV[1])
	    I = Array{Int64,1}(undef, sz)
	    J = Array{Int64,1}(undef, sz)
	    V = Array{Int8,1}(undef, sz)
	    i = 1
		for f=1:length(FV)
			for k in FV[f]
	            I[i] = f
	            J[i] = k
	            V[i] = 1
	            i = i + 1
			end
		end
		M_2 = sparse(I,J,V)
		return M_2
	end

	"""
	From indexed base matrix to sparse array with 0 and 1
	"""
	function characteristicMatrix_push( FV::Array{Int64,2})
	    I,J,V = Int64[],Int64[],Int8[]
	    for f=1:size(FV, 1)
	        for k in FV[f, :]
	        push!(I,f)
	        push!(J,k)
	        push!(V,1)
	        end
	    end
	    M_2 = sparse(I,J,V)
	    return M_2
	end


	function characteristicMatrix_set( FV::Array{Int64,2})
	    sz = length(FV)
	    I = Array{Int64,1}(undef, sz)
	    J = Array{Int64,1}(undef, sz)
	    V = Array{Int8,1}(undef, sz)
	    i = 1
	    for f=1:size(FV, 1)
	        for k in FV[f, :]
	            I[i] = f
	            J[i] = k
	            V[i] = 1
	            i = i + 1

	        end
	    end
	    M_2 = sparse(I,J,V)
	    return M_2
	end

	# function characteristicMatrix_parallel( FV::Array{Int64,2})
	# #     sz = size(FV, 1)
	#     sz = length(FV)
	#     I = SharedArray{Int64,1}(sz)
	#     J = SharedArray{Int64,1}(sz)
	#     V = SharedArray{Int8,1}(sz)
	#     ii = SharedArray{Int64,1}(1)
	# #     I,J,V = Int64[],Int64[],Int8[]
	#     println("sz $sz")
	#     println(size(FV))
	#     println(length(FV))
	#     ii[1] = 1
	#     @sync @distributed for f=1:size(FV, 1)
	# #     for f=1:size(FV, 1)
	#         for k in FV[f, :]
	#             I[ii[1]] = f
	#             J[ii[1]] = k
	#             V[ii[1]] = 1
	#             ii[1] = ii[1] + 1
	#
	# #         push!(I,f)
	# #         push!(J,k)
	# #         push!(V,1)
	#         end
	#     end
	#     println("i=${ii[1]}")
	#     M_2 = sparse(I,J,V)
	#     return M_2
	# end
	characteristicMatrix(FV::Array{Int64,2}) = characteristicMatrix_set(FV::Array{Int64,2})
	characteristicMatrix(FV::LarSurf.Lar.Cells) = characteristicMatrix_set(FV::LarSurf.Lar.Cells)

	function characteristicMatrix(FV::Array{Int64,2}, nvertices)
    	mat = characteristicMatrix(FV)
    	return unsafe_resize(mat, size(mat, 1), nvertices)
	end

    """
    Expand indexes into sparse horizontally.
    Convert CV with vertex indexes (Int64) to sparse CV with just zeros and ones.
	Slow implementation.

    It should be the same as lar.CharacteristicMatrix()
    """
    function _CVi_to_CV01(CVi, nvertices)
        nc = size(CVi)[1]
        nvertices_per_C = size(CVi)[2]
        CV01 = spzeros(Int8, nc, nvertices)

        for k in 1:nc
            for i in 1:nvertices_per_C
                # print("vert k: ", k,", i: ", i)
                vertind = CVi[k, i]
                # print(" vert ind: ", vertind, "\n")
                CV01[k, vertind] = 1
            end
        end
        return CV01
    end

    # CV01 = CVi_to_CV01(CVi, nvertices)

    # VF to sparse
    # print("VF to sparse")


    """
    Expand indexes into sparse verticaly.
    Convert CV with vertex indexes (Int64) to sparse CV with just zeros and ones.
	Slow implementation.

    """
    function _VFi_to_VF01(VFi, nvertices)
        nfaces = size(VFi)[2]
        VF01 = spzeros(Int8, nvertices, nfaces)

        for k in 1:size(VFi)[1]
            for i in 1:(size(VFi)[2])
                # print("vert k: ", k,", i: ", i)
                vertind = VFi[k, i]
                # print(" vert ind: ", vertind, "\n")
                VF01[vertind, i] = 1
            end
        end
        return VF01
    end
    # ind_to_sparse_v = VFi_to_VF01

    # VF01 = ind_to_sparse_v(VFi, nvertices)
    """
    Based on matrix with indexes expand the index into sparse array containing one
    and zero. Deprecated. Use LarSurf.Lar.characteristicMatrix().
    """
    function characteristicMatrix(CVi, nvertices, axis=2)
        if axis == 1
            CV01 = _VFi_to_VF01(CVi, nvertices)
        elseif axis == 2
			CV01 = characteristicMatrix(CVi, nvertices)
            # CV01 = _CVi_to_CV01(CVi, nvertices)
        else
            error("Axis should be 1 or 2")
        end
        return CV01
    end

    function characteristicMatrix_for_loop(CVi, nvertices, axis=2)
        if axis == 1
            CV01 = _VFi_to_VF01(CVi, nvertices)
        elseif axis == 2
            CV01 = _CVi_to_CV01(CVi, nvertices)
        else
            error("Axis should be 1 or 2")
        end
        return CV01
    end


    ind_to_sparse = characteristicMatrix

	"""
	Check two arrays. Return true if their elements are same.
	"""
	function match_arr(arr1::Array, arr2::Array)
    for i =1:length(arr1)
        if arr1[i] != arr2[i]
            println("Element i=$i is not in match. $(arr1[i]) != $(arr2[i])")
            return false
        end
    end
    return true
end
    """
    Input is list of lists
    Output is 2D Array
    """
    function ll2array(CVill::Array)
        nc = size(CVill)[1]
        CVi = Array{typeof(CVill[1][1])}(undef, size(CVill)[1], size(CVill[1])[1])
        for k in 1:nc
            CVi[k, :] = CVill[k]
        end
        return CVi
    end

	"""
	Convert 2D array to list of lists.
	"""
	function array2ll(CVarr::Union{Array{Int64,2}, Array{Int8,2}})
    na, nb = size(CVarr)
	arr = Array{Array{eltype(CVarr),1},1}(undef, na)
    for i=1:na
        arr[i] = CVarr[i, :]
    end
    return arr
	end

    """
    Create VV matrix representing identity matrix in list of lists format with indices.

    julia> createVVll(5)

    [[1], [2], [3], [4], [5]]
    """
    function createVVll(number_of_vertices)

        VVm32 = [[i] for i=1:size_of_vertices]
        return VVm32
    end


    """
    Convert size in tuple to size in array
    """
    function size_as_array(block_size)
        if typeof(block_size) == Tuple{Int64,Int64,Int64}
            block_size = [block_size[1], block_size[2], block_size[3]]
        end
        return block_size
    end

    function hard_max!(stop, data_size)
        for i=1:length(stop)
            if data_size[i] < stop[i]
                stop[i] = data_size[i]
            end
        end
        return stop
    end


    # function check_LARmodel(larmodel::Lar.LARmodel)
    function check_LARmodel(larmodel::Lar.LARmodel)
        V, topology = larmodel
        n_nodes = size(V)[2]

        for i=1:length(topology)
            mx = maximum(maximum(topology[i]))
            if n_nodes < mx
                error("Maximal node ID is $n_nodes but in $i-th topology is maximum $mx")
                return false
            end
        end
        return true

    end

# end
