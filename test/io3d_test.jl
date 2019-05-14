using lario3d
using Test

@testset "test read" begin
    pth = lario3d.datasets_join_path("medical/orig/sample-data/nrn4.pklz")
    datap = lario3d.read3d(pth)

    data3d = datap["data3d"]
    # eltype(data3d)
    @test size(data3d) == (7,7,6)

end
# pth = lario3d.datasets_join_path("medical/orig/sample_data/nrn4.pklz")
# print(pth)
