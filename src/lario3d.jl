module lario3d

export version
hello(who::String) = "Hello, $who"

include("read.jl")
function version()
    return "0.0.2"
end

end
