--@require UnitConversion
ARMarker = function(pos, name)
    local this = {}
    this.Position = pos
    this.Name = name
    return this
end

HUDMarkers = (function()
    local this = HorizonModule("HUD Simple Stats", "Simple flight stats","PreUpdate", true, 0)
    local vec2 = require("cpml/vec2")
    this.Tags = "system,hud,data"
    this.Config = {
        FOV = 43,
        MaxDistance = 10000,
        MarkerSize = 2.5,
        Markers = {
            ARMarker(vec3(17442775.554728,22652024.515086,1930.1708970298), "Test Marker"),
            ARMarker(vec3(17442775.434868,22652028.313883,1927.7876691544), "Madis Base"),
            ARMarker(vec3(17438322.598583,22648116.831735,-3113.1790178152), "Centcom's Factory")
        }
    }
    local hud = Horizon.GetModule("UI Controller").Displays[1]
    local static = Horizon.Memory.Static
    local defaultMarker = [[<svg viewBox="0 0 198 198"><path fill="#fff" d="M99 .35L197.65 99 99 197.65.35 99 99 .35M99 0L0 99l99 99 99-99L99 0z"/><path fill="none" stroke="#f2f2f2" stroke-miterlimit="10" d="M109 99H89M99 89v20"/><path fill="#fff" d="M188 89L99 10.31 10 89 99 0l89 89zM10 109l89 78.69L188 109l-89 89-89-89z" opacity=".8"/></svg>]]

    local xform = hud.TransformSize(this.Config.MarkerSize)
    local chairPos = vec3(Horizon.Core.getElementPositionById(Horizon.Controller.getId()))
        - vec3(16,15.75,16) 
        + vec3(-0.125,-1.075,0.225)
        
    local function makeMarker(arm)
        local marker = UIPanel(0,0,xform.x,xform.y)
        marker.Anchor = UIAnchor.Middle
        marker.Content = defaultMarker
        marker.Marker = arm
        marker.ShowMarker = true
        marker.OnUpdate = function(ref)
            local eyePos = Utils3d.localToRelative(chairPos, static.World.Up, static.World.Right, static.World.Forward)
            local screenPos = Utils3d.worldToScreen(
                    static.World.Position + eyePos,
                    ref.Marker.Position,
                    static.World.Forward,
                    static.World.Up,
                    this.Config.FOV)
            
            if screenPos.z < 0 then
                ref.Content = ""
                ref.ShowMarker = false
            else
                ref.Content = defaultMarker
                ref.ShowMarker = true
            end

            ref.Position = vec2(screenPos.x, 100 - screenPos.y)
            ref.IsDirty = true
        end
        local text = UIPanel(xform.x * 0.5, xform.y, xform.x * 2, 2)
        text.Anchor = UIAnchor.TopCenter
        text.Style = text.Style .. [[font-size: 0.75vh;text-align:center;-webkit-text-stroke-width: 2px;-webkit-text-stroke-color: #000000bb;text-shadow: 0 0 0.5vh #000000ff;]]
        text.OnUpdate = function(ref)
            local dist = (ref.Parent.Marker.Position - static.World.Position):len()
            if ref.Parent.ShowMarker then
                ref.Content = ref.Parent.Marker.Name .. "<br/>" .. tostring(unitconverter.VariableDistance(dist))
            else
                ref.Content = ""
            end
        end
        text.AlwaysDirty = true
        marker.AddChild(text)
        return marker
    end

    for _, v in ipairs(this.Config.Markers) do
        local marker = makeMarker(v)
        hud.AddWidget(marker)
    end

    return this
end)()
Horizon.RegisterModule(HUDMarkers)