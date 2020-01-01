# Notes for developers

There are few notes collected in this file



# Performance

# Experiment times explanation

* `reciving and decoding time [s]` is time when organiser (cpu 1) waits for
workers and decodes the data.

* `cumulative double face filtration time [s]` is part of
`reciving and decoding time [s]`. This time is consumed for filtering doubled faces.


## Double faces filtering

Does is make sense to make an optimization? Copy of the faces into sparsearray have to be done anyway.
See `surface_extraction_parallel_low_communication.jl` and function `lsp_get_surface()`

```julia
# TODO does it make sense to make an optimization? Copy of the faces into sparsearray have to be done anyway.
# println(faces_per_block)
# for  block_i=1:block_number
tm_doubled_filtration = @elapsed for big_fid in faces_per_block
    # median time 31 ns
    # bigFchar[big_fid] = (bigFchar[big_fid] + 1) % 2
    # median time 14 ns
    bigFchar[big_fid] = if (bigFchar[big_fid] == 1) 0 else 1 end
end
```

Complete surface extraction takes 23 seconds, the filtration (and copy to global) takes 7 seconds.
