local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local World = require(ReplicatedStorage.Common.World)

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair

local Fish_Without_Owner =
    World:query(Components.Tags.Fish):without(Pair(Components.Relationships.Owner, Jecs.Wildcard)):cached()

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = function()
        for Fish_Entity in Fish_Without_Owner:iter() do
            World:delete(Fish_Entity)
        end
    end,
    runConditions = {},
}
