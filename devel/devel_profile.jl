#=
devel_profile:
- Julia version: 1.1.0
- Author: Jirik
- Date: 2019-04-26
=#


println("start")
function profile_test(n)
    for i = 1:n
        A = randn(100,100,20)
        m = maximum(A)
        Am = mapslices(sum, A; dims=2)
        B = A[:,:,5]
        Bsort = mapslices(sort, B; dims=1)
        b = rand(100)
        C = B.*b
    end
end

profile_test(1)  # run once to trigger compilation
using Profile
Profile.clear()  # in case we have any previous profiling data
@profile profile_test(10)

println("after profile")
using ProfileView
ProfileView.view()

ProfileView.svgwrite("profile_results.svg")
