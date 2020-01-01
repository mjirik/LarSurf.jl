nrn10_100:
2019-12-19 9:39
julia experiments\surface_extraction_parallel.jl --crop 100 -i nrn10.jld2 --show --taubin_n 20 --taubin_lambda 0.30 --taubin_mu -0.25

nrn10_100_green:
2019-12-20 11:21
julia experiments\surface_extraction_parallel.jl --crop 100 -i nrn10.jld2 --show --taubin_n 30 --taubin_lambda 0.4 --taubin_mu -0.35 --color 0. 1. 0. 0.

liver_01_white:
2019-12-20 12:10
julia experiments\surface_extraction_parallel.jl -d medical/orig/3Dircadb1.1/MASKS_DICOM/LIVER --show --taubin_n 40 --taubin_lambda 0.5 --taubin_mu -0.2 --n_procs 4 --threshold 0 --color 1. 1. 1. 0.5

liver_01_red:
2019-12-20 13:10
julia experiments\surface_extraction_parallel.jl -d medical/orig/3Dircadb1.1/MASKS_DICOM/LIVER --show --taubin_n 40 --taubin_lambda 0.5 --taubin_mu -0.2 --n_procs 4 --threshold 0 --color 1. 0. 0. 0.

portalvein_01_yellow_[1-3]
<!-- 2019-12-22 11:10 -->
2019-12-22 12:30
julia experiments\surface_extraction_parallel.jl -d medical/orig/3Dircadb1.1/MASKS_DICOM/portalvein --show --taubin_n 20 --taubin_lambda 0.5 --taubin_mu -0.2 --n_procs 4 --threshold 0 --color .9 .9 0. .9
