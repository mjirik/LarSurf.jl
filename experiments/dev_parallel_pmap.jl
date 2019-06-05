using Distributed
if nprocs() == 1
    addprocs(3)
end

function bigfunc(iterator)
  localvar = 2.5

  smallfunc = function (elm)
    # hypothetical (expensive) operation with elm
    # (in my code this is solving a linear system)
    localvar * elm
  end

  pmap(smallfunc, iterator)
end

bigfunc(1:10)
