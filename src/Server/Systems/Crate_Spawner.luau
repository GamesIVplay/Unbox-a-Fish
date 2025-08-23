local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Crates_Folder = workspace:WaitForChild("Crates")

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local World = require(ReplicatedStorage.Common.World)

local Crates = require(ReplicatedStorage.Common.Modules.Crates)
local StatCalculator = require(ReplicatedStorage.Common.Modules.StatCalculator)

local Plots_With_Owner_Without_Crate = World:query(Components.Renderable)
    :with(Components.Tags.Plot, Pair(Components.Relationships.Owner, Jecs.Wildcard))
    :without(Pair(Components.Relationships.Crate, Jecs.Wildcard))
    :cached()

local function Roll_Crate(LuckMultiplier: number)
    LuckMultiplier = LuckMultiplier

    local Total = 0
    local Adjusted = {}

    for Name, Data in Crates do
        local Weighted = Data.Chance ^ (1 / LuckMultiplier)
        Adjusted[Name] = Weighted
        Total += Weighted
    end

    local Roll = math.random() * Total
    local Cumulative = 0

    for Name, Weight in Adjusted do
        Cumulative += Weight
        if Roll <= Cumulative then
            return Name, Crates[Name]
        end
    end

    return
end

return {
    name = script.Name,
    phase = Phases.Runservice.Update,
    system = function()
        for Plot_Entity, Plot_Model: Model in Plots_With_Owner_Without_Crate:iter() do
            local Crate_Stand = Plot_Model:FindFirstChild("Crate_Stand") :: Model

            local Owner_Entity = World:target(Plot_Entity, Components.Relationships.Owner)
            local Owner_Player = World:get(Owner_Entity, Components.Player) :: Player

            local Crate_Queue = World:get(Owner_Entity, Components.Crate_Queue)
            local Luck_Level = World:get(Owner_Entity, Components.Luck_Level)
            local Luck_Multiplier = StatCalculator.Calculate_Luck(Luck_Level)

            local Crate_Name
            local Crate_Data

            if #Crate_Queue > 0 then
                Crate_Name = Crate_Queue[1]
                Crate_Data = Crates[Crate_Name]

                table.remove(Crate_Queue, 1)

                World:set(Owner_Entity, Components.Crate_Queue, Crate_Queue)
            else
                Crate_Name, Crate_Data = Roll_Crate(Luck_Multiplier)
            end

            local Crate_Model = Crate_Data.Model:Clone()
            Crate_Model:PivotTo(Crate_Stand:GetPivot())
            Crate_Model:SetAttribute("Owner", Owner_Player.UserId)

            Crate_Model.Parent = Crates_Folder

            local Crate_Entity = World:entity()

            World:set(Crate_Entity, Components.Name, Crate_Name)
            World:set(Crate_Entity, Components.Renderable, Crate_Model)
            World:set(Crate_Entity, Components.Health, Crate_Data.Health)
            World:set(Crate_Entity, Pair(Components.Relationships.Max, Components.Health), Crate_Data.Health)

            World:add(Crate_Entity, Components.Tags.Crate)
            World:add(Crate_Entity, Components.Tags.Networked)
            World:add(Plot_Entity, Pair(Components.Relationships.Crate, Crate_Entity))

            World:set(Crate_Entity, Components.Cleanup, function()
                Crate_Model:Destroy()
            end)
        end
    end,
    runConditions = {},
}
