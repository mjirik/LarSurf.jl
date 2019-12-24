# Notes for developers

There are few notes collected in this file



# Performance

## Double faces filtering

Does is make sense to make an optimization? Copy of the faces into sparsearray have to be done anyway.
See `surface_extraction_parallel_low_communication.jl` and function `lsp_get_surface()`
