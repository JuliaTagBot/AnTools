# Prima di tutto definisci la funzione che vuoi applicare

# Add cumulative, histogram, local linear regression, kernel density etc!
# Figure out how to use info of categorical vs non categorical variable!!
function getxy(df, xvalue, x, y::Symbol)
    media = by(df, x) do dd
        DataFrame(m = mean(dd[y]))
    end
    aux = DataFrame()
    aux[x] = xvalue
    mediaoverx = sort!(join(aux, media, on = x, kind = :left),cols = [x])
    return mediaoverx[:m]
end

getxy(df,xvalue, x, func::Function) = func(df,xvalue,x)

function gethist(df, xvalue, x)
    vect = [length(find(df[x] .== t)) for t in xvalue]/length(df[x])
    return vect
end

function getcum(df, xvalue, x)
    vect = gethist(df, xvalue, x)
    return cumsum(vect)
end
