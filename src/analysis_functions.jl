# Prima di tutto definisci la funzione che vuoi applicare

funcs = (:getxy, :gethist, :getcum)

function getxy(df, xaxis, x, y)
  media = by(df, x) do dd
      DataFrame(m = mean(dd[y]))
  end
  aux = DataFrame()
  aux[x] = xaxis
  mediaoverx = join(aux, media, on = x, kind = :left)
  return mediaoverx[:m]
end

function gethist(df, xaxis, x)
  vect = [length(find(df[x] .== t)) for t in xaxis]/length(df[x])
  return vect
end

function getcum(df, xaxis, x)
  vect = gethist(df, xaxis, x)
  return cumsum(vect)
end
