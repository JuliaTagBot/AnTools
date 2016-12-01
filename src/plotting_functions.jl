plot_funcs = (:myscatter!,:myplot!)

function myscatter!(figura, x,y,d; kwargs...)
    scatter!(figura,x,y, err=d;kwargs...)
end

function myplot!(figura, x,y,rib; kwargs...)
    #plot!(figura,x,y, ribbon = d, fillalpha = 0.5, line = 2;kwargs...)
    current(figura)
    shadederror!(x,y,rib; kwargs)
end

#get_color_palette(:auto, default(:bgcolor),100)

function border(x,y,rib)
    rib1, rib2 = if Plots.istuple(rib)
        first(rib), last(rib)
    else
        rib, rib
    end
    yline = vcat(y-rib1,(y+rib2)[end:-1:1])
    xline = vcat(x,x[end:-1:1])
    return xline, yline
end

@userplot ShadedError

@recipe function f(s::ShadedError)
    x, y, rib = s.args

    # set up the subplots

    # line plot
    @series begin
        seriestype := :path
        primary := true
        x, y
    end

    # shaded error bar
    xline, yline = border(x,y,rib)

    @series begin
        seriestype := :path
        primary := false
        fillrange := 0
        fillalpha --> 0.5
        linewidth := 0
        xline, yline
    end
end
