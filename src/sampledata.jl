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