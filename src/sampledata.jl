# module sampledata

    # hexaogon
    #    3 -- 4
    #  /  \ /  \
    # 1 -- 2 -- 5
    #  \  / \  /
    #   7 -- 8
    function hexagon()
        hexagon_vertices = [0. 0.; 2. 0.; 1. 2.; 3. 2; 4. 0.; 3. -2.; 1. -2]
        hexagon_faces = [ 1 2 3; 2 4 3; 4 2 5; 5 2 6; 2 7 6; 2 1 7]

        return hexagon_vertices, hexagon_faces
    end

    # Two tetrahedrons
    function two_tetrahedrons()
        v = [1 1 1; 1 2 2; 2 2 1; 2 2 2; 2 3 2]
        f = [1 2 3; 1 2 4; 1 3 4; 2 3 4;
            2 3 4; 2 3 5; 2 4 5; 3 4 5]

        return v, f
    end

    function tetrahedron()
        # Tetrahedron
        v = [1 1 1; 1 2 2; 2 2 1; 2 2 2]
        f = [1 2 3; 1 2 4; 1 3 4; 2 3 4]
        return v, f
    end

# end

function generate_segmentation234()
    segmentation = zeros(Int8, 2, 3, 4)
    segmentation[1:2,2:3,3:4] .= 1
    return segmentation
end

function generate_segmentation567(factor::Integer=1)
    segmentation = zeros(Int8, 5*factor, 6*factor, 7*factor)
    segmentation[2*factor:5*factor,2*factor:5*factor,2*factor:6*factor] .= 1
    return segmentation

end

"""
Generate almost cubic image with size [a, a+1, a+2] and
object with size [a, a, a].
"""
function generate_almost_cube(factor::Real=10)
    shape = [
        Int(round(factor)),
        Int(round(factor)) + 1,
        Int(round(factor)) + 2
    ]
    segmentation = zeros(Int8, shape[1], shape[2], shape[3])
    segmentation[
        Int(round(0.2*factor)):Int(round(0.6*factor)),
        Int(round(0.3*factor)):Int(round(0.7*factor)),
        Int(round(0.4*factor)):Int(round(0.8*factor))
    ] .= 1
    return segmentation

end

"""
Generate almost cubic image with size [a, a, a] and
object with size [a, a, a].
offset can be set from 0.0 to 0.4, default is 0.2
"""
function generate_cube(factor::Real=10, offset=0.2; remove_one_pixel::Bool=false)
    shape = [
        Int(round(factor)),
        Int(round(factor)),
        Int(round(factor))
    ]
    segmentation = zeros(Int8, shape[1], shape[2], shape[3])
    segmentation[
        Int(round((offset + 0.0)*factor)):Int(round((offset + 0.4)*factor)),
        Int(round((offset + 0.1)*factor)):Int(round((offset + 0.5)*factor)),
        Int(round((offset + 0.2)*factor)):Int(round((offset + 0.6)*factor))
    ] .= 1
    # remove one pixel from the corner
    if remove_one_pixel
        segmentation[
        Int(round(0.2*factor)),
        Int(round(0.3*factor)),
        Int(round(0.4*factor))
        ] = 0
    end
    return segmentation

end

function generate_minecraft_kidney(size::Real)
    c1 = generate_cube(size, 0.1)
    c2 = generate_cube(size, 0.3)
    # return convert(Array{Int8,3}, (c1 - c2) .> 0)
    return (c1 - c2) .> 0
end
