
module LarSurf
    using Logging
    using Distributed
	using SparseArrays
	using JLD2, FileIO
	# using Pkg
    # @everywhere using LinearAlgebraicRepresentation
    # Lar = LinearAlgebraicRepresentation
    @info "Loaded M on $(myid())"

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
	include("triangulation.jl")
    # include("read.jl")
    # include("plasm.jl") ;
    include("surface.jl") ;
    include("representation.jl") ;
    include("import3d.jl") ;
    include("block.jl") ;
    include("sampledata.jl") ;
    # include("io3d.jl") ;
    include("boundary_operator.jl") ;
    # include("inner_boundary.jl") ;
    include("datasets.jl") ;
    include("surface_extraction.jl") ;
    # include("experiment_support.jl") ;
    include("brick_surf_extraction.jl") ;
    include("surface_extraction_parallel_low_comunication.jl") ;
    # include("surface_extraction_parallel.jl") ;
	include("surface_extraction_per_voxel.jl")
	include("smoothing.jl")
	# if "ExSup" in keys(Pkg.installed())
		include("larsurf_experiments.jl")
	# end
	# include("dicom_support.jl")

    function version()
        return "0.0.2"
    end

end
