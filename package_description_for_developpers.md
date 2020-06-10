# Description for developpers


# Algorithms

* Per-voxel surface extraction
  Surface is calculated as a union of each voxel 6 faces. The double inner faces are removed by expensive search algorithm.
  [surface_extraction_per_voxel.jl](src/surface_extraction_per_voxel.jl)


* LAR based surface extraction
  Extraction based on multiplication of LAR matrices. Multiple blocks on one CPU.
  [surface_extraction.jl](src/surface_extraction.jl)

* LAR based surface extraction parallel low communication
  Extraction based on multiplication of LAR matrices. Multiple blocks on one CPU.
  [surface_extraction_parallel_low_comunication.jl](src/surface_extraction_parallel_low_comunication.jl)

## Code organization

* [devel](devel/) is used for various develpment test. This can be messy but sometimes you can find there few interesting lines of code.
* [examples](examples/) This directory is more organized. It shoud be usefull for newcomer.
* [experiments](experiments/) Experiments prepared for paper.
* [graphics](graphics/) Images used on web or for presentation
* [src](src/)  sources for surface extraction from grid volumetric data. The core of the package.
  * [surface_extraction_per_voxel.jl](src/surface_extraction_per_voxel.jl) Per-voxel segmentation. Single process. Expensive computation.
  * [surface_extraction.jl](src/surface_extraction.jl) Surface extraction based on LAR. Per-block but still on one CPU.
  * [surface_extraction_parallel_low_comunication.jl](src/surface_extraction_parallel_low_comunication.jl) Surface extraction based on LAR. Per-block on multiple CPUs.
  * [per_voxel_tools.jl](src/per_voxel_tools.jl) Functions for per-voxel surface extraction from grid volumetric data. The double faces are removed by searching for duplicities in the list of Vertices and then searching of duplicities in Faces.
  * [block.jl](src/block.jl) Implementations of surface extraction functions used by all block parallel methods
  * [boundary_operator.jl](src/boundary_operator.jl) Computate, save and load boundary matrix.


## The experiment mode

There is implemented the experiment mode. It can be used for simple run the whole sequence and measure all the times.
The times are stored in `.csv` file (default is "exp_surface_extraction_times.csv").

* [Surface extraction](experiments/surface_extraction_parallel.jl)
