
module LarSurf
    using Distributed
    using Logging
	using SparseArrays
    # @everywhere using LinearAlgebraicRepresentation
    # Lar = LinearAlgebraicRepresentation
    println("Loaded M on $(myid())")

    export version
    # export convert
    hello(who::String) = "Hello, $who"

    # @everywhere LarSurf.ahoj("ku")
    # include("ahoj.jl")
    # @everywhere include("ahoj.jl")

	include("lar.jl")
    include("convert.jl")
    include("print_function.jl")
    include("arr_fcn.jl")
    include("read.jl")
    include("plasm.jl") ;
    include("surface.jl") ;
    include("representation.jl") ;
    include("import3d.jl") ;
    include("block.jl") ;
    include("sampledata.jl") ;
    include("io3d.jl") ;
    include("boundary_operator.jl") ;
    include("inner_boundary.jl") ;
    include("datasets.jl") ;
    include("surface_extraction.jl") ;
    include("experiment_support.jl") ;
    include("brick_surf_extraction.jl") ;
    include("surface_extraction_parallel.jl") ;

    function version()
        return "0.0.2"
    end

end
