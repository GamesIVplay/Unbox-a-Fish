local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local Hammers = require(ReplicatedStorage.Common.Modules.Hammers)

return {
    name = script.Name,
    phase = Phases.Runservice.PreUpdate,
    system = function()
        for _, Player: Player, Data in Network.Requests.EquipSlot.Iter() do
            local Player_Entity = Registry.Get("Players", Player)

            if not Player_Entity then
                continue
            end

            local Character = World:get(Player_Entity, Components.Renderable) :: Model?

            if not Character then
                continue
            end

            local Humanoid = Character:FindFirstChildOfClass("Humanoid")

            if not Humanoid then
                continue
            end

            if not (Data >= 0) and (Data <= 6) then
                continue
            end

            local Current_Slot = World:get(Player_Entity, Components.Equipped_Slot)

            if Current_Slot == Data then
                World:set(Player_Entity, Components.Equipped_Slot, 0)
            else
                World:set(Player_Entity, Components.Equipped_Slot, Data)
            end

            if World:get(Player_Entity, Components.Equipped_Slot) == 1 then
                local Tool_Level = World:get(Player_Entity, Components.Tool_Level)

                local Tool = Hammers[Tool_Level].Model:Clone()
                Tool:AddTag("Hammer")

                Humanoid:EquipTool(Tool)
            else
                local Tool = Character:FindFirstChildOfClass("Tool")

                if Tool and Tool:HasTag("Hammer") then
                    Tool:Destroy()
                end
            end
        end
    end,
    runConditions = {},
}
