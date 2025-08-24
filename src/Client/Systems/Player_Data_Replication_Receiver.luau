local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Crates_Folder = workspace:WaitForChild("Crates")

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

local Util = require(ReplicatedStorage.Common.Modules.Util)

local CRATE_BOUNCE_TIME = 0.08
local Crate_Bounce_Tween_Info = TweenInfo.new(CRATE_BOUNCE_TIME, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)

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

        local Skip = Value:FindFirstChild("Skip") :: Model
        local Skip_Screen = Skip:FindFirstChild("Screen") :: Part

        local SkipPrompt = Instance.new("ProximityPrompt")
        SkipPrompt.ClickablePrompt = true
        SkipPrompt.Enabled = true
        SkipPrompt.Exclusivity = Enum.ProximityPromptExclusivity.OneGlobally
        SkipPrompt.GamepadKeyCode = Enum.KeyCode.ButtonX
        SkipPrompt.KeyboardKeyCode = Enum.KeyCode.E
        SkipPrompt.MaxActivationDistance = 10
        SkipPrompt.RequiresLineOfSight = false
        SkipPrompt.HoldDuration = 0.5
        SkipPrompt.ActionText = "Skip ⏩"
        SkipPrompt.ObjectText = ""
        SkipPrompt.Style = Enum.ProximityPromptStyle.Custom
        SkipPrompt.Parent = Skip_Screen

        SkipPrompt.Triggered:Connect(function()
            Network.Requests.SkipCrate.Fire()
        end)

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

local function Handle_Crate_Bounces()
    for _, Value in Network.BounceCrate.Iter() do
        if not Value:IsDescendantOf(Crates_Folder) then
            continue
        end

        task.spawn(function()
            Util.Tween_Model_Scale(1, 0.8, Crate_Bounce_Tween_Info, Value)

            task.wait(CRATE_BOUNCE_TIME)

            Util.Tween_Model_Scale(0.8, 1, Crate_Bounce_Tween_Info, Value)
        end)
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

        Handle_Crate_Bounces()
    end,
    runConditions = {},
}
