## Add extra functions to analyze the data
## Remember the format: y = f(df,x,xvalues,args...)
## First example: model!

function update(p,ρ,γ, rew)
    pnew = rew? 0 : (γ+p)/((1-γ)*(1-ρ))
    return pnew
end

function plow_high(ρ, γ, rews)
    n = length(rews)+1
    v = zeros(Float64,n)
    v[1] = 0
    for i in 2:n
        v[i] = update(v[i-1],ρ,γ,rews[i-1])
    end
    return v
end

function prob(T, ρ, n, p, γ) #add the fact that there could be reward!!!
    phnrw = zeros(Float64, n+1)
    plnrw = zeros(Float64, n+1)
    stay_cdf = zeros(Float64, n+1)
    stay_cdf[1] = 1.
    phnrw[1] = 1.
    plnrw[1] = 0.
    for i = 1:n
        phnrw[i+1] = phnrw[i]*(1-γ)*(1-p)
        plnrw[i+1] = phnrw[i]*γ+plnrw[i]
        stay_cdf[i+1] = cdf(Poisson(i*ρ),T)
    end
    leave_pdf = -diff(stay_cdf).*(phnrw+plnrw)[1:n]
    leave_correct = -diff(stay_cdf).*plnrw[1:n]
    leave_pdf, leave_correct = leave_pdf/sum(leave_pdf), leave_correct/sum(leave_pdf)
    confidence = sum(leave_correct)
    axis = collect(0:(n-1))
    v_mean = mean(axis,WeightVec(leave_pdf))
    v_std = std(axis,WeightVec(leave_pdf))
    return leave_pdf, v_mean, v_std, confidence
end

function dist(media, standard, T,ρ, n, p, γ)
    v_mean, v_std = prob(T,ρ,n,p,γ)[2:3]
    return (media-v_mean)^2+(standard-v_std)^2
end
function dist_media(media, standard, T,ρ, n, p, γ)
    v_mean, v_std = prob(T,ρ,n,p,γ)[2:3]
    return (media-v_mean)^2
end

function minimize(media, standard, n,p,γ)
    value = Inf
    sol = [0.,0.]
    for T = 1.:100.
        result = optimize(v -> dist(media,standard, T,v, n, p,γ), 0.05, 20.)
        if result.f_minimum < value
            value = result.f_minimum
            sol = [T,result.minimum]
        end
    end
    return sol, value
end
function minimize(media, standard,T::Float64, n,p,γ)
    value = Inf
    sol = [0.,0.]
    result = optimize(v -> dist_media(media,standard, T,v, n, p,γ), 0.05, 20.)
    if result.f_minimum < value
        value = result.f_minimum
        sol = [T,result.minimum]
    end
    return sol, value
end

function model(df, xaxis, x, T)
    v = AT.gethist(df, xaxis, x)
    data_mean = mean(xaxis,WeightVec(v))
    data_std = std(xaxis,WeightVec(v))
    p = df[:RewardProb][1]/100
    γ = df[:FlippingGamma][1]/100
    n = 2*maximum(xaxis)+1
    sol,value = minimize(data_mean, data_std, T, n,p,γ)
    T,ρ = sol
    vec = prob(T, ρ, n, p, γ)[1]
    return vec[xaxis+1],T,ρ, value
end
function model(df, xaxis, x, binsize)
    v = AT.gethist(df, xaxis, x, binsize)
    data_mean = mean(xaxis,WeightVec(v))
    data_std = std(xaxis,WeightVec(v))
    p = df[:RewardProb][1]/100
    γ = df[:FlippingGamma][1]/100
    n = 2*maximum(xaxis)+1
    sol,value = minimize(data_mean, data_std,6., n,p,γ)
    T,ρ = sol
    vec = prob(T, ρ, n, p, γ)[1]
    return vec[xaxis+1],T,ρ, value
end
