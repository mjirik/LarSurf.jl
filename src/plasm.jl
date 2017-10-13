function lar2plasm(EV, FE)
    EV = sparse(EV)
    faces = Array{Array{Int64, 1}, 1}()

    for f in 1:size(FE, 1)

        verts = Array{Int64, 1}()
        done = Array{Int64, 1}()
        face = FE[f, :]
        edges = EV[face.nzind, :]

        push!(done, 1)
        vs = edges[1, :].nzind
        if face.nzval[1] < 0
            vs = vs[end:-1:1]
        end
        startv, nextv = vs

        # println(startv)
        push!(verts, startv)
        while nextv != startv
            e = setdiff(edges[:, nextv].nzind, done)[1]
            push!(done, e)
            vs = edges[e, :].nzind
            if face.nzval[e] < 0
                vs = vs[end:-1:1]
            end
            curv, nextv = vs
            push!(verts, curv)
        end

        push!(faces, verts)
    end

    "FV = " * string(faces)[15:end]
end

function lar2py(V, EV)
    text = "V = [[0,0]"
    for i in 1:size(V, 1)
        text = text * "," * string(vec(V[i, :]))
    end
    text = text * "]\n"
    
    text = text * "EV = ["
    for i in 1:size(EV, 1)
        if i > 1 text = text * "," end
        text = text * string(EV[i, :].nzind)
    end
    text = text * "]"
    return text
end


function visualize_numbers(set, font_size)

    f = open("tmp.py", "w")

    write(f, "from larlib import *\n" *
        lar2py(set[1], set[2]) * "\n" *
        lar2plasm(set[2], set[3]) * "\n" *
        "VV = AA(LIST)(range(len(V)))\n" *
        "submodel = STRUCT(MKPOLS((V,EV)))\n" *
        "VIEW(larModelNumbering(1,1,1)(V,[VV,EV,FV],submodel,$font_size))\n")

    close(f)
    run(`python tmp.py`)
end

function visualize_boundary(set, boundary, font_size)
    f = open("tmp.py", "w")

    write(f, "from larlib import *\n" *
        lar2py(set[1], set[2]) * "\n" *
        lar2plasm(set[2], set[3]) * "\n" *
        "VV = AA(LIST)(range(len(V)))\n" *
        "submodel = STRUCT(MKPOLS((V,EV)))\n" *
        "model = larModelNumbering(1,1,1)(V,[VV,EV,FV],submodel,$font_size)\n" *
        lar2py(set[1], set[2][boundary.nzind, :]) * "\n" *
        "overmodel = STRUCT(MKPOLS((V,EV)))\n" *
        "VIEW(STRUCT([model, COLOR(RED)(overmodel)]))")

    close(f)
    run(`python tmp.py`)
end
