# import analysis functions

include("analysis_functions.jl")

# import plotting functions

include("plotting_functions.jl")

function getxysplit(df,x,y,errorbar::Bool)
    xvalue = get_axis(df[x])
    yvalue = getxy(df,xvalue,x,y)
    error = zeros(length(xvalue))
    valid = ~isna(y)
    return xvalue[valid], yvalue[valid], error[valid]
end

function getxysplit(df,x,y,errorbar::Symbol)
    splitdata = groupby(df, errorbar)
    xvalue = get_axis(df[x])
    v = DataArray(Float64, length(xvalue), length(splitdata));
    mean_across_pop = DataArray(Float64, length(xvalue));
    sem_across_pop = DataArray(Float64, length(xvalue));
    valid = Array(Bool, length(xvalue));
    for i in 1:length(splitdata)
        v[:,i] = getxy(splitdata[i],xvalue,x,y)
    end
    for j in 1:length(xvalue)
        mean_across_pop[j] = mean(dropna(v[j,:]))
        sem_across_pop[j] = sem(dropna(v[j,:]))
        valid[j] = (length(dropna(v[j,:]))>1)
    end
    return xvalue[valid], mean_across_pop[valid], sem_across_pop[valid]
end

#= Things to do:
1) Determine x axis!
2) Compute y axise for all pop, the get mean and std!
=#


get_axis(column::PooledDataArray) = sort!(union(column))
get_axis(column::AbstractArray) = linspace(minimum(column),maximum(column),100)


#Plots.jl version
function analyze_data(figura, df,x,y,zv; plot_func = myplot!, errorbar = false, kwargs...)

    df[:fake] = zeros(size(df,1))
    data = by(df,zv) do dd
        label = mapreduce(t-> "$t = $(dd[1,t]) ",string,"",zv)
        if zv == [:fake]
            label = ""
        end
        xvalue,yvalue,error = getxysplit(dd,x,y,errorbar)
        plot_func(figura, xvalue,yvalue, error;
        label=label, kwargs...)
        DataFrame(x = xvalue, y = yvalue, error = error, trace_number = figura.n)
    end
    return data
end

analyze_data(figura, df, x, y; kwargs...) = analyze_data(figura, df,x,y,[:fake];kwargs...)









# function getpermouse(df,funcx, funcy)
#     dati_condition = by(df,:MouseID) do dd
#         DataFrame(xdots = funcx(dd), ydots = funcy(dd))
#     end
#     return dati_condition[:xdots], dati_condition[:ydots]
# end
#
# function getpermousesplit(figura, df, zv, funcx, funcy;kwargs...)
#     df[:fake] = ["" for i in 1:size(df,1)]
#     # fill figure!
#     # fill figure!
#     listau = union(df[zv[end]])
#     sort!(listau)
#
#     if length(zv) > 1
#         listapu = union(df[zv[end-1]])
#         sort!(listapu)
#     end
#     indexpu = 1
#     dati = by(df,zv) do dd
#         indexu = findfirst(t -> t == dd[1,zv[end]], listau)
#         if length(zv) > 1
#             indexpu = findfirst(t -> t == dd[1,zv[end-1]], listapu)
#         end
#         xdots, ydots = getpermouse(dd,funcx, funcy)
#         label = mapreduce(t-> "$t = $(dd[1,t]) ",string,"",zv)
#         opz = [:circle, :diamond]
#         palette = get_color_palette(:auto, default(:bgcolor),100)
#         scatter!( figura,
#         xdots,
#         ydots,
#         color=palette[(indexu-1)%100+1],
#         markershape = opz[(indexpu-1)%2+1],
#         label = label;
#         kwargs...)
#         DataFrame(x = xdots, y = ydots)
#     end
#     return dati
# end


# for func in funcs
#   for plot_func in plot_funcs
#     @eval begin
#       function $(parse("$(func)m_$(plot_func)"))(figura, df, zv,args...;kwargs...)
#
#         # get xvalue
#         df[:fake] = ["" for i in 1:size(df,1)]
#         xvalue = union(df[args[1]])
#         sort!(xvalue)
#
#         if eltype(xvalue) <: Number
#           xvalue_replace = copy(xvalue)
#         else
#           xvalue_replace = collect(1:length(xvalue))
#         end
#         # fill figure!
#         listau = union(df[zv[end]])
#         sort!(listau)
#
#         if length(zv) > 1
#           listapu = union(df[zv[end-1]])
#           sort!(listapu)
#         end
#         indexpu = 1
#
#         dati = by(df,zv) do dd
#           indexu = findfirst(t -> t == dd[1,zv[end]], listau)
#           if length(zv) > 1
#             indexpu = findfirst(t -> t == dd[1,zv[end-1]], listapu)
#           end
#           media, errore, validi = $(parse("$(func)m"))(dd,xvalue,args...)
#           label = mapreduce(t-> "$t = $(dd[1,t]) ",string,"",zv)
#           if zv == [:fake]
#             label = ""
#           end
#           $(plot_func)(figura,indexu,indexpu, xvalue_replace[validi],media[validi], errore[validi],
#           label = label; kwargs...)
#           if ~(eltype(xvalue) <: Number)
#             xticks!(figura,xvalue_replace,map(string,xvalue))
#           end
#           DataFrame(x = xvalue, y = media, err = errore)
#         end
#         return dati
#       end
#     end
#   end
# end
