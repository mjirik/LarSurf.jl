using LarSurf


@testset "Convert 2D array to list and back" begin
    hexV, hexFVarr = LarSurf.hexagon()
    hexFVll = LarSurf.array2ll(hexFVarr)
    hexFVarr2 = LarSurf.ll2array(hexFVll)
    @test hexFVarr[2,1] == hexFVarr2[2,1]
    @test hexFVarr[4,2] == hexFVarr2[4,2]
end

@testset "Test characteristicMatrix implementations" begin
    hexV, hexFVarr = LarSurf.hexagon()
    hexFVll = LarSurf.array2ll(hexFVarr)
    mat0 = LarSurf.characteristicMatrix_for_loop(hexFVarr, size(hexV, 1))
    mat1 = LarSurf.characteristicMatrix_push(hexFVll )
    mat2 = LarSurf.characteristicMatrix_set( hexFVll )
    mat3 = LarSurf.characteristicMatrix_push(hexFVar )
    mat4 = LarSurf.characteristicMatrix_set( hexFVarr)

    @test LarSurf.match_arr(mat0, mat1)
    @test LarSurf.match_arr(mat0, mat2)
    @test LarSurf.match_arr(mat0, mat3)
    @test LarSurf.match_arr(mat0, mat4)
end
