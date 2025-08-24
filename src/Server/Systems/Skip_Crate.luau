local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local Ratelimit = require(ReplicatedStorage.Packages.Ratelimit)
local Skip_Rate_Limit = Ratelimit(1, 0.5)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = function()
        for _, Player: Player in Network.Requests.SkipCrate.Iter() do
            if not Skip_Rate_Limit(Player) then
                continue
            end

            local Player_Entity = Registry.Get("Players", Player)

            if not Player_Entity then
                continue
            end

            local Plot_Entity = World:target(Player_Entity, Components.Relationships.Plot)

            if not Plot_Entity then
                continue
            end

            local Crate = World:target(Plot_Entity, Components.Relationships.Crate)

            if not Crate then
                continue
            end

            if World:has(Crate, Components.Tags.Opening) then
                Network.Notification.Fire(Player, {
                    Text = "Your crate is opening!",
                })
                continue
            end

            World:delete(Crate)
        end
    end,
    runConditions = {},
}
