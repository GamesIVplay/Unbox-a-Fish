local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local AnimPlayer = require(ReplicatedStorage.Common.Modules.AnimPlayer)

return {
    name = script.Name,
    phase = Phases.InitPhases.PreInit,
    system = function()
        local LocalEntity = World:entity()
        Registry.Define("Players", "Local", LocalEntity)

        World:set(LocalEntity, Components.Player, LocalPlayer)

        World:set(LocalEntity, Components.Equipped_Slot, 0)
        World:set(LocalEntity, Components.Rebirth, 0)
        World:set(LocalEntity, Components.Cash, 0)
        World:set(LocalEntity, Components.Tool_Level, 1)
        World:set(LocalEntity, Components.Luck_Level, 1)
        World:set(LocalEntity, Components.Auto_Swing_Level, 1)
        World:set(LocalEntity, Components.Index, {})
        World:set(LocalEntity, Components.Inventory, {})

        World:set(LocalEntity, Components.Tutorial_Step, 0)

        World:set(LocalEntity, Components.FriendBoost, 1)

        if LocalPlayer.Character then
            World:set(LocalEntity, Components.Renderable, LocalPlayer.Character)

            task.spawn(function()
                local Humanoid = LocalPlayer.Character:WaitForChild("Humanoid")

                local Animator = Humanoid:WaitForChild("Animator")

                AnimPlayer.Load(Animator)
            end)
        end

        LocalPlayer.CharacterAdded:Connect(function(Character)
            World:set(LocalEntity, Components.Renderable, Character)

            local Humanoid = Character:WaitForChild("Humanoid")

            local Animator = Humanoid:WaitForChild("Animator")

            AnimPlayer.Load(Animator)
        end)

        LocalPlayer.CharacterRemoving:Connect(function()
            World:remove(LocalEntity, Components.Renderable)
        end)
    end,
    runConditions = {},
}
