local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Jecs = require(ReplicatedStorage.Packages.Jecs)
local Pair = Jecs.pair

local Network = require(ServerScriptService.Network)

local Components = require(ReplicatedStorage.Common.Components)
local Log = require(ReplicatedStorage.Common.Log)
local Phases = require(ReplicatedStorage.Common.Phases)
local World = require(ReplicatedStorage.Common.World)

local Util = require(ReplicatedStorage.Common.Modules.Util)

local Hammers = require(ReplicatedStorage.Common.Modules.Hammers)
local Types = require(ReplicatedStorage.Common.Types)

local Player_Entities = World:query(Components.Player):cached()

local function Replicate_Cash(Player: Player, Entity: Types.Entity)
    local Cash = World:get(Entity, Components.Cash)
    local Previous_Cash = World:get(Entity, Pair(Components.Relationships.Previous, Components.Cash))

    if Cash ~= Previous_Cash then
        Network.PlayerChanges.Cash.Fire(Player, Cash)

        World:set(Entity, Pair(Components.Relationships.Previous, Components.Cash), Cash)

        Log.Info(`{Player.Name}'s cash was changed to {Cash}`)
    end
end

local function Replicate_Tool_Level(Player: Player, Entity: Types.Entity)
    local Character = World:get(Entity, Components.Renderable)

    if not Character then
        return
    end

    local Tool_Level = World:get(Entity, Components.Tool_Level)
    local Previous_Tool_Level = World:get(Entity, Pair(Components.Relationships.Previous, Components.Tool_Level))

    if Tool_Level ~= Previous_Tool_Level then
        for _, Inst in Player.Backpack:GetChildren() do
            if Inst:HasTag("Hammer") then
                Inst:Destroy()
            end
        end

        for _, Inst in Character:GetChildren() do
            if Inst:HasTag("Hammer") then
                Inst:Destroy()
            end
        end

        local Hammer = Hammers[Tool_Level].Model:Clone()
        Hammer:AddTag("Hammer")
        Hammer.Parent = Player.Backpack

        Network.PlayerChanges.ToolLevel.Fire(Player, Tool_Level)

        World:set(Entity, Pair(Components.Relationships.Previous, Components.Tool_Level), Tool_Level)

        Log.Info(`{Player.Name}'s tool level was changed to {Tool_Level}`)
    end
end

local function Replicate_Inventory(Player: Player, Entity: Types.Entity)
    local Character = World:get(Entity, Components.Renderable)

    if not Character then
        return
    end

    local Inventory = World:get(Entity, Components.Inventory)
    local Previous_Inventory = World:get(Entity, Pair(Components.Relationships.Previous, Components.Inventory)) or {}

    if not Util.TablesAreEqual(Inventory, Previous_Inventory) then
        local Backpack = Player.Backpack

        -- Collect existing tools
        local Existing: { [string]: { Tool: Tool, Count: number, Container: Instance } } = {}

        local function ScanContainer(Container)
            for _, Tool in Container:GetChildren() do
                if Tool:IsA("Tool") and Tool:HasTag("Item") then
                    local Name = Tool.Name
                    local StrippedName, Count = Name:match("^(.*)%s%[x(%d+)%]$")

                    if not StrippedName then
                        StrippedName = Name
                        Count = 1
                    else
                        Count = tonumber(Count)
                    end

                    -- Prioritize higher counts
                    local ExistingEntry = Existing[StrippedName]
                    if not ExistingEntry or Count > ExistingEntry.Count then
                        Existing[StrippedName] = {
                            Tool = Tool,
                            Count = Count,
                            Container = Container,
                        }
                    end
                end
            end
        end

        ScanContainer(Backpack)
        if Character then
            ScanContainer(Character)
        end

        -- Update tools based on Traps data
        for Mutation, Fish in Inventory do
            for Name, Target_Amount in Fish do
                local Formatted_Name = `{Mutation ~= "Normal" and `{Mutation} ` or ""}{Name}`
                local ExistingEntry = Existing[Formatted_Name]

                if ExistingEntry then
                    local Tool = ExistingEntry.Tool
                    local CurrentCount = ExistingEntry.Count
                    if CurrentCount ~= Target_Amount then
                        Tool.Name = Target_Amount > 1 and string.format("%s [x%d]", Formatted_Name, Target_Amount)
                            or Formatted_Name
                    end
                    Existing[Formatted_Name] = nil -- Mark as processed
                else
                    -- Tool missing, create it
                    local Tool = Instance.new("Tool")
                    Tool.RequiresHandle = false
                    Tool.Name = Target_Amount > 1 and string.format("%s [x%d]", Formatted_Name, Target_Amount)
                        or Formatted_Name
                    Tool.CanBeDropped = false
                    Tool.Parent = Backpack

                    Tool:AddTag("Item")
                end
            end
        end

        -- Remove any trap tools that no longer exist in the Traps table
        for TrapName, Entry in Existing do
            if Entry.Tool:HasTag("Item") then
                Entry.Tool:Destroy()
            end
        end

        World:set(
            Entity,
            Pair(Components.Relationships.Previous, Components.Inventory),
            Util.CopyTable(Inventory, true)
        )
    end
end

local function Replicate_Luck_Level(Player: Player, Entity: Types.Entity)
    local Luck_Level = World:get(Entity, Components.Luck_Level)
    local Previous_Luck_Level = World:get(Entity, Pair(Components.Relationships.Previous, Components.Luck_Level))

    if Luck_Level ~= Previous_Luck_Level then
        Network.PlayerChanges.LuckLevel.Fire(Player, Luck_Level)

        World:set(Entity, Pair(Components.Relationships.Previous, Components.Luck_Level), Luck_Level)

        Log.Info(`{Player.Name}'s luck level was changed to {Luck_Level}`)
    end
end

local function Replicate_Auto_Swing_Level(Player: Player, Entity: Types.Entity)
    local Auto_Swing_Level = World:get(Entity, Components.Auto_Swing_Level)
    local Previous_Auto_Swing_Level = World:get(Entity, Pair(Components.Relationships.Previous, Components.Auto_Swing_Level))

    if Auto_Swing_Level ~= Previous_Auto_Swing_Level then
        Network.PlayerChanges.AutoSwingLevel.Fire(Player, Auto_Swing_Level)

        World:set(Entity, Pair(Components.Relationships.Previous, Components.Auto_Swing_Level), Auto_Swing_Level)

        Log.Info(`{Player.Name}'s auto swing level was changed to {Auto_Swing_Level}`)
    end
end

local function Replicate_Index(Player: Player, Entity: Types.Entity)
    local Index = World:get(Entity, Components.Index)

    local Previous_Index = World:get(Entity, Pair(Components.Relationships.Previous, Components.Index)) or {}

    for Fish_Entity, Fish_Name in
        World:query(Components.Name):with(Components.Tags.Fish, Pair(Components.Relationships.Owner, Entity))
    do
        local Fish_Mutation = World:get(Fish_Entity, Components.Mutation) or "Normal"

        if not Index[Fish_Mutation] then
            Index[Fish_Mutation] = {}
        end

        if not table.find(Index[Fish_Mutation], Fish_Name) then
            table.insert(Index[Fish_Mutation], Fish_Name)
        end
    end

    if not Util.TablesAreEqual(Index, Previous_Index) then
        Network.PlayerChanges.Index.Fire(Player, Index)

        World:set(Entity, Components.Index, Index)
        World:set(Entity, Pair(Components.Relationships.Previous, Components.Index), Util.CopyTable(Index, true))

        Log.Info(`{Player.Name}'s index was changed`)
    end
end

local function Replicate_Tutorial_Step(Player: Player, Entity: Types.Entity)
    local Tutorial_Step = World:get(Entity, Components.Tutorial_Step)
    local Previous_Tutorial_Step = World:get(Entity, Pair(Components.Relationships.Previous, Components.Tutorial_Step))

    if Tutorial_Step ~= Previous_Tutorial_Step then
        Network.PlayerChanges.TutorialStep.Fire(Player, Tutorial_Step)

        World:set(Entity, Pair(Components.Relationships.Previous, Components.Tutorial_Step), Tutorial_Step)

        Log.Info(`{Player.Name}'s tutorial step was changed to {Tutorial_Step}`)
    end
end

local function Replicate_Friend_Boost(Player: Player, Entity: Types.Entity)
    local FriendBoost = World:get(Entity, Components.FriendBoost)
    local PreviousFriendBoost = World:get(Entity, Pair(Components.Relationships.Previous, Components.FriendBoost))

    if FriendBoost ~= PreviousFriendBoost then
        Network.PlayerChanges.FriendBoost.Fire(Player, FriendBoost)

        World:set(Entity, Pair(Components.Relationships.Previous, Components.FriendBoost), FriendBoost)

        Log.Info(`{Player.Name}'s friend boost was changed to {FriendBoost}`)
    end
end

local function Replicate_Restock_Time(Player: Player, Entity: Types.Entity)
    local Restock_Time = World:get(Entity, Components.Restock_Time)
    local Previous_Restock_Time = World:get(Entity, Pair(Components.Relationships.Previous, Components.Restock_Time))

    if Restock_Time ~= Previous_Restock_Time then
        Network.PlayerChanges.RestockTime.Fire(Player, Restock_Time)

        World:set(Entity, Pair(Components.Relationships.Previous, Components.Restock_Time), Restock_Time)

        Log.Info(`{Player.Name}'s restock time was changed to {Restock_Time}`)
    end
end

local function Replicate_Stock(Player: Player, Entity: Types.Entity)
    local Stock = World:get(Entity, Components.Stock)
    local Previous_Stock = World:get(Entity, Pair(Components.Relationships.Previous, Components.Stock)) or {}

    if not Util.TablesAreEqual(Stock, Previous_Stock) then
        Network.PlayerChanges.Stock.Fire(Player, Stock)

        World:set(Entity, Pair(Components.Relationships.Previous, Components.Stock), Util.CopyTable(Stock, true))

        Log.Info(`{Player.Name}'s stock was changed`)
    end
end

local function Replicate_Bought_One_Time_Offer(Player: Player, Entity: Types.Entity)
    local Bought_One_Time_Offer = World:has(Entity, Components.Tags.BoughtOneTimeOffer)
    local Previous_Bought_One_Time_Offer =
        World:get(Entity, Pair(Components.Relationships.Previous, Components.Tags.BoughtOneTimeOffer))

    if Bought_One_Time_Offer ~= Previous_Bought_One_Time_Offer then
        Network.PlayerChanges.BoughtOneTimeOffer.Fire(Player, Bought_One_Time_Offer)

        World:set(
            Entity,
            Pair(Components.Relationships.Previous, Components.Tags.BoughtOneTimeOffer),
            Bought_One_Time_Offer
        )
    end
end

return {
    name = script.Name,
    phase = Phases.Runservice.PostUpdate,
    system = function()
        for Entity, Player in Player_Entities:iter() do
            Replicate_Cash(Player, Entity)

            Replicate_Tool_Level(Player, Entity)

            Replicate_Inventory(Player, Entity)

            Replicate_Luck_Level(Player, Entity)

            Replicate_Auto_Swing_Level(Player, Entity)

            Replicate_Index(Player, Entity)

            Replicate_Tutorial_Step(Player, Entity)

            Replicate_Friend_Boost(Player, Entity)

            Replicate_Restock_Time(Player, Entity)

            Replicate_Stock(Player, Entity)

            Replicate_Bought_One_Time_Offer(Player, Entity)
        end
    end,
    runConditions = {},
}
