# import analysis functions and their names (vector funcs)

include("analysis_functions.jl")

# import plotting functions and their names (vector plot_funcs)

include("plotting_functions.jl")


for func in funcs
  @eval begin
    function $(parse("$(func)m"))(df,xaxis,args...)
      splitdata = groupby(df, :MouseID)
      v = DataArray(Float64, length(xaxis), length(splitdata));
      mean_across_mice = DataArray(Float64, length(xaxis));
      sem_across_mice = DataArray(Float64, length(xaxis));
      valid_axis = Array(Bool, length(xaxis));
      for i in 1:length(splitdata)
        v[:,i] = $(func)(splitdata[i],xaxis,args...)
      end
      for j in 1:length(xaxis)
        mean_across_mice[j] = mean(dropna(v[j,:]))
        sem_across_mice[j] = sem(dropna(v[j,:]))
        valid_axis[j] = (length(dropna(v[j,:]))>1)
      end
      return mean_across_mice, sem_across_mice, valid_axis
    end
  end
end

#= Things to do:
1) Determine x axis!
2) Compute y axise for all mice, the get mean and std!
=#


#Plots.jl version
for func in funcs
  for plot_func in plot_funcs
    @eval begin
      function $(parse("$(func)m_$(plot_func)"))(figura, df, zv,args...;kwargs...)

        # get xaxis
        df[:fake] = ["" for i in 1:size(df,1)]
        xaxis = union(df[args[1]])
        sort!(xaxis)

        if eltype(xaxis) <: Number
          xaxis_replace = copy(xaxis)
        else
          xaxis_replace = collect(1:length(xaxis))
        end
        # fill figure!
        listau = union(df[zv[end]])
        sort!(listau)

        if length(zv) > 1
          listapu = union(df[zv[end-1]])
          sort!(listapu)
        end
        indexpu = 1

        dati = by(df,zv) do dd
          indexu = findfirst(t -> t == dd[1,zv[end]], listau)
          if length(zv) > 1
            indexpu = findfirst(t -> t == dd[1,zv[end-1]], listapu)
          end
          media, errore, validi = $(parse("$(func)m"))(dd,xaxis,args...)
          label = mapreduce(t-> "$t = $(dd[1,t]) ",string,"",zv)
          if zv == [:fake]
            label = ""
          end
          $(plot_func)(figura,indexu,indexpu, xaxis_replace[validi],media[validi], errore[validi],
          label = label; kwargs...)
          if ~(eltype(xaxis) <: Number)
            xticks!(figura,xaxis_replace,map(string,xaxis))
          end
          DataFrame(x = xaxis, y = media, err = errore)
        end
        return dati
      end
    end
  end
end

function getpermouse(df,funcx, funcy)
  dati_condition = by(df,:MouseID) do dd
    DataFrame(xdots = funcx(dd), ydots = funcy(dd))
  end
  return dati_condition[:xdots], dati_condition[:ydots]
end

function getpermousesplit(figura, df, zv, funcx, funcy;kwargs...)
  df[:fake] = ["" for i in 1:size(df,1)]
  # fill figure!
  # fill figure!
  listau = union(df[zv[end]])
  sort!(listau)

  if length(zv) > 1
    listapu = union(df[zv[end-1]])
    sort!(listapu)
  end
  indexpu = 1
  dati = by(df,zv) do dd
    indexu = findfirst(t -> t == dd[1,zv[end]], listau)
    if length(zv) > 1
      indexpu = findfirst(t -> t == dd[1,zv[end-1]], listapu)
    end
    xdots, ydots = getpermouse(dd,funcx, funcy)
    label = mapreduce(t-> "$t = $(dd[1,t]) ",string,"",zv)
    opz = [:circle, :diamond]
    palette = get_color_palette(:auto, default(:bgcolor),100)
    scatter!( figura,
              xdots,
              ydots,
              color=palette[(indexu-1)%100+1],
              markershape = opz[(indexpu-1)%2+1],
              label = label;
              kwargs...)
    DataFrame(x = xdots, y = ydots)
  end
  return dati
end
