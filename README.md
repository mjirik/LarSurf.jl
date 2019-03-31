# lario3d.jl
Import 3D structures to LARLIB

    conda install -c simpleitk -c mjirik io3d simpleitk
    
For the visualization support by PyPlasm

```commandline
conda install pip numpy PyOpenGL
pip uninstall -y pyplasm
pip install --no-cache-dir pyplasm
```

Install pandas

```commandline
conda install pandas
```

```julia
Pkg.add("Pandas")
using Pandas

```
