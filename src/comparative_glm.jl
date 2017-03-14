function add_cols_glm!(pokes)
    pokes[:leaves] = zeros(Int64,size(pokes,1))
    for i in 1:size(pokes,1)-1
        if pokes[i+1,:Side] != pokes[i,:Side]
            pokes[i,:leaves] = 1
        end
    end
    pokes[:rews] = pokes[:Rewarded].== "true"
    return
end

function get_lkl(rewards,leaves, params)
    α, β,λ, T = params
    neg_exp_λ = exp(-λ)
    Vs = zeros(size(rewards))
    Vs[1] = rewards[1]*β
    for i = 2:length(Vs)
        Vs[i] = Vs[i-1]*neg_exp_λ*(rewards[i] ? α : 1.)+rewards[i]*β
    end
    neglkl = -sum(log.(leaves+(1-2leaves).*(logistic.(Vs-T))))
end

function fit_glm(sel_pokes, init = [0.1,2.3,10.3,1.2])
    rewards = collect(sel_pokes[:Rewarded] .== "true")
    leaves = collect(sel_pokes[:leaves])
    optimize(t->get_lkl(rewards,leaves, t), init)
end
