"""
emulate function of
'LinearAlgebraicRepresentation' package implemented by Alberto Paoluzzi.

We are using functions:
	characteristicMatrix()
	cuboidGrid()
and type definitions:
	Points
	Cells
	Cell
	LARmodel
	Chains
"""

# TODO better implementation of characteristicMatrix. Probably can use just my own function

module Lar
	using SparseArrays
	using LinearAlgebra
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



	"""
		cart(args::Array{Array{Any,1},1})::Array{Tuple,1}

	Cartesian product of collections given in the
	 unary `Array` argument. Return an `Array` of `Tuple`. The number ``n`` of output `Tuple` is equal to the *product of sizes* of input `args`
	#	Example
	```julia
	julia> cart([[1,2,3],["a","b"],[11,12]])
	# output
	12-element Array{Tuple{Any,Any,Any},1}:
	 (1, "a", 11)
	 (1, "a", 12)
	 (1, "b", 11)
	 (1, "b", 12)
	 (2, "a", 11)
	 (2, "a", 12)
	 (2, "b", 11)
	 (2, "b", 12)
	 (3, "a", 11)
	 (3, "a", 12)
	 (3, "b", 11)
	 (3, "b", 12)
	```
	"""
	function cart(args)::Array{Tuple,1}
	   return sort(vcat(collect(Iterators.product(args...))...))
	end


	"""
		larVertProd(vertLists::Array{Points,1})::Points
	Generate the integer *coordinates of vertices* (0-cells) of a *multidimensional grid*.
	*Grid n-vertices* are produced by the `larVertProd` function, via Cartesian product of vertices of ``n`` 0-dimensional arguments (vertex arrays in `vertLists`), orderly corresponding to ``x_1, x_2, ..., x_n`` coordinates in the output points ``(x_1, x_2,...,x_n)`` in ``R^n``.
	#	Example
	```julia
	julia> larVertProd([ larGrid(3)(0), larGrid(4)(0) ])
	# output
	2×20 Array{Int64,2}:
	 0  0  0  0  0  1  1  1  1  1  2  2  2  2  2  3  3  3  3  3
	 0  1  2  3  4  0  1  2  3  4  0  1  2  3  4  0  1  2  3  4
	```
	"""
	function larVertProd(vertLists::Array{Array{Int64,2},1})::Array{Int64,2}
	   coords = [[x[1] for x in v] for v in Lar.cart(vertLists)]
	   return sortslices(hcat(coords...), dims=2)
	end
	function larVertProd(vertLists::Array{Array{Float64,2},1})::Array{Float64,2}
	   coords = [[x[1] for x in v] for v in Lar.cart(vertLists)]
	   return sortslices(hcat(coords...), dims=2)
	end




	"""
		larCuboids( shape, filled=false )::Union( Cells, Array{Cells,1} )

	Multi-dimensional generator function.
	Generate either a solid *``d``-grid* of unit *``d``-cuboids* in ``d``-dimensional space, or the array of ``p``-skeletons (``0 <=p<= d``), depending on the Boolean variable `filled`. ``0``-cuboids are points, ``1``-cuboids are segments, , ``2``-cuboids are squares,  ``3``-cuboids are cubes, etc. The `shape=[a,b,c]` value determines the number ``a x b x c`` of ``d``-cells. Notice that `d = length(shape)`
	"""
	function larCuboids( shape, filled=false )
	   vertGrid = larImageVerts(shape)
	   gridMap = larGridSkeleton(shape)
	   if ! filled
	      cells = gridMap(length(shape))
	   else
	      skeletonIds = 0:length(shape)
	      cells = [ gridMap(id) for id in skeletonIds ]
	   end
	   return convert(Array{Float64,2},vertGrid), cells
	end

	cuboidGrid = larCuboids



	"""
		larCellProd(cellLists::Array{Cells,1})::Cells
	Generation of *grid cells* by *Cartesian product* of 0/1-complexes.
	The *output complex* is generated by the product of *any number* of either 0- or 1-dimensional cell complexes. The product of ``d`` 1-complexes generates *solid ``d``-cells*, while the product of ``n`` 0-complexes and ``d-n`` 1-complexes (``n < d``) generates *non-solid ``(d-n)``-cells*, properly embedded in ``d``-space, i.e. with vertices having ``d`` coordinates.
	# Examples
	To understand the *generation of cuboidal grids* from products of 0- or 1-dimensional complexes, below we show a simple example of 2D grids embedded in ``R^3``.
	In particular, `v1 = [0. 1. 2. 3.]` and `v0 = [0. 1. 2.]` are two 2-arrays of 1D vertices, `c1 = [[0,1],[1,2],[2,3]]` and `c0 = [[0],[1],[2]]` are the LAR representation of one *``1``-complex* and one *``0``-complex*, respectively. The solid 2-complex named `grid2D` is generated in 2D as follows:
	```julia
	julia> v1 = [0. 1. 2. 3.]
	1×4 Array{Float64,2}:
	 0.0  1.0  2.0  3.0
	julia> c1 = [[0,1],[1,2],[2,3]]
	3-element Array{Array{Int64,1},1}:
	 [0, 1]
	 [1, 2]
	 [2, 3]
	julia> grid2D = larVertProd([v1,v1]),larCellProd([c1,c1])
	([0.0 0.0 … 3.0 3.0; 0.0 1.0 … 2.0 3.0], Array{Int64,1}[[1, 2, 5, 6], [2, 3, 6, 7], [3, 4, 7, 8], [5, 6, 9, 10], [6, 7, 10, 11], [7, 8, 11, 12], [9, 10, 13, 14], [10, 11, 14, 15], [11, 12, 15, 16]])
	```
	whereas a *non-solid* ``2``-complex in ``3D`` is generated as:
	```julia
	julia> v1, c1 = [0. 1. 2. 3.],[[0,1],[1,2],[2,3]]
	([0.0 1.0 2.0 3.0], Array{Int64,1}[[0, 1], [1, 2], [2, 3]])
	julia> v0, c0 = [0. 1. 2.], [[0],[1],[2]]
	([0.0 1.0 2.0], Array{Int64,1}[[0], [1], [2]])
	julia> vertGrid = larVertProd([v1, v1, v0])
	3×48 Array{Float64,2}:
	 0.0  0.0  0.0  0.0  0.0  0.0  …  3.0  3.0  3.0  3.0  3.0  3.0  3.0  3.0  3.0
	 0.0  0.0  0.0  1.0  1.0  1.0  …  1.0  1.0  1.0  2.0  2.0  2.0  3.0  3.0  3.0
	 0.0  1.0  2.0  0.0  1.0  2.0  …  0.0  1.0  2.0  0.0  1.0  2.0  0.0  1.0  2.0
	julia> cellGrid = larCellProd([c1, c1, c0])
	27-element Array{Array{Int64,1},1}:
	 [1, 4, 13, 16]
	 [2, 5, 14, 17]
	 ...  ... ...
	 [32, 35, 44, 47]
	 [33, 36, 45, 48]
	julia> grid3D = vertGrid,cellGrid
	([0.0 0.0 … 3.0 3.0; 0.0 0.0 … 3.0 3.0; 0.0 1.0 … 1.0 2.0], Array{Int64,1}[[1, 4, 13, 16], [2, 5, 14, 17], … [32, 35, 44, 47], [33, 36, 45, 48]])
	julia> using Plasm
	julia> Plasm.view(grid3D)
	```
	"""
	function larCellProd(cellLists::Array{Cells,1})::Cells
	   shapes = [length(item) for item in cellLists]
	   subscripts = cart([collect(range(0, length=shape)) for shape in shapes])
	   indices = [collect(tuple) .+ 1 for tuple in subscripts]

	   jointCells = [cart([cells[k] for (k,cells) in zip(index,cellLists)])
	   				for index in indices]
	   convertIt = index2addr([ (length(cellLists[k][1]) > 1) ? shape .+ 1 : shape
	      for (k,shape) in enumerate(shapes) ])
	   [vcat(map(convertIt, map(collect,jointCells[j]))...) for j in 1:length(jointCells)]
	end



	"""
		filterByOrder( n::Int )Array{Array{Array{Int8,1},1},1}
	Filter the `array` of codes  (`Boolean` `String`) of *``n`` bits* depending on their integer value (*order*).
	# Example
	```julia
	julia> filterByOrder(3)
	# output
	4-element Array{Array{Array{Int8,1},1},1}:
	 Array{Int8,1}[Int8[0, 0, 0]]
	 Array{Int8,1}[Int8[0, 0, 1], Int8[0, 1, 0], Int8[1, 0, 0]]
	 Array{Int8,1}[Int8[0, 1, 1], Int8[1, 0, 1], Int8[1, 1, 0]]
	 Array{Int8,1}[Int8[1, 1, 1]]
	```"""
	function filterByOrder(n::Int)Array{Array{Array{Int8,1},1},1}
	   terms = [[parse(Int8,bit) for bit in collect(term)] for term in Lar.binaryRange(n)]
	   return [[term for term in terms if sum(term) == k] for k in 0:n]
	end



	"""
		larGridSkeleton( shape::Array{Int,1} )( d::Int )::Cells

	Produce the `d`-dimensional skeleton (set of `d`-cells) of a cuboidal grid of given `shape`.
	# Example
	A `shape=[1,1,1]` parameter refers to a *grid* with a single step on the three axes, i.e. to a single *3D unit cube*. Below all *skeletons* of such simplest grid are generated.
	```julia
	julia> Lar.larGridSkeleton([1,1,1])(0)
	# output
	8-element Array{Array{Int64,1},1}:
	[[1], [2], [3], [4], [5], [6], [7], [8]]
	julia> Lar.larGridSkeleton([1,1,1])(1)
	# output
	12-element Array{Array{Int64,1},1}:
	[[1,2],[3,4],[5,6],[7,8],[1,3],[2,4],[5,7],[6,8],[1,5],[2,6],[3,7],[4,8]]
	julia> Lar.larGridSkeleton([1,1,1])(2)
	# output
	6-element Array{Array{Int64,1},1}:
	[[1,2,3,4], [5,6,7,8], [1,2,5,6], [3,4,7,8], [1,3,5,7], [2,4,6,8]]
	julia> Lar.larGridSkeleton([1,1,1])(3)
	# output
	1-element Array{Array{Int64,1},1}:
	 [1, 2, 3, 4, 5, 6, 7, 8]
	```
	"""
	function larGridSkeleton(shape)
	    n = length(shape)
	    function larGridSkeleton0( d::Int )::Cells

	    	@assert d<=n

	        components = filterByOrder(n)[d .+ 1]
	        apply(fun,a) = fun(a)
			componentCellLists = [ [map(f,x)  for (f,x) in  zip( [larGrid(dim)
				for dim in shape], convert(Array{Int64,1},component) ) ]
					for component in components ]
	        colList(arr) = [arr[:,k]  for k in 1:size(arr,2)]
	        out = [ larCellProd(map(colList,cellLists)) for cellLists in componentCellLists ]
	        return vcat(out...)
	    end
	    return larGridSkeleton0
	end


	"""
		larImageVerts(shape::Array{Int,1})::Array{Int64,2}
	Linearize the *grid of integer vertices*, given the `shape` of a *cuboidal grid* (typically an *image*).
	# Examples
	```julia
	julia> larImageVerts([1024,1024])
	# output
	2×1050625 Array{Int64,2}:
	 0  0  0  0  0  0  0  0  0  0   0   0 … 1024  1024  1024  1024  1024  1024  1024  1024
	 0  1  2  3  4  5  6  7  8  9  10  11 … 1017  1018  1019  1020  1021  1022  1023  1024

	julia> larImageVerts([1,1,1])
	# output
	3×8 Array{Int64,2}:
	 0  0  0  0  1  1  1  1
	 0  0  1  1  0  0  1  1
	 0  1  0  1  0  1  0  1
	```
	"""
	function larImageVerts( shape::Array{Int,1} )::Array{Int64,2}
	   vertexDomain(n) = hcat([k for k in 0:n-1]...)
	   vertLists = [vertexDomain(k+1) for k in shape]
	   vertGrid = larVertProd(vertLists)
	   return vertGrid
	end

	"""
    binaryRange(n)
	Generate the first `n` binary numbers in string padded for max `2^n` length
	"""
	function binaryRange(n)
	    return string.(range(0, length=2^n), base=2, pad=n)
	end


	"""
		index2addr(shape::Array{Int64,1})(multiIndex)::Int
	*Multi-index to address* transformation. Multi-index is a *generalization* of the concept of an integer index to an *ordered tuple of indices*.
	The second-order utility function `index2addr`  transforms a `shape` list for a *multidimensional array* into a function that, when applied to a *multindex array*, i.e. to a list of integer `Tuple` within the `shape`'s bounds, returns the *integer addresses* of the corresponding array components within the *linear storage* of the multidimensional array.
	#	Example
	Notice that in the example below, there are ``3 x 6`` different *multi-index values* for the variable `index`, generated by `cart([ 0:2, 0:5 ])`.
	```julia
	julia> [index2addr([3,6])(collect(index)) for index in cart([ 0:2, 0:5 ])]'
	# output
	1×18 RowVector{Int64,Array{Int64,1}}:
	 1  2  3  4  5  6  7  8  9  10  11  12  13  14  15  16  17  18

	julia> index2addr([3,6])([0,0])
	# output
	1
	julia> index2addr([3,6])([2,5])
	# output
	18
	```
	"""
	function index2addr( shape::Array{Int64,2} )
	    n = length(shape)
	    theShape = append!(shape[2:end],1)
	    weights = [prod(theShape[k:end]) for k in range(1, length=n)]

	    function index2addr0( multiIndex::Array{Int,1} )::Int
	        return dot(collect(multiIndex), weights) + 1
	    end

	    return index2addr0
	end


	"""
		index2addr(shape::Array{Int64,2})(multiIndex::Array{Int,1})::Int
	Multi-index to address transformation. Partial function allowing for using both horizontal and vertical vectors for `shape` parameter. Notice that multi-indices are used here as *coordinates of grid points*, hence they start from tuples of zeros. Accordingly, the translation formula for multi-index to address transformation is *0-based*.
	"""
	function index2addr(shape::Array{Int64,1})
	   index2addr(hcat(shape...))
	end



	"""
			characteristicMatrix( FV::Cells )::ChainOp
		Binary matrix representing by rows the `p`-cells of a cellular complex.
		The input parameter must be of `Cells` type. Return a sparse binary matrix,
		providing the basis of a ``Chain`` space of given dimension. Notice that the
		number of columns is equal to the number of vertices (0-cells).
		# Example
		```julia
		V,(VV,EV,FV,CV) = cuboid([1.,1.,1.], true);
		julia> Matrix(characteristicMatrix(FV))
		6×8 Array{Int8,2}:
		1  1  1  1  0  0  0  0
		0  0  0  0  1  1  1  1
		1  1  0  0  1  1  0  0
		0  0  1  1  0  0  1  1
		1  0  1  0  1  0  1  0
		0  1  0  1  0  1  0  1
		julia> Matrix(characteristicMatrix(CV))
		1×8 Array{Int8,2}:
		1  1  1  1  1  1  1  1
		julia> Matrix(characteristicMatrix(EV))
		12×8 Array{Int8,2}:
		1  1  0  0  0  0  0  0
		0  0  1  1  0  0  0  0
		0  0  0  0  1  1  0  0
		0  0  0  0  0  0  1  1
		1  0  1  0  0  0  0  0
		0  1  0  1  0  0  0  0
		0  0  0  0  1  0  1  0
		0  0  0  0  0  1  0  1
		1  0  0  0  1  0  0  0
		0  1  0  0  0  1  0  0
		0  0  1  0  0  0  1  0
		0  0  0  1  0  0  0  1
		```
	"""
	function characteristicMatrix( FV::Cells )::ChainOp
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
    lar2obj(V::Points, cc::ChainComplex)
Triangulated OBJ string representation of the model passed as input.
Use this function to export LAR models into OBJ
# Example
```julia
	julia> cube_1 = ([0 0 0 0 1 1 1 1; 0 0 1 1 0 0 1 1; 0 1 0 1 0 1 0 1],
	[[1,2,3,4],[5,6,7,8],[1,2,5,6],[3,4,7,8],[1,3,5,7],[2,4,6,8]],
	[[1,2],[3,4],[5,6],[7,8],[1,3],[2,4],[5,7],[6,8],[1,5],[2,6],[3,7],[4,8]] )
	julia> cube_2 = Lar.Struct([Lar.t(0,0,0.5), Lar.r(0,0,pi/3), cube_1])
	julia> V, FV, EV = Lar.struct2lar(Lar.Struct([ cube_1, cube_2 ]))
	julia> V, bases, coboundaries = Lar.chaincomplex(V,FV,EV)
	julia> (EV, FV, CV), (copEV, copFE, copCF) = bases, coboundaries
	julia> FV # bases[2]
	18-element Array{Array{Int64,1},1}:
	 [1, 3, 4, 6]
	 [2, 3, 5, 6]
	 [7, 8, 9, 10]
	 [1, 2, 3, 7, 8]
	 [4, 6, 9, 10, 11, 12]
	 [5, 6, 11, 12]
	 [1, 4, 7, 9]
	 [2, 5, 11, 13]
	 [2, 8, 10, 11, 13]
	 [2, 3, 14, 15, 16]
	 [11, 12, 13, 17]
	 [11, 12, 13, 18, 19, 20]
	 [2, 3, 13, 17]
	 [2, 13, 14, 18]
	 [15, 16, 19, 20]
	 [3, 6, 12, 15, 19]
	 [3, 6, 12, 17]
	 [14, 16, 18, 20]
	julia> CV # bases[3]
	3-element Array{Array{Int64,1},1}:
	 [2, 3, 5, 6, 11, 12, 13, 14, 15, 16, 18, 19, 20]
	 [2, 3, 5, 6, 11, 12, 13, 17]
	 [1, 2, 3, 4, 6, 7, 8, 9, 10, 11, 12, 13, 17]
	julia> copEV # coboundaries[1]
	34×20 SparseMatrixCSC{Int8,Int64} with 68 stored entries: ...
	julia> copFE # coboundaries[2]
	18×34 SparseMatrixCSC{Int8,Int64} with 80 stored entries: ...
	julia> copCF # coboundaries[3]
	4×18 SparseMatrixCSC{Int8,Int64} with 36 stored entries: ...
	objs = Lar.lar2obj(V'::Lar.Points, [coboundaries...])
	open("./two_cubes.obj", "w") do f
    	write(f, objs)
	end
```
"""
function lar2obj(V::Lar.Points, cc::Lar.ChainComplex)
    copEV, copFE, copCF = cc
	if size(V,2) > 3
		V = convert(Lar.Points, V') # out V by rows
	end
    obj = ""
    for v in 1:size(V, 1)
        obj = string(obj, "v ",
    	round(V[v, 1], digits=6), " ",
    	round(V[v, 2], digits=6), " ",
    	round(V[v, 3], digits=6), "\n")
    end

    print("Triangulating")
    triangulated_faces = Lar.triangulate(V, cc[1:2])
    println("DONE")

    for c in 1:copCF.m
        obj = string(obj, "\ng cell", c, "\n")
        for f in copCF[c, :].nzind
            triangles = triangulated_faces[f]
            for tri in triangles
                #t = copCF[c, f] > 0 ? tri : tri[end:-1:1]
				t = tri
                obj = string(obj, "f ", t[1], " ", t[2], " ", t[3], "\n")
            end
        end
    end

    return obj
end

end
