using Distributed
if nprocs() == 1
    addprocs(3)
end


function foo(arg1)
    print("foo: $arg1")
end

@everywhere function bar(arg1)
    print("foo: $arg1")
end

foo("1")
bar("2")
