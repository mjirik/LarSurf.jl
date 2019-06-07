using SparseArrays,LinearAlgebra
n = 10000
L = sprand(Float64,n,n,0.3)
u0 = sprand(Float64,n,0.3)
u1 = similar(u0)

BLAS.set_num_threads(1)
@time mul!(u1,L,u0);

BLAS.set_num_threads(4)
@time mul!(u1,L,u0);

@time mul!(u1,L,u0);
u0_d = rand(Float64,n)

u1_d = similar(u0_d)

@time mul!(u1_d,L,u0_d);
