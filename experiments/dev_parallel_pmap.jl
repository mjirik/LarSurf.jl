using Distributed
if nprocs() == 1
    addprocs(3)
end

function surface_extraction(iterator)
  localvar = 2.5
  block_func = function (elm)
    # hypothetical (expensive) operation with elm
    # (in my code this is solving a block)
    localvar * elm
  end

  pmap(block_func, iterator)
end

surface_extraction_mock(1:10)
