local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

return {
    name = script.Name,
    phase = Phases.Runservice.PreUpdate,
    system = function()
        for _, Player: Player, Target_Slot in Network.Requests.Swap.Iter() do
            local Player_Entity = Registry.Get("Players", Player)

            if not Player_Entity then
                continue
            end

            local Inventory = World:get(Player_Entity, Components.Inventory)
            local Equipped_Slot = World:get(Player_Entity, Components.Equipped_Slot)

            if Equipped_Slot == 0 then
                Network.Notification.Fire(Player, {
                    Text = "Equip a slot",
                })
                continue
            end

            if Equipped_Slot == 1 then
                Network.Notification.Fire(Player, {
                    Text = "Equip a different slot",
                })
                continue
            end

            Inventory[Equipped_Slot], Inventory[Target_Slot] = Inventory[Target_Slot], Inventory[Equipped_Slot]
        end
    end,
    runConditions = {},
}
