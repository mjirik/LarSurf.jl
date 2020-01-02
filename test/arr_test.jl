using LarSurf


@testset "Convert 2D array to list and back" begin
    hexV, hexFVarr = LarSurf.hexagon()
    hexFVll = LarSurf.array2ll(hexFVarr)
    hexFVarr2 = LarSurf.ll2array(hexFVll)
    @test hexFVarr[2,1] == hexFVarr2[2,1]
    @test hexFVarr[4,2] == hexFVarr2[4,2]
end

@testset "Test characteristicMatrix implementations" begin
    mat0 = LarSurf.characteristicMatrix_for_loop(hexFVarr, size(hexV, 1))
    mat1 = characteristicMatrix_push(hexFVll )
    mat2 = characteristicMatrix_set( hexFVll )
    mat3 = characteristicMatrix_push(hexFVar )
    mat4 = characteristicMatrix_set( hexFVarr)

    @test match_arr(mat0, mat1)
    @test match_arr(mat0, mat2)
    @test match_arr(mat0, mat3)
    @test match_arr(mat0, mat4)
end
