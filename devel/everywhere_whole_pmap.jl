using Distributed
if nprocs() == 1
    addprocs(3)
end
@everywhere using ParallelDataTransfer

@everywhere module MyModule
    using Distributed
    # export bar
    mat = 1
    function set_mat(arg1)
        global mat
        # println("mat: ", mat)
        println("set mat $arg1")
        mat = arg1
        println("mat: $mat")
    end
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

    function run(data)
        inner_parameter = 2
        # z = randn(10, 10);
        # sendto(workers(), MyModule.set_mat(mat))
        @spawn MyModule.set_mat(4)
        function suma(data_row)
            println("suma on $(myid())")
            println("  suma mat: $mat")

            return sum(data_row)
        end
        output = pmap(suma, data)
        return output
    end
end

MyModule.foo("1")
@spawnat 2 MyModule.foo("2")

MyModule.foo_call_sbar("2")
# MyModule.foo_call_ebar("2")  # ebar not defined
# MyModule.e_bar("2") # ebar not defined
data = [rand(Int8, 10), rand(Int8, 10), rand(Int8, 10)]

@everywhere MyModule.set_mat(3)
output = MyModule.run(data)
output
output
