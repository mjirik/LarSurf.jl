
module lario3d
    using LinearAlgebraicRepresentation
    Lar = LinearAlgebraicRepresentation

    export version
    # export convert
    hello(who::String) = "Hello, $who"

    include("convert.jl")
    include("read.jl")
    include("plasm.jl")
    include("surface.jl")
    include("representation.jl")
    include("import3d.jl")
    include("block.jl")
    include("sampledata.jl")
    include("io3d.jl")
    include("arr_fcn.jl")
    include("boundary_operator.jl")
    include("inner_boundary.jl")
    include("datasets.jl")
    include("surface_extraction.jl")
    include("experiment_support.jl")
    include("brick_surf_extraction.jl")

    function version()
        return "0.0.2"
    end

end
