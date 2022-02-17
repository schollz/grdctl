-- grdctl

engine.name = 'PolyPerc' -- TODO: remove


function init()
    local grdctl_=include("grdctl/lib/grdctl")
    grdctl=grdctl_:new()
    print(grdctl.m)

    params:default()
end

