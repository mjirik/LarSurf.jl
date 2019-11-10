# LarSurf.jl

[![Build Status](https://travis-ci.org/mjirik/LarSurf.jl.svg?branch=master)](https://travis-ci.org/mjirik/LarSurf.jl)
[![Coveralls](https://coveralls.io/repos/github/mjirik/LarSurf.jl/badge.svg?branch=master)](https://coveralls.io/github/mjirik/LarSurf.jl?branch=master)


Package for surface extraction using Linear Algebraic Representation theory by
Alberto Paoluzzi. See
[original Julia repository](https://github.com/cvdlab/LinearAlgebraicRepresentation.jl)
for more details.


# Example

Do the surface extraction on simple shape. [Source code](examples/show_surface_parallel_tetris.jl)

```julia

using ViewerGL
using Distributed
if nprocs() == 1
    addprocs(3)
	@info "adding 3 more CPUs"
end
using Test
using Logging
using SparseArrays
@everywhere using LarSurf

block_size = [2, 2, 2]
segmentation = LarSurf.tetris_brick()
LarSurf.lsp_setup(block_size)
larmodel = LarSurf.lsp_get_surface(segmentation)
V, FV = larmodel
FVtri = LarSurf.triangulate_quads(FV)
objlines = LarSurf.Lar.lar2obj(V, FVtri, "tetris_tri.obj")

ViewerGL.VIEW([
    ViewerGL.GLGrid(V,FVtri,ViewerGL.Point4d(1,1,1,0.1))
	ViewerGL.GLAxis(ViewerGL.Point3d(-1,-1,-1),ViewerGL.Point3d(1,1,1))
])
```

![tetris](graphics/tetris.png)

```Julia

Vs = LarSurf.Smoothing.smoothing_FV_taubin(V, FV, 0.4, -0.2, 2)

ViewerGL.VIEW([
    ViewerGL.GLGrid(Vs,FVtri,ViewerGL.Point4d(1,1,1,0.1))
	ViewerGL.GLAxis(ViewerGL.Point3d(-1,-1,-1),ViewerGL.Point3d(1,1,1))
])

objlines = LarSurf.Lar.lar2obj(V, FVtri, "tetris_tri_taubin.obj")
```

![tetris](graphics/tetris_tri_taubin.png)


# Install

The package is prepared for Julia however for reading the Computed Tomography
data we use Io3d.jl package. This package is wrapper for python `io3d`.

# Install python things

Import 3D structures to LARLIB

    conda install -c simpleitk -c mjirik -c conda-forge io3d simpleitk pandas

Check the python path

```commandline
which python
```


Install wrappers for python packages

```julia
run(`which python`)

ENV["PYTHON"] = "/home/mirjirik/space/conda-env/julia/bin/python"
] add Pandas
] add https://github.com/mjirik/Io3d.jl
] add https://github.com/cvdlab/LinearAlgebraicRepresentation.jl#julia-1.0


using Pandas, Io3d

```

# For developers

```
develop https://github.com/mjirik/LarSurf.jl
```
