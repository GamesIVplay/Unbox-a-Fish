local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local Map = workspace:WaitForChild("Map")
local Plots = Map:WaitForChild("Plots")

return {
    name = script.Name,
    phase = Phases.InitPhases.PreInit,
    system = function()
        for _, PlotModel: Model in Plots:GetChildren() do
            local PlotNumber = tonumber(PlotModel.Name)

            local Entity = World:entity()
            Registry.Define("Plots", PlotNumber, Entity)

            World:set(Entity, Components.Renderable, PlotModel)

            World:add(Entity, Components.Tags.Plot)
            World:add(Entity, Components.Tags.Networked)
        end
    end,
    runConditions = {},
}
