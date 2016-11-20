# Repository for analysis and plotting of a dataframe #

### What is this repository for? ###

It exports one function to select data, as well as six functions to make cumulative, histogram or xy plots, with line plot with shaded error or scatter plot with error bars.

The error bar is standard error of the mean across mice. It is assumed that the mouse label is :MouseID.

This packages relies on [DataFrames](https://github.com/JuliaStats/DataFrames.jl) and [Plots](https://github.com/tbreloff/Plots.jl) (the plotlyjs backend).