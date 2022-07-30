--@class GravityCounterModule
--@require HorizonCore
--@require HorizonModule
--@require ThrustControlModule
--@require KeybindsModule
--@require ReadingsModule

GravityCounterModule = (function()
    local this = HorizonModule("Gravity Counter", "Negates the effect of gravity, allowing hovering and linear velocity approaches to planets", "Flush", true)
    this.Tags = "thrust,stability"
    this.Keybind = "GravityCounter"
    this.Config.Version = "%GIT_FILE_LAST_COMMIT%"
    this.QuickConfig = {
        Enabled = true,
        WidgetFactory = function(parent, hud, module)
            local template = HUDQuickConfig.Templates.Toggle(parent, hud, module)
            return template
        end,
        Order = 3,
        Category = "Stability Assists"
    }

    function this.Update(eventType, deltaTime)
        local world = Horizon.Memory.Static.World
        local ship = Horizon.Memory.Dynamic.Ship

        ship.Thrust = ship.Thrust - world.Gravity
    end

    Horizon.Emit.Subscribe(this.Keybind, this.ToggleEnabled)
    return this
end)()