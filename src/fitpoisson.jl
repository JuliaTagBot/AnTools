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
    weight_vec = Weights(conditional_leaveprob(T, r, p, γ, n))
    mean(axis, weight_vec), std(axis, weight_vec, corrected = false)
end

function dist(media, standard, T, r, p, γ, n)
    v_mean, v_std = modelmeanstd(T, r, p, γ, n)
    return (media-v_mean)^2+(standard-v_std)^2
end

function minimize(media, standard, p, γ, n = 30)
    value = Inf
    sol = [0.,0.]
    result = optimize(v -> dist(media,standard, v[1], v[2], p, γ, n), [10.0, 1.0])
    if result.f_minimum < value
        value = result.f_minimum
        sol = [T,result.minimum]
    end
    return sol, value
end
