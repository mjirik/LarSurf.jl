module DummyModule

export MyType, f

mutable struct MyType
    a::Int
end

f(x) = x^2+1

println("loaded")

end

# @everywhere include("devel/DummyModule.jl") this works
