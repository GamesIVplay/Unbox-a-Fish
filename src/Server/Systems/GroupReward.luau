local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local Add_Fish = require(ServerScriptService.Server.Modules.Add_Fish)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local GroupId = require(ReplicatedStorage.Common.Modules.GroupId)

return {
    name = script.Name,
    phase = Phases.Runservice.PreUpdate,
    system = function()
        for _, Player: Player in Network.Requests.GroupReward.Iter() do
            task.spawn(function()
                local Player_Entity = Registry.Get("Players", Player)

                if not Player_Entity then
                    return
                end

                if not Player:IsInGroup(GroupId) then
                    Network.Notification.Fire(Player, {
                        Text = "Your not in the group",
                    })
                    return
                end

                if World:has(Player_Entity, Components.Tags.Claimed_Group_Rewards) then
                    Network.Notification.Fire(Player, {
                        Text = "You already claimed this",
                    })

                    return
                end

                local Cash = World:get(Player_Entity, Components.Cash)
                local Inventory = World:get(Player_Entity, Components.Inventory)

                Add_Fish(Inventory, "Cappuccino Assassino", "Gold")

                World:add(Player_Entity, Components.Tags.Claimed_Group_Rewards)
                World:set(Player_Entity, Components.Cash, Cash + 20000)
                World:set(Player_Entity, Components.Inventory, Inventory)

                Network.Notification.Fire(Player, {
                    Text = "Rewards Claimed!",
                })

                Network.Confetti.Fire(Player)
            end)
        end
    end,
    runConditions = {},
}
