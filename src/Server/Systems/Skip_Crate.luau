local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Network = require(ServerScriptService.Network)

local Ratelimit = require(ReplicatedStorage.Packages.Ratelimit)
local Skip_Rate_Limit = Ratelimit(1, 8)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = function()
        for _, Player: Player in Network.Requests.SkipCrate.Iter() do
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

            local Tutorial_Step = World:get(Player_Entity, Components.Tutorial_Step)

            if Tutorial_Step ~= 5 and Tutorial_Step < 11 then
                Network.Notification.Fire(Player, {
                    Text = "Complete the tutorial first",
                })
                continue
            end

            if not Skip_Rate_Limit(Player_Entity) then
                Network.Notification.Fire(Player, {
                    Text = "You're on cooldown",
                })
                continue
            end

            if Tutorial_Step == 5 then
                World:set(Player_Entity, Components.Tutorial_Step, 6)
            end

            World:delete(Crate)
        end
    end,
    runConditions = {},
}
