local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local World = require(ReplicatedStorage.Common.World)

local Ratelimit = require(ReplicatedStorage.Packages.Ratelimit)
local Can_Run = Ratelimit(1, 1)

local Players = World:query(Components.Double_Luck_Time_Remaining, Components.Double_Mutation_Time_Remaining):cached()

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = function()
        for Player_Entity, Luck_Time_Remaining: number, Mutation_Time_Remaining: number in Players:iter() do
            World:set(Player_Entity, Components.Double_Luck_Time_Remaining, math.max(Luck_Time_Remaining - 1, 0))

            World:set(
                Player_Entity,
                Components.Double_Mutation_Time_Remaining,
                math.max(Mutation_Time_Remaining - 1, 0)
            )
        end
    end,
    runConditions = {
        function()
            return Can_Run()
        end,
    },
}
