using Distributed
if nprocs() == 1
    addprocs(3)
end

@everywhere function used_in_smallfunc(par1, par2)
  println(par1, par2, " ")
  return par1 + par2
end

function bigfunc(iterator)
  localvar = 2.5
  pars = (1, 15)

  smallfunc = function (elm)
    # hypothetical (expensive) operation with elm
    # (in my code this is solving a linear system)
    localvar * elm
    # used_in_smallfunc(pars...)  # LoadError
    used_in_smallfunc(pars[1], pars[2])
  end

  pmap(smallfunc, iterator)
end

bigfunc(1:10)
