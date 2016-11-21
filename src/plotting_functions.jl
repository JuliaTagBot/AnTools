plot_funcs = (:myscatter!,:myplot!)

function myscatter!(figura, x,y,d; kwargs...)
    scatter!(figura,x,y, err=d;kwargs...)
end

function myplot!(figura, x,y,d; kwargs...)
    plot!(figura,x,y, ribbon = d, fillalpha = 0.5, line = 2;kwargs...)
end

#get_color_palette(:auto, default(:bgcolor),100)
