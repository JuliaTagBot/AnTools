using Distributions

leaveprob(T, r, n) = diff(cdf(Gamma(T, 1/r), 0:n+1))

function prob(p, γ, n) #add the fact that there could be reward!!!
    phnrw = zeros(Float64, n+1)
    plnrw = zeros(Float64, n+1)
    phnrw[1] = 1.
    plnrw[1] = 0.
    for i = 1:n
        phnrw[i+1] = phnrw[i]*(1-γ)*(1-p)
        plnrw[i+1] = phnrw[i]*γ+plnrw[i]
    end
    return phnrw, plnrw
end


function conditional_leaveprob(T, r, p, γ, n)
    phnrw, plnrw = prob(p, γ, n)
    unnorm_leave_prob = leaveprob(T, r, n).*(phnrw .+ plnrw)
    return unnorm_leave_prob ./ sum(unnorm_leave_prob)
end

function modelmeanstd(T, r, p, γ, n)
    axis = collect(0:n)
    v_mean = mean(axis, WeightVec(leave_pdf))
    v_std = std(axis, WeightVec(leave_pdf))
    return v_mean, v_std
end
