using Distributed
@everywhere using ParallelDataTransfer

if nprocs() == 1
    addprocs(3)
end

mat = Dict()
println("----------------alskdjflaskfjasklf laksjflaskj-=-------")
mat["5x5x5"] = [1,2,3]
mat["15x15x15"] = [5,6]
matice = mat
sendto(workers(), matice=matice)

# matice = @spawn mat;
# mat[1] = 7
# matice = @spawn mat;

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
    vysledek = localvar * elm
    global matice

    # println("$localvar * $elm = $vysledek ")
    # matice
    # print("pred fetch $matice")
    # fetch(matice);
    # print("po fetch $matice")
    # local_matrix_storage = fetch(matice)
    local_matrix_storage = matice
    print(local_matrix_storage)
    if local_matrix_storage["5x5x5"][1] == 1
      local_matrix_storage["5x5x5"][1] = 2
      matice = @spawn local_matrix_storage
    else
      print(" else...")
    end
    # used_in_smallfunc(pars...)  # LoadError
    used_in_smallfunc(pars[1], pars[2])
  end

  pmap(smallfunc, iterator)
end

bigfunc(1:10)
