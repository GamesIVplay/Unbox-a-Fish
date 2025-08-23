local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Assets = ReplicatedStorage:WaitForChild("Assets")

local Billboards = Assets:WaitForChild("Billboards")
local YourPlot_Billboard = Billboards:WaitForChild("YourPlot") :: BillboardGui

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair

local Network = require(ReplicatedFirst.Network)

local Components = require(ReplicatedStorage.Common.Components)
local Phases = require(ReplicatedStorage.Common.Phases)
local Registry = require(ReplicatedStorage.Common.Registry)
local World = require(ReplicatedStorage.Common.World)

local Types = require(ReplicatedStorage.Common.Types)

local Fusion_Values = require(ReplicatedFirst.Client.Modules.Fusion_Values)

local function Handle_Cash_Changes(LocalEntity: Types.Entity)
    for _, Value in Network.PlayerChanges.Cash.Iter() do
        World:set(LocalEntity, Components.Cash, Value)

        Fusion_Values.Cash:set(Value)
    end
end

local function Handle_Tool_Level_Changes(LocalEntity: Types.Entity)
    for _, Value in Network.PlayerChanges.ToolLevel.Iter() do
        World:set(LocalEntity, Components.Tool_Level, Value)

        Fusion_Values.Tool_Level:set(Value)
    end
end

local function Handle_Luck_Level_Changes(LocalEntity: Types.Entity)
    for _, Value in Network.PlayerChanges.LuckLevel.Iter() do
        World:set(LocalEntity, Components.Luck_Level, Value)

        Fusion_Values.Luck_Level:set(Value)
    end
end

local function Handle_Index_Changes(LocalEntity: Types.Entity)
    for _, Value in Network.PlayerChanges.Index.Iter() do
        World:set(LocalEntity, Components.Index, Value)

        Fusion_Values.Index:set(Value)
    end
end

local function Handle_Tutorial_Step_Changes(LocalEntity: Types.Entity)
    for _, Value in Network.PlayerChanges.TutorialStep.Iter() do
        World:set(LocalEntity, Components.Tutorial_Step, Value)

        Fusion_Values.Tutorial_Step:set(Value)
    end
end

local function Handle_Friend_Boost_Changes(LocalEntity: Types.Entity)
    for _, Value in Network.PlayerChanges.FriendBoost.Iter() do
        World:set(LocalEntity, Components.FriendBoost, Value)

        Fusion_Values.Friend_Boost:set(Value)
    end
end

local function Handle_Plot_Assign(LocalEntity: Types.Entity)
    for _, Value in Network.PlayerChanges.PlotChosen.Iter() do
        YourPlot_Billboard:Clone().Parent = Value

        local PlotEntity = World:entity()

        World:set(PlotEntity, Components.Renderable, Value)

        World:add(PlotEntity, Components.Tags.Plot)
        World:add(PlotEntity, Pair(Components.Relationships.Owner, LocalEntity))

        World:add(LocalEntity, Pair(Components.Relationships.Plot, PlotEntity))
    end
end

local function Handle_Restock_Time(LocalEntity: Types.Entity)
    for _, Value in Network.PlayerChanges.RestockTime.Iter() do
        World:set(LocalEntity, Components.Restock_Time, Value)

        Fusion_Values.Restock_Time:set(Value)
    end
end

local function Handle_Stock_Changes(LocalEntity: Types.Entity)
    for _, Value in Network.PlayerChanges.Stock.Iter() do
        World:set(LocalEntity, Components.Stock, Value)

        Fusion_Values.Stock:set(Value)
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.First,
    system = function()
        local LocalEntity = Registry.Get("Players", "Local")

        Handle_Cash_Changes(LocalEntity)

        Handle_Tool_Level_Changes(LocalEntity)

        Handle_Luck_Level_Changes(LocalEntity)

        Handle_Index_Changes(LocalEntity)

        Handle_Tutorial_Step_Changes(LocalEntity)

        Handle_Friend_Boost_Changes(LocalEntity)

        Handle_Plot_Assign(LocalEntity)

        Handle_Restock_Time(LocalEntity)

        Handle_Stock_Changes(LocalEntity)
    end,
    runConditions = {},
}
