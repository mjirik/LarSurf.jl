using Meshing
using GeometryTypes
using LinearAlgebra: dot, norm
using FileIO

# generate an SDF of a sphere
sdf_sphere = SignedDistanceField(HyperRectangle(Vec(-1,-1,-1.),Vec(2,2,2.))) do v
    sqrt(sum(dot(v,v))) - 1 # sphere
end

m = GLNormalMesh(sdf_sphere, MarchingCubes())

save("sphere.ply",m)
