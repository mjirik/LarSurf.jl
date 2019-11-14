# LarSurf.jl

[![Build Status](https://travis-ci.org/mjirik/LarSurf.jl.svg?branch=master)](https://travis-ci.org/mjirik/LarSurf.jl)
[![Coveralls](https://coveralls.io/repos/github/mjirik/LarSurf.jl/badge.svg?branch=master)](https://coveralls.io/github/mjirik/LarSurf.jl?branch=master)


Package for surface extraction using Linear Algebraic Representation theory by
Alberto Paoluzzi. See
[original Julia repository](https://github.com/cvdlab/LinearAlgebraicRepresentation.jl)
for more details.



# Install


```julia
] add https://github.com/cvdlab/LinearAlgebraicRepresentation.jl#julia-1.0
] add https://github.com/mjirik/LarSurf.jl
```


## Install extra
The package is prepared for pure Julia however for reading the
Computed Tomography
data we use Io3d.jl package. This package is wrapper for python `io3d`.

Import 3D structures to LARLIB

    conda install -c simpleitk -c mjirik -c conda-forge io3d simpleitk pandas



Install wrappers for python packages

```julia
ENV["PYTHON"] = split(read(`$((Sys.iswindows() ? "where" : "which")) python`, String), "\n")[1]
using Pkg; Pkg.add("PyCall") ; Pkg.build("PyCall")
] add Pandas
] add https://github.com/mjirik/Io3d.jl
] add https://github.com/mjirik/ExSu.jl
] add https://github.com/cvdlab/LinearAlgebraicRepresentation.jl#julia-1.0

using Pandas, Io3d

```

## For developers

```
develop https://github.com/mjirik/LarSurf.jl
```


# Examples

## Tetris example

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

![tetris](graphics/tetris_taubin.png)


## Liver extraction experiment

Run experiment with extraction of CT data. Measure all statistics.

### Get data

We are using dataset 3D-IRCADb 01 | IRCAD France.

```julia
using Io3d
Io3d.datasets_download("3Dircadb1.1")
datap = Io3d.read3d(Io3d.datasets_join_path("medical/orig/sample-data/nrn4.pklz"))

```
Data can be also manually downloaded from [dataset website](https://www.ircad.fr/research/3d-ircadb-01/)

### Run experiment

Due to long run time the experiment is divided into smaller parts.
The extracted data are stored into `.jld2` files.

* [Surface extraction](experiments/surface_extraction_parallel_ircad01.jl)
	The `stepxy` and `stepz` allow to drop some data for faster debug.
	The `blocks_size` parameter control the size of parallel blocks.
* [Smoothing](experiments/surface_extraction_parallel_ircad01_smoothing.jl)
* [Show extraction](experiments/surface_extraction_parallel_ircad01_show.jl)
* [Create `.obj` file](experiments/surface_extraction_parallel_ircad01_obj.jl)

All measured times are recorded into `.csv` file
(`exp_surface_extraction_ircad_times.csv`)

![smooth liver](graphics/liver_taubin.png)


# Troubleshooting

* Problems with install are often caused by PyCall package
	Check the python path

	```commandline
	which python
	```
