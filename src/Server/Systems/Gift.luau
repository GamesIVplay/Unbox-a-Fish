local MarketPlaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair

local Ratelimit = require(ReplicatedStorage.Packages.Ratelimit)
local Gift_Rate_Limit = Ratelimit(1, 0.5)

local GamepassIds = require(ReplicatedStorage.Common.Modules.GamepassIds)

local Network = require(ServerScriptService.Network)

local Add_Fish = require(ServerScriptService.Server.Modules.Add_Fish)
local Remove_Fish = require(ServerScriptService.Server.Modules.Remove_Fish)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local Colors = require(ReplicatedStorage.Common.Modules.Colors)
local Fish = require(ReplicatedStorage.Common.Modules.Fish)
local Mutations = require(ReplicatedStorage.Common.Modules.Mutations)

local Types = require(ReplicatedStorage.Common.Types)

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = function()
        for _, Player: Player, Target_Player_Entity: Types.Entity in Network.Requests.Gift.Iter() do
            if not Gift_Rate_Limit(Player) then
                continue
            end

            local Player_Entity = Registry.Get("Players", Player)

            if not Player_Entity then
                continue
            end

            local Character = World:get(Player_Entity, Components.Renderable) :: Model?

            if not Character then
                continue
            end

            if
                not Target_Player_Entity
                or not World:contains(Target_Player_Entity)
                or not World:has(Target_Player_Entity, Components.Player)
                or Player_Entity == Target_Player_Entity
            then
                continue
            end

            local Tutorial_Step = World:get(Player_Entity, Components.Tutorial_Step)

            if Tutorial_Step < 10 then
                Network.Notification.Fire(Player, {
                    Text = "Complete the tutorial first",
                })
                continue
            end

            local Equipped_Slot = World:get(Player_Entity, Components.Equipped_Slot)
            local Inventory = World:get(Player_Entity, Components.Inventory)

            local Equipped_Item = Inventory[Equipped_Slot]

            local Held_Fish_Name: string?
            local Held_Fish_Mutation: Types.Mutation?

            if Equipped_Slot ~= 1 and Equipped_Item then
                Held_Fish_Name = Equipped_Item.Name
                Held_Fish_Mutation = Equipped_Item.Mutation
            end

            if not Held_Fish_Name then
                Network.Notification.Fire(Player, {
                    Text = "Your not holding a fish",
                    Color = Colors.Error,
                })
                continue
            end

            Remove_Fish(Inventory, Held_Fish_Name, Held_Fish_Mutation)

            local Gifter_Name = World:get(Player_Entity, Components.Name)
            local Receiver_Name = World:get(Target_Player_Entity, Components.Name)

            local Target_Player_Inventory = World:get(Target_Player_Entity, Components.Inventory)
            local Target_Player = World:get(Target_Player_Entity, Components.Player)

            Add_Fish(Target_Player_Inventory, Held_Fish_Name, Held_Fish_Mutation)

            local Mutation_Text = Held_Fish_Mutation ~= nil and (Held_Fish_Mutation .. " ") or ""

            Network.Notification.Fire(Player, {
                Text = `Gifted {Receiver_Name} a {Mutation_Text}{Held_Fish_Name}`,
            })

            Network.Notification.Fire(Target_Player, {
                Text = `{Gifter_Name} gifted you a {Mutation_Text}{Held_Fish_Name}`,
            })
        end
    end,
    runConditions = {},
}
