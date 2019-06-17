# LarSurf.jl

[![Build Status](https://travis-ci.com/mjirik/LarSurf.jl.svg?branch=master)](https://travis-ci.com/mjirik/LarSurf.jl)
[![Coveralls](https://coveralls.io/repos/github/mjirik/LarSurf.jl/badge.svg?branch=master)](https://coveralls.io/github/mjirik/LarSurf.jl?branch=master)


Package for surface extraction using Linear Algebraic Representation theory by
Alberto Paoluzzi. See
[original Julia repository](https://github.com/cvdlab/LinearAlgebraicRepresentation.jl)
for more details.

# Install python things
Import 3D structures to LARLIB

    conda install -c simpleitk -c mjirik -c conda-forge io3d simpleitk pandas

For the visualization support by PyPlasm

```commandline
conda install pip numpy PyOpenGL
pip uninstall -y pyplasm
pip install --no-cache-dir pyplasm
```

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
