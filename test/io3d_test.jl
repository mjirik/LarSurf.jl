using lario3d
using Test

@testset "Block basic function Tests" begin
end
pth = lario3d.datasets_join_path("medical/orig/sample-data/nrn4.pklz")
datap = lario3d.read3d(pth)

data3d = datap["data3d"]
eltype(data3d)
# pth = lario3d.datasets_join_path("medical/orig/sample_data/nrn4.pklz")
# print(pth)
