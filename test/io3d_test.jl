using LarSurf
using Test

@testset "test read" begin
    pth = Io3d.datasets_join_path("medical/orig/sample-data/nrn4.pklz")
    datap = Io3d.read3d(pth)

    data3d = datap["data3d"]
    # eltype(data3d)
    @test size(data3d) == (7,7,6)

end
# pth = Io3d.datasets_join_path("medical/orig/sample_data/nrn4.pklz")
# print(pth)
