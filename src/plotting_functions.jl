plot_funcs = (:myscatter!,:myplot!)

function myscatter!(figura, indexu, indexpu, x,y,d;kwargs...)
  opz = [:circle, :diamond]
  palette =
  scatter!(figura,x,y, err=d, color=palette[(indexu-1)%100+1], markershape = opz[(indexpu-1)%2+1];kwargs...)
end

function myscattergr!(figura, x,y,d;kwargs...)
    scatter!(figura,x,y, err=d;kwargs...)
end

function myplot!(figura, x,y,d;kwargs...)
    plot!(figura,x,y, ribbon = d, fillalpha = 0.5, line = 2;kwargs...)
end


#get_color_palette(:auto, default(:bgcolor),100)
