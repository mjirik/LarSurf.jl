module Lar
	using SparseArrays
		"""
		Points = Array{Number,2}

	Alias declation of LAR-specific data structure.
	Dense `Array{Number,2,1}` ``M x N`` to store the position of *vertices* (0-cells)
	of a *cellular complex*. The number of rows ``M`` is the dimension
	of the embedding space. The number of columns ``N`` is the number of vertices.
	"""
	const Points = Matrix

	const Cells = Array{Array{Int,1},1}
    const LARmodel = Tuple{Points,Array{Cells,1}}
	const Cell = SparseVector{Int8, Int}

	"""
		Chain = SparseArrays.SparseVector{Int8,Int}

	Alias declation of LAR-specific data structure.
	Binary `SparseVector` to store the coordinates of a `chain` of `N-cells`. It is
	`nnz=1` with `value=1` for the coordinates of an *elementary N-chain*, constituted by
	a single *N-chain*.
	"""
	const Chain = SparseArrays.SparseVector{Int8,Int}


	"""
		ChainOp = SparseArrays.SparseMatrixCSC{Int8,Int}

	Alias declation of LAR-specific data structure.
	`SparseMatrix` in *Compressed Sparse Column* format, contains the coordinate
	representation of an operator between linear spaces of `P-chains`.
	Operators ``P-Boundary : P-Chain -> (P-1)-Chain``
	and ``P-Coboundary : P-Chain -> (P+1)-Chain`` are typically stored as
	`ChainOp` with elements in ``{-1,0,1}`` or in ``{0,1}``, for
	*signed* and *unsigned* operators, respectively.
	"""
	const ChainOp = SparseArrays.SparseMatrixCSC{Int8,Int}




	"""
		grid_0(n::Int)::Array{Int64,2}
	Generate a *uniform 0D cellular complex*.
	The `grid_0` function generates a 0-dimensional uniform complex embedding ``n+1`` equally-spaced  0-cells (at *unit interval* boundaries). It returns by columns the cells of this 0-complex as `Array{Int64,2}.
	#	Example
	```julia
	julia> grid_0(10)
	# output
	1×11 Array{Int64,2}:
	 0  1  2  3  4  5  6  7  8  9  10
	```
	"""
	function grid_0(n::Int)::Array{Int64,2}
	    return hcat([[i] for i in range(0, length=n+1)]...)
	end


	"""
		grid_1(n::Int)::Array{Int64,2}
	Generate a *uniform 1D cellular complex*.
	The `grid_1` function generates a 0-dimensional uniform complex embedding ``n+1`` equally-spaced  1-cells (*unit intervals*). It returns by columns the cells of this 1-complex as `Array{Int64,2}`.
	#	Example
	```julia
	julia> grid_1(10)
	# output
	2×10 Array{Int64,2}:
	 0  1  2  3  4  5  6  7  8   9
	 1  2  3  4  5  6  7  8  9  10
	```
	"""
	function grid_1(n)
	    return hcat([[i,i+1] for i in range(0, length=n)]...)
	end


	"""
		larGrid(n::Int)(d::Int)::Array{Int64,2}
	Generate either a *uniform 0D cellular complex* or a *uniform 1D cellular complex*.
	A `larGrid` function is given to generate the LAR representation of the cells of either a 0- or a 1-dimensional complex, depending on the value of the `d` parameter, to take values in the set ``{0,1}``, and providing the *order* of the output complex.
	#	Example
	```julia
	julia> larGrid(10)(0)
	# output
	1×11 Array{Int64,2}:
	 0  1  2  3  4  5  6  7  8  9  10
	julia> larGrid(10)(1)
	# output
	2×10 Array{Int64,2}:
	 0  1  2  3  4  5  6  7  8   9
	 1  2  3  4  5  6  7  8  9  10
	```
	"""
	function larGrid(n::Int)
	    function larGrid1(d::Int)::Array{Int64,2}
	        if d==0
	         return grid_0(n)
	        elseif d==1
	         return grid_1(n)
	        end
	    end
	    return larGrid1
	end
end
