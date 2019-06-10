using Distributed
if nprocs() == 1
    addprocs(3)
end

@everywhere module MyModule
    using Distributed
    # export bar
    mat = 1
    function foo(arg1)
        println("foo: $arg1")
        println("  mat: $mat")
    end
    function foo_call_ebar(arg1)
        ebar(arg1)
    end

    # how to call this function?
    function ebar(arg1)
        println("bar: $arg1")
    end

    include("devel/everywhere__submodule.jl")
    # @everywhere include("everywhere__submodule.jl")  # LoadError
    function foo_call_sbar(arg1)
        sbar(arg1)
    end
end

MyModule.foo("1")
@spawnat 2 MyModule.foo("2")

MyModule.foo_call_sbar("2")
# MyModule.foo_call_ebar("2")  # ebar not defined
# MyModule.e_bar("2") # ebar not defined
