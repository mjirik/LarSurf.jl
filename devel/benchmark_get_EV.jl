using Logging
using LarSurf
using SparseArrays
using Pio3d
using BenchmarkTools

larmodel = LarSurf.Lar.cuboidGrid([1,1,2], true)
V, topology = larmodel
VV, EVorig, FV, CV = topology
deleteat!(FV,10)
# FVsurf = cat([FV[1:9], FV[11:end]])
EV = LarSurf.Smoothing.get_EV_quads(FV;return_unfiltered=true)
function ev_half(EV)
    sortedEV = sort(EV)
    EV = LarSurf.Smoothing.get_EV_quads(FV;return_unfiltered=false)
    return EV
end

function ev_set(EV)
    EV = collect(Set(EV))
    return EV
end
@benchmark ev_set(EV)
@benchmark ev_half(EV)
