module AnTools
using DataFrames
using Plots
gr()
export  getxym_myplot!,
        get_xym_myscatter!,
        gethistm_myplot!,
        get_histm_myscatter!,
        get_cumm_myplot!,
        get_cumm_myscatter!,
        choose_data,
        getpermousesplit


include("big_functions.jl")
include("select_functions.jl")
end
