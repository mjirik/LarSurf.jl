# Description for developpers

Directories

* [devel](devel/) is used for various develpment test. This can be messy but sometimes you can find there few interesting lines of code.
* [examples](examples/) This directory is more organized. It shoud be usefull for newcomer.
* [experiments](experiments/) Experiments prepared for paper.
* [graphics](graphics/) Images used on web or for presentation
* src
** [import3d](src/import3d.jl) Functions for surface extraction from grid volumetric data. The double faces are removed by searching for duplicities in the list of Vertices and then searching of duplicities in Faces.
**

## The experiment mode

There is implemented the experiment mode. It can be used for simple run the whole sequence and measure all the times.
The times are stored in `.csv` file (default is "exp_surface_extraction_times.csv").

* [Surface extraction](experiments/surface_extraction_parallel.jl)
